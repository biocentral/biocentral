import yaml
import logging
import asyncio

from pathlib import Path
from typing import Dict, Any, Optional
from importlib import resources
from collections import namedtuple

from ..prediction_models import BiotrainerProcess
from ..server_management import TaskInterface, TaskStatus, FileManager, StorageFileType

logger = logging.getLogger(__name__)

_ProcessTuple = namedtuple("_ProcessTuple", ["process", "dataset_name", "split_name"])


class AutoEvalTask(TaskInterface):

    def __init__(self, flip_dict, embedder_name: str, user_id):
        self.flip_dict = flip_dict
        self.embedder_name = embedder_name
        self.file_manager = FileManager(user_id=user_id)
        self.current_dataset = None
        self.current_split = None
        self.total_tasks = 1  # TODO sum(len(dataset_dict['splits']) for dataset_dict in flip_dict.values())
        self.completed_tasks = 0
        self.task_queue = []
        self.results = {}
        self.status = TaskStatus.RUNNING
        self.current_process: Optional[_ProcessTuple]

    async def start(self):
        for dataset_name, dataset_dict in self.flip_dict.items():
            for split in dataset_dict['splits']:
                self.task_queue.append((dataset_name, split))

        await self._process_queue()

    async def _process_queue(self):
        while self.task_queue:
            dataset_name, split = self.task_queue.pop(0)
            await self._start_biotrainer_process(dataset_name, split)
            await self._await_process_completion()
            logger.info(f"[AUTOEVAL] Process for {dataset_name} - split {split['name']} has finished!")

        self.status = TaskStatus.FINISHED

    async def _start_biotrainer_process(self, dataset_name, split):
        config = self._prepare_config(dataset_name, split)
        embedder_path_name = self.embedder_name.replace("/", "_")
        database_hash = f"autoeval_{embedder_path_name}_{dataset_name}_{split['name']}"
        model_hash = str(hash(str(config)))
        config_path = self._save_config(config, database_hash=database_hash, model_hash=model_hash)
        log_path = self.file_manager.get_file_path(database_hash=database_hash,
                                                   file_type=StorageFileType.BIOTRAINER_LOGGING,
                                                   model_hash=model_hash, check_exists=False)
        # TODO [Optimization] Embed sequence file for some splits before training

        # TODO [Optimization] Sub-Process handling via process manager
        biotrainer_process = BiotrainerProcess(config_path, log_path)
        self.current_process = _ProcessTuple(biotrainer_process, dataset_name, split)
        logger.info(f"[AUTOEVAL] Starting process for dataset {dataset_name} - split {split['name']}!")
        await biotrainer_process.start()

    def _prepare_config(self, dataset_name: str, split: dict):
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
        config_file_yaml = yaml.dump(config)
        config_file_path = self.file_manager.save_file(database_hash=database_hash,
                                                       file_type=StorageFileType.BIOTRAINER_CONFIG,
                                                       file_content=config_file_yaml, model_hash=model_hash)
        return config_file_path

    async def _await_process_completion(self):
        while self.current_process.process.get_task_status() == TaskStatus.RUNNING:
            await asyncio.sleep(5)  # Check every 5 seconds

        result = self.current_process.process.update()
        self.results[f"{self.current_process.dataset_name}_{self.current_process.split_name}"] = result
        self.completed_tasks += 1
        self.current_process = None

    def get_task_status(self) -> TaskStatus:
        return self.status

    def update(self) -> Dict[str, Any]:
        progress_info = f"{self.completed_tasks}/{self.total_tasks}"
        logger.info(f"[AUTOEVAL] Progress information: {progress_info}")
        update_dict = {
            'status': self.status.name,
            'progress': progress_info,
            'current_process': f"{self.current_process.dataset_name}_"
                               f"{self.current_process.split_name}" if self.current_process else "",
            'results': self.results
        }
        return update_dict
