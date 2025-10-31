import os

from collections import namedtuple
from biotrainer.trainers import Pipeline
from biotrainer.utilities import get_device
from typing import Optional, Callable
from biotrainer.embedders import get_predefined_embedder_names
from biotrainer.autoeval import autoeval_pipeline, get_unique_framework_sequences

from ..utils import get_logger
from ..embeddings import CalculateEmbeddingsTask
from ..server_management import (
    TaskInterface,
    FileManager,
    StorageFileType,
    TaskDTO,
    EmbeddingDatabaseFactory,
    FileContextManager,
    get_custom_training_pipeline_loading,
    get_custom_training_pipeline_memory,
    TrainingDTOObserver,
    TaskStatus,
)

logger = get_logger(__name__)

_DatasetTuple = namedtuple("_DatasetTuple", ["dataset_name", "split_name"])


def _task_name(dataset_tuple: _DatasetTuple):
    return f"{dataset_tuple.dataset_name}-{dataset_tuple.split_name}"


class AutoEvalTask(TaskInterface):
    MIN_SEQ_LENGTH = 0
    MAX_SEQ_LENGTH = 2000
    FRAMEWORK = "pbc"

    def __init__(
        self,
        embedder_name: str,
        user_id: str,
        onnx_path: Optional[str] = None,
        tokenizer_config_path: Optional[str] = None,
    ):
        self.embedder_name = embedder_name
        self.file_manager = FileManager(user_id=user_id)
        self.onnx_path = onnx_path
        self.tokenizer_config = tokenizer_config_path

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        update_dto_callback(
            TaskDTO(status=TaskStatus.RUNNING, embedder_name=self.embedder_name)
        )

        autoeval_path = self.file_manager.get_autoeval_path(
            embedder_name=self.embedder_name
        )
        custom_pipeline = self._get_pipeline(update_dto_callback)
        custom_observer = TrainingDTOObserver(update_dto_callback)
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
                update_dto_callback(
                    TaskDTO(status=TaskStatus.RUNNING, autoeval_progress=progress)
                )

        self._post_task_cleanup()

        return TaskDTO(status=TaskStatus.FINISHED, autoeval_progress=progress)

    def _get_pipeline(self, update_dto_callback: Callable) -> Pipeline:
        if self.embedder_name in get_predefined_embedder_names():
            return get_custom_training_pipeline_memory(embedder_name=self.embedder_name)
        else:
            self._embed_all(update_dto_callback)
            embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
            return get_custom_training_pipeline_loading(
                embedder_name=self.embedder_name, embeddings_db=embeddings_db
            )

    def _embed_all(self, update_dto_callback: Callable) -> Optional[TaskDTO]:
        _, unique_per_residue, unique_per_sequence = get_unique_framework_sequences(
            framework=self.FRAMEWORK,
            min_seq_length=self.MIN_SEQ_LENGTH,
            max_seq_length=self.MAX_SEQ_LENGTH,
        )
        for name, reduced, seq_dict in [
            ("per_residue", False, unique_per_residue),
            ("per_sequence", True, unique_per_sequence),
        ]:
            calculate_task = CalculateEmbeddingsTask(
                embedder_name=self.embedder_name,
                sequence_input=list(seq_dict.values()),
                reduced=reduced,
                use_half_precision=False,
                device=get_device(),
                custom_tokenizer_config=self.tokenizer_config,
            )
            calculate_dto = None
            for dto in self.run_subtask(calculate_task):
                calculate_dto = dto
                if calculate_dto.embedding_current is not None:
                    update_dto_callback(calculate_dto)

            if not calculate_dto or calculate_dto.embedded_sequences is None:
                return TaskDTO(
                    status=TaskStatus.FAILED,
                    error=f"Calculating of embeddings {name} failed before autoeval!",
                )

    def _post_task_cleanup(self):
        # Delete onnx embeddings and model because they should not be stored permanently
        if self.onnx_path:
            logger.info(f"Deleting {self.embedder_name} related embeddings and files..")
            embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
            embeddings_db.delete_embeddings_by_model(embedder_name=self.onnx_path)
            self.file_manager.delete_file(
                file_type=StorageFileType.ONNX_MODEL, embedder_name=self.embedder_name
            )
            self.file_manager.delete_file(
                file_type=StorageFileType.TOKENIZER_CONFIG,
                embedder_name=self.embedder_name,
            )
