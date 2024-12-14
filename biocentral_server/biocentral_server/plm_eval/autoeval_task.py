import yaml
import logging

from pathlib import Path
from typing import Dict, Any, Optional, Callable
from importlib import resources
from collections import namedtuple

from ..prediction_models import BiotrainerTask
from ..server_management import TaskInterface, TaskStatus, FileManager, StorageFileType, EmbeddingsDatabase, TaskDTO

logger = logging.getLogger(__name__)

_DatasetTuple = namedtuple("_DatasetTuple", ["dataset_name", "split_name"])


def _task_name(dataset_tuple: _DatasetTuple):
    return f"{dataset_tuple.dataset_name}-{dataset_tuple.split_name}"


class AutoEvalTask(TaskInterface):

    def __init__(self, flip_dict: dict, embedder_name: str, user_id: str, embeddings_db_instance: EmbeddingsDatabase):
        self.flip_dict = flip_dict
        self.embedder_name = embedder_name
        self.file_manager = FileManager(user_id=user_id)
        self.embeddings_db_instance = embeddings_db_instance

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
        database_hash = f"autoeval_{embedder_path_name}_{dataset_name}_{split_name}"

        # TODO TASK ID
        model_hash = str(hash(str(config)))
        config_path = self._save_config(config, database_hash=database_hash, model_hash=model_hash)
        log_path = self.file_manager.get_file_path(database_hash=database_hash,
                                                   file_type=StorageFileType.BIOTRAINER_LOGGING,
                                                   model_hash=model_hash, check_exists=False)

        biotrainer_task = BiotrainerTask(config_path=config_path, config_dict=config,
                                         database_instance=self.embeddings_db_instance,
                                         log_path=log_path)
        self.current_dataset = _DatasetTuple(dataset_name, split_name)
        logger.info(f"[AUTOEVAL] Starting process for dataset {dataset_name} - split {split_name}!")
        biotrainer_dto: TaskDTO
        for current_dto in self.run_subtask(biotrainer_task):
            biotrainer_dto = current_dto
            dto_update = self._create_dto_update(current_task_dto=biotrainer_dto, task_config=config)
            update_dto_callback(TaskDTO.running().add_update(dto_update))

    def _prepare_config(self, dataset_name: str, split: Dict):
        with resources.open_text('autoeval.configsbank', f'{dataset_name}.yml') as config_file:
            config = yaml.load(config_file, Loader=yaml.FullLoader)

        config["embedder_name"] = self.embedder_name

        for file_name, file_path in split.items():
            if file_name == "name":
                continue
            if file_path is not None:
                config[file_name] = file_path
        return config

    def _save_config(self, config: dict, database_hash: str, model_hash: str) -> Path:
        config_file_path = self.file_manager.get_file_path(database_hash=database_hash,
                                                           file_type=StorageFileType.BIOTRAINER_CONFIG,
                                                           model_hash=model_hash, check_exists=False)
        config["output_dir"] = str(config_file_path.parent.absolute())
        config_file_yaml = yaml.dump(config)
        config_file_path = self.file_manager.save_file(database_hash=database_hash,
                                                       file_type=StorageFileType.BIOTRAINER_CONFIG,
                                                       file_content=config_file_yaml, model_hash=model_hash)
        return config_file_path

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
