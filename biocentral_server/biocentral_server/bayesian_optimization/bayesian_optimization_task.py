import tempfile
import time
import torch.multiprocessing as mp
from pathlib import Path
from typing import Dict, Callable
from biotrainer.protocols import Protocol
import yaml
from .botraining import SUPPORTED_MODELS, pipeline

from ..embeddings import EmbeddingTask
from ..server_management import TaskInterface, EmbeddingsDatabase, TaskDTO

"""
BOtraining process wrapper
- init: store all process arguments
- run_task: launch process and wait until process exit
"""


class BayesTask(TaskInterface):
    SUPPORTED_MODELS = SUPPORTED_MODELS
    def __init__(self, config_dict: Dict, database_instance: EmbeddingsDatabase):
        super().__init__()
        self.config_dict = config_dict
        self.database_instance = database_instance
        self.output_dir = Path(config_dict["output_dir"])
        if not self.output_dir.exists():
            self.output_dir.mkdir(parents=True)
        # print(f"path: {str(self.output_dir / 'config.yaml')}")

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        self._pre_embed_with_db()
        print("finish embedding task")
        self.biotrainer_process = mp.Process(
            target=pipeline, args=(str(self.output_dir / "config.yaml"), "", False) 
            # set to True when input data have no inference data
        )
        self.biotrainer_process.start()
        # TODO: allow progress report?
        while self.biotrainer_process.is_alive():
            time.sleep(1)
        return TaskDTO.finished({})

    def _pre_embed_with_db(self):
        sequence_file_path = self.config_dict["sequence_file"]
        embedder_name = self.config_dict.get("embedder_name", "one_hot_encoding")
        print(f"embedder: {embedder_name}")
        if 'embedder_name' in self.config_dict.keys():
            self.config_dict.pop("embedder_name")
        protocol = Protocol.sequence_to_class  # per sequence protocol should be fine
        device = self.config_dict.get("device", None)
        output_path = self.output_dir / "embeddings.h5"
        with tempfile.TemporaryDirectory() as temp_embeddings_dir:
            temp_embeddings_path = Path(temp_embeddings_dir)
            embedding_task = EmbeddingTask(
                embedder_name=embedder_name,
                sequence_file_path=sequence_file_path,
                embeddings_out_path=temp_embeddings_path,
                protocol=protocol,
                use_half_precision=False,
                device=device,
                embeddings_database=self.database_instance,
            )
            embedding_dto: TaskDTO
            for current_dto in self.run_subtask(embedding_task):
                embedding_dto = current_dto

            embeddings_task_result: Dict = embedding_dto.update["embeddings_file"][
                embedder_name
            ]

            # TODO [Optimization] Try to avoid double reading and saving of embedding files
            EmbeddingsDatabase.export_embeddings_task_result_to_hdf5(
                embeddings_task_result=embeddings_task_result, output_path=output_path
            )
        self.config_dict["embeddings_file"] = str(output_path)
        self.export_dict()

    def export_dict(self):
        config_file_yaml = yaml.dump(self.config_dict)
        config_path = self.output_dir / "config.yaml"
        with open(config_path, "w") as config_file:
            config_file.write(config_file_yaml)
