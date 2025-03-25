import os
import time
import threading
import torch.multiprocessing as mp

from pathlib import Path
from copy import deepcopy
from typing import Callable, Optional, Dict
from biotrainer.protocols import Protocol
from biotrainer.utilities import read_FASTA
from biotrainer.utilities.cli import headless_main_with_custom_trainer

from ..embeddings import CalculateEmbeddingsTask
from ..server_management import TaskInterface, TaskDTO, FileContextManager, EmbeddingDatabaseFactory, \
    EmbeddingsDatabase, BiotrainerDatabaseStorageTrainer


class BiotrainerTask(TaskInterface):

    def __init__(self, model_path: Path, config_dict: dict):
        super().__init__()
        self.model_path = model_path
        self.config_dict = config_dict
        self.stop_reading = False
        self._last_read_position_in_log_file = 0
        self.biotrainer_process: Optional[mp.Process] = None

    @staticmethod
    def _read_seqs(server_sequence_file_path):
        file_context_manager = FileContextManager()
        with file_context_manager.storage_read(server_sequence_file_path) as seq_file_path:
            all_seq_records = read_FASTA(str(seq_file_path))
        return {seq.id: str(seq.seq) for seq in all_seq_records}

    @staticmethod
    def _create_custom_trainer(hp_manager, output_vars, config):
        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        return BiotrainerDatabaseStorageTrainer(hp_manager=hp_manager, output_vars=output_vars,
                                                embeddings_db=embeddings_db, **config)

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        server_sequence_file_path = self.config_dict["sequence_file"]
        all_seqs = self._read_seqs(server_sequence_file_path)

        protocol = Protocol.from_string(self.config_dict['protocol'])
        reduced = protocol in Protocol.using_per_sequence_embeddings()

        file_context_manager = FileContextManager()
        with file_context_manager.storage_write(self.model_path) as biotrainer_out_path:
            # Set output dirs to temp dir
            self.config_dict["output_dir"] = str(biotrainer_out_path)
            log_path = biotrainer_out_path / "logger_out.log"

            # Save files temporarily on the file system
            for key, value in self.config_dict.items():
                if "_file" in key and key != 'ignore_file_inconsistencies':
                    temp_path = biotrainer_out_path / (key + ".fasta")
                    file_context_manager.save_file_temporarily(temp_path, value)
                    self.config_dict[key] = str(temp_path)

            # Save embeddings to temp dir
            embedder_name = self.config_dict["embedder_name"]
            if embedder_name != "one_hot_encoding":  # Encode OHE during biotrainer process
                self._pre_embed_with_db(all_seqs=all_seqs, reduced=reduced)

            # TODO Device Management
            self.config_dict["device"] = "cuda"
            config = deepcopy(self.config_dict)

            # Run biotrainer
            self.biotrainer_process = mp.Process(target=headless_main_with_custom_trainer,
                                                 args=(config, self._create_custom_trainer), )
            self.biotrainer_process.start()

            self._read_logs(update_dto_callback=update_dto_callback, log_path=log_path)
            self.biotrainer_process.join()

        return TaskDTO.finished(result={})

    def _read_logs(self, update_dto_callback: Callable, log_path: Path):
        while self.biotrainer_process.is_alive():
            new_log_content = self._read_log_file(log_path)
            if new_log_content != "":
                update_dto_callback(TaskDTO.running().add_update({"log_file": new_log_content}))
            time.sleep(1)
        # After stop reading we read the last output from the log file
        final_log_content = self._read_log_file(log_path)
        update_dto_callback(TaskDTO.running().add_update({"log_file": final_log_content}))

    def _read_log_file(self, log_path: Path):
        if os.path.exists(log_path):
            with open(log_path, "r") as log_file:
                log_file.seek(self._last_read_position_in_log_file)
                new_log_content = log_file.read()
                self._last_read_position_in_log_file = log_file.tell()
                return new_log_content
        return ""

    def _pre_embed_with_db(self, all_seqs: Dict[str, str], reduced: bool):
        embedder_name = self.config_dict['embedder_name']
        device = self.config_dict.get('device', None)

        calculate_embedding_task = CalculateEmbeddingsTask(embedder_name=embedder_name,
                                                           sequence_input=all_seqs,
                                                           reduced=reduced,
                                                           use_half_precision=False,
                                                           device=device)
        embedding_dto: Optional[TaskDTO] = None
        for current_dto in self.run_subtask(calculate_embedding_task):
            embedding_dto = current_dto

        if not embedding_dto:
            raise Exception("Could not compute embeddings!")
