import os
import time
import torch.multiprocessing as mp

from pathlib import Path
from typing import Callable, Optional
from biotrainer.utilities.cli import headless_main

from ..embeddings import EmbeddingTask
from ..server_management import TaskInterface, EmbeddingsDatabase, TaskDTO, FileContextManager


class BiotrainerTask(TaskInterface):

    def __init__(self, model_path: Path, config_dict: dict):
        super().__init__()
        self.model_path = model_path
        self.config_dict = config_dict
        self.stop_reading = False
        self._last_read_position_in_log_file = 0
        self.biotrainer_process = None

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        server_sequence_file_path = self.config_dict["sequence_file"]

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
            hdf5_temp_path = biotrainer_out_path / "embeddings.h5"
            self._pre_embed_with_db(server_sequence_file_path=server_sequence_file_path,
                                    hdf5_temp_path=hdf5_temp_path)
            self.config_dict.pop("embedder_name")
            self.config_dict["embeddings_file"] = str(hdf5_temp_path)

            # Run biotrainer
            self.biotrainer_process = mp.Process(target=headless_main, args=(self.config_dict,), )
            self.biotrainer_process.start()

            # Read logs until process is finished
            self._read_logs(update_dto_callback=update_dto_callback, log_path=log_path)

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

    def _pre_embed_with_db(self, server_sequence_file_path: str, hdf5_temp_path: Path):
        embedder_name = self.config_dict['embedder_name']
        protocol = self.config_dict['protocol']
        device = self.config_dict.get('device', None)

        embedding_task = EmbeddingTask(embedder_name=embedder_name,
                                       sequence_file_path=server_sequence_file_path,
                                       embeddings_out_path=hdf5_temp_path.parent,
                                       protocol=protocol,
                                       use_half_precision=False,
                                       device=device)
        embedding_dto: Optional[TaskDTO] = None
        for current_dto in self.run_subtask(embedding_task):
            embedding_dto = current_dto

        if embedding_dto:
            embeddings_task_result = embedding_dto.update["embeddings_file"][embedder_name]
            # TODO [Optimization] Try to avoid double reading and saving of embedding files
            EmbeddingsDatabase.export_embeddings_task_result_to_hdf5(embeddings_task_result=embeddings_task_result,
                                                                 output_path=hdf5_temp_path)
