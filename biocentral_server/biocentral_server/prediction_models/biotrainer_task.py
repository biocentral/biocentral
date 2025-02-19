import os
import time
import yaml
import tempfile
import torch.multiprocessing as mp

from pathlib import Path
from typing import Callable
from biotrainer.utilities.cli import headless_main

from ..embeddings import EmbeddingTask
from ..server_management import TaskInterface, EmbeddingsDatabase, TaskDTO


class BiotrainerTask(TaskInterface):

    def __init__(self, config_path: Path, config_dict: dict, log_path: Path):
        super().__init__()
        self.config_path = config_path
        self.config_dict = config_dict
        self.log_path = log_path
        self.stop_reading = False
        self._last_read_position_in_log_file = 0
        self._log_output = ""  # TODO Can maybe be removed
        self.biotrainer_process = None

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        self._pre_embed_with_db()

        self.biotrainer_process = mp.Process(target=headless_main, args=(str(self.config_path),))
        self.biotrainer_process.start()
        self._read_logs(update_dto_callback)

        return TaskDTO.finished(result={})

    def _read_logs(self, update_dto_callback: Callable):
        while self.biotrainer_process.is_alive():
            new_log_content = self._read_log_file()
            if new_log_content != "":
                update_dto_callback(TaskDTO.running().add_update({"log_file": new_log_content}))
            time.sleep(1)
        # After stop reading we read the last output from the log file
        final_log_content = self._read_log_file()
        update_dto_callback(TaskDTO.running().add_update({"log_file": final_log_content}))

    def _read_log_file(self):
        if os.path.exists(self.log_path):
            with open(self.log_path, "r") as log_file:
                log_file.seek(self._last_read_position_in_log_file)
                new_log_content = log_file.read()
                self._log_output = new_log_content
                self._last_read_position_in_log_file = log_file.tell()
                return new_log_content
        return ""

    def _pre_embed_with_db(self):
        sequence_file_path = self.config_dict['sequence_file']

        embedder_name = self.config_dict['embedder_name']
        protocol = self.config_dict['protocol']
        device = self.config_dict.get('device', None)
        output_path = self.config_path.parent / "embeddings.h5"

        with tempfile.TemporaryDirectory() as temp_embeddings_dir:
            # TODO [Refactoring] Consider moving temporary directory to embedding task directly
            temp_embeddings_path = Path(temp_embeddings_dir)
            embedding_task = EmbeddingTask(embedder_name=embedder_name,
                                           sequence_file_path=sequence_file_path,
                                           embeddings_out_path=temp_embeddings_path,
                                           protocol=protocol,
                                           use_half_precision=False,
                                           device=device)
            embedding_dto: TaskDTO
            for current_dto in self.run_subtask(embedding_task):
                embedding_dto = current_dto

            embeddings_task_result = embedding_dto.update["embeddings_file"][embedder_name]
            # TODO [Optimization] Try to avoid double reading and saving of embedding files
            EmbeddingsDatabase.export_embeddings_task_result_to_hdf5(embeddings_task_result=embeddings_task_result,
                                                                     output_path=output_path)
        self.config_dict.pop("embedder_name")
        self.config_dict["embeddings_file"] = str(output_path)

        # TODO Enable biotrainer to accept a dict
        config_file_yaml = yaml.dump(self.config_dict)
        with open(self.config_path, "w") as config_file:
            config_file.write(config_file_yaml)
