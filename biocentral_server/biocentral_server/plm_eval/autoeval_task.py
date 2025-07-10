import os

from collections import namedtuple
from biotrainer.trainers import Pipeline
from biotrainer.utilities import get_device
from typing import Dict, Any, Optional, Callable
from biotrainer.embedders import get_predefined_embedder_names
from biotrainer.autoeval import autoeval_pipeline, get_unique_framework_sequences

from ..utils import get_logger
from ..embeddings import CalculateEmbeddingsTask
from ..server_management import (TaskInterface, FileManager, StorageFileType, TaskDTO, EmbeddingDatabaseFactory,
                                 FileContextManager, get_custom_training_pipeline_loading,
                                 get_custom_training_pipeline_memory, TrainingDTOObserver)

logger = get_logger(__name__)

_DatasetTuple = namedtuple("_DatasetTuple", ["dataset_name", "split_name"])


def _task_name(dataset_tuple: _DatasetTuple):
    return f"{dataset_tuple.dataset_name}-{dataset_tuple.split_name}"


class AutoEvalTask(TaskInterface):
    MIN_SEQ_LENGTH = 0
    MAX_SEQ_LENGTH = 2000
    FRAMEWORK = "flip"

    def __init__(self, embedder_name: str, user_id: str, onnx_path: Optional[str] = None,
                 tokenizer_config_path: Optional[str] = None):
        self.embedder_name = embedder_name
        self.file_manager = FileManager(user_id=user_id)
        self.onnx_path = onnx_path
        self.tokenizer_config = tokenizer_config_path

    @staticmethod
    def _wrap_dto_callback(update_dto_callback):
        def dto_wrapper(dto):
            update_dto_callback(TaskDTO.running().add_update(update={"prediction_model": dto.update}))

        return lambda dto: dto_wrapper(dto)

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        update_dto_callback(TaskDTO.running().add_update(update={"embedder_name": self.embedder_name}))

        autoeval_path = self.file_manager.get_autoeval_path(embedder_name=self.embedder_name)
        custom_pipeline = self._get_pipeline(update_dto_callback)
        custom_observer = TrainingDTOObserver(self._wrap_dto_callback(update_dto_callback))
        custom_storage_path = os.environ.get("AUTOEVAL_DATA_DIR", None)
        file_context_manager = FileContextManager()
        with file_context_manager.storage_write(autoeval_path) as output_dir:
            for progress in autoeval_pipeline(
                    embedder_name=self.embedder_name,
                    framework=self.FRAMEWORK,
                    output_dir=output_dir,
                    use_half_precision=False,
                    min_seq_length=self.MIN_SEQ_LENGTH,
                    max_seq_length=self.MAX_SEQ_LENGTH,
                    custom_pipeline=custom_pipeline,
                    custom_output_observers=[custom_observer],
                    custom_storage_path=custom_storage_path,
            ):
                update_dto_callback(TaskDTO.running().add_update({"completed_tasks": progress.completed_tasks,
                                                                  "total_tasks": progress.total_tasks,
                                                                  "current_task_name": progress.current_task_name,
                                                                  "current_framework_name": progress.current_framework_name,
                                                                  }))

        self._post_task_cleanup()

        return TaskDTO.finished(result=progress.final_report)

    def _get_pipeline(self, update_dto_callback: Callable) -> Pipeline:
        if self.embedder_name in get_predefined_embedder_names():
            return get_custom_training_pipeline_memory(embedder_name=self.embedder_name)
        else:
            self._embed_all(update_dto_callback)
            embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
            return get_custom_training_pipeline_loading(embedder_name=self.embedder_name,
                                                        embeddings_db=embeddings_db)

    def _embed_all(self, update_dto_callback: Callable):
        _, unique_per_residue, unique_per_sequence = get_unique_framework_sequences(framework=self.FRAMEWORK,
                                                                                    min_seq_length=self.MIN_SEQ_LENGTH,
                                                                                    max_seq_length=self.MAX_SEQ_LENGTH)
        for name, reduced, seq_dict in [("per_residue", False, unique_per_residue),
                                        ("per_sequence", True, unique_per_sequence)]:

            calculate_task = CalculateEmbeddingsTask(embedder_name=self.embedder_name,
                                                     sequence_input=list(seq_dict.values()),
                                                     reduced=reduced,
                                                     use_half_precision=False,
                                                     device=get_device(),
                                                     custom_tokenizer_config=self.tokenizer_config)
            calculate_dto = None
            for dto in self.run_subtask(calculate_task):
                calculate_dto = dto
                if "embedding_current" in calculate_dto.update:
                    update_dto_callback(calculate_dto)

            if not calculate_dto or "all_seqs" not in calculate_dto.update:
                error = f"Calculating of embeddings {name} failed before autoeval!"
                update_dto_callback(TaskDTO.failed(error=error))
                raise Exception(error)

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


"""
class _OLDAutoEvalTask(TaskInterface):

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
"""
