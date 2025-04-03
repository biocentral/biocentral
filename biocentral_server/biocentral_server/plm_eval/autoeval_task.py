import logging
from pathlib import Path

from ruamel import yaml
from importlib import resources
from collections import namedtuple
from typing import Dict, Any, Optional, Callable

from ..prediction_models import BiotrainerTask
from ..server_management import TaskInterface, FileManager, StorageFileType, TaskDTO, EmbeddingDatabaseFactory

logger = logging.getLogger(__name__)

_DatasetTuple = namedtuple("_DatasetTuple", ["dataset_name", "split_name"])


def _task_name(dataset_tuple: _DatasetTuple):
    return f"{dataset_tuple.dataset_name}-{dataset_tuple.split_name}"


class AutoEvalTask(TaskInterface):

    def __init__(self, flip_dict: dict, embedder_name: str, user_id: str,
                 onnx_path: Optional[str] = None,
                 tokenizer_config_path: Optional[str] = None):
        self.flip_dict = flip_dict
        self.embedder_name = embedder_name
        self.file_manager = FileManager(user_id=user_id)
        self.onnx_path = onnx_path
        self.tokenizer_config_path = tokenizer_config_path

        self.task_queue = []
        self.completed_tasks = 0
        self.current_dataset: Optional[_DatasetTuple] = None
        self.total_tasks = sum(len(dataset_dict['splits']) for dataset_dict in flip_dict.values())

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        for dataset_name, dataset_dict in self.flip_dict.items():
            for split in dataset_dict['splits']:
                self.task_queue.append((dataset_name, split))

        self.task_queue = sorted(self.task_queue, key=lambda x: x[0])
        self._process_queue(update_dto_callback)

        self._post_task_cleanup()

        return TaskDTO.finished(
            result=self._create_dto_update(current_task_dto=TaskDTO.finished(result={}), task_config={}))

    def _process_queue(self, update_dto_callback):
        while self.task_queue:
            dataset_name, split = self.task_queue.pop(0)
            self._run_biotrainer_subtask(dataset_name, split, update_dto_callback)
            self.completed_tasks += 1
            logger.info(f"[AUTOEVAL] Process for {dataset_name} - split {split['name']} has finished!")
            logger.info(f"[AUTOEVAL] Progress information: {self.completed_tasks}/{self.total_tasks}")

    def _run_biotrainer_subtask(self, dataset_name: str, split: Dict, update_dto_callback):
        config = self._prepare_config(dataset_name, split)
        split_name = split['name']
        embedder_path_name = self.embedder_name.replace("/", "_")

        # TODO TASK ID: Do we need a model hash here?
        model_hash = f"autoeval_{embedder_path_name}_{dataset_name}_{split_name}"
        model_path = self.file_manager.get_biotrainer_model_path(model_hash)

        biotrainer_task = BiotrainerTask(model_path=model_path, config_dict=config)
        self.current_dataset = _DatasetTuple(dataset_name, split_name)
        logger.info(f"[AUTOEVAL] Starting process for dataset {dataset_name} - split {split_name}!")
        biotrainer_dto: TaskDTO
        for current_dto in self.run_subtask(biotrainer_task):
            biotrainer_dto = current_dto
            dto_update = self._create_dto_update(current_task_dto=biotrainer_dto, task_config=config)
            update_dto_callback(TaskDTO.running().add_update(dto_update))

    def _prepare_config(self, dataset_name: str, split: Dict):
        with resources.open_text('autoeval.configsbank', f'{dataset_name}.yml') as config_file:
            config = yaml.load(config_file, Loader=yaml.Loader)

        # Subcellular localization is SOTA LightAttention, i.e. residues_to_class
        # But here we are using per-sequence embeddings for now because of much smaller storage and faster computation
        if dataset_name == "scl":
            config["protocol"] = "sequence_to_class"
            config["model_choice"] = "FNN"

        if self.onnx_path and self.tokenizer_config_path:
            config["embedder_name"] = self.onnx_path
            config["custom_tokenizer_config"] = self.tokenizer_config_path
        else:
            config["embedder_name"] = self.embedder_name

        for file_name, file_path in split.items():
            if file_name == "name":
                continue
            if file_path is not None:
                config[file_name] = file_path
        return config

    def _create_dto_update(self, current_task_dto: TaskDTO, task_config: dict) -> Dict[str, Any]:
        update_dict = {
            'completed_tasks': self.completed_tasks,
            'embedder_name': self.embedder_name,
            'total_tasks': self.total_tasks,
            'current_task': _task_name(self.current_dataset) if self.current_dataset else "",
            'current_task_config': task_config,
            'current_task_dto': current_task_dto.dict()
        }
        return update_dict

    def _post_task_cleanup(self):
        # Delete onnx embeddings and model because they should not be stored permanently
        if self.onnx_path:
            logger.info(f"Deleting {self.embedder_name} related embeddings and files..")
            embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
            embeddings_db.delete_embeddings_by_model(embedder_name=self.onnx_path)
            self.file_manager.delete_file(file_type=StorageFileType.ONNX_MODEL,
                                          embedder_name=self.embedder_name)
            self.file_manager.delete_file(file_type=StorageFileType.TOKENIZER_CONFIG,
                                          embedder_name=self.embedder_name)
