from __future__ import annotations

from enum import Enum

from abc import ABC, abstractmethod
from pydantic import BaseModel, ConfigDict
from biotrainer_core.data_classes import (
    SequenceData,
    BiotrainerModelUpdate,
    BiotrainerModelResult,
    BiotrainerInferenceResult,
)

from typing import Any, Dict, Callable, Generator, Optional, List, Tuple

from .task_utils import run_subtask_util

from ..shared_endpoint_models import (
    Prediction,
    ActiveLearningIterationResult,
    ActiveLearningScreeningSimulationResult,
    EmbeddingProgress,
    ProjectionResult,
)

from ...utils import get_logger

logger = get_logger(__name__)


class TaskStatus(str, Enum):
    PENDING = "PENDING"
    RUNNING = "RUNNING"
    FINISHED = "FINISHED"
    FAILED = "FAILED"

    @staticmethod
    def from_string(status: str) -> TaskStatus:
        return TaskStatus(status.upper())


class TaskDTO(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)

    @classmethod
    def errored(cls, error: str):
        logger.error(f"TaskDTO - Failed: {error}")
        return cls(status=TaskStatus.FAILED, error=error)

    """ Fat-struct that contains all possible (intermediate) results from tasks """
    status: TaskStatus
    error: Optional[str] = None

    # predict
    predictions: Optional[Dict[str, List[Prediction]]] = None  # seq_id -> predictions

    # custom_models
    biotrainer_update: Optional[BiotrainerModelUpdate] = None
    biotrainer_result: Optional[BiotrainerModelResult] = None
    biotrainer_inference_result: Optional[BiotrainerInferenceResult] = None

    # embeddings
    embedding_progress: Optional[EmbeddingProgress] = None
    embedded_sequences: Optional[Dict[str, str]] = None
    embeddings: Optional[List[SequenceData]] = None
    embeddings_file: Optional[str] = None

    #clustering
    clustered_data: Optional[Dict[str, List[str]]] = None

    # projections
    projection_result: Optional[ProjectionResult] = None

    # active_learning
    al_iteration_result: Optional[ActiveLearningIterationResult] = None
    al_simulation_result: Optional[ActiveLearningScreeningSimulationResult] = None


class TaskInterface(ABC):
    @abstractmethod
    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        pass

    @staticmethod
    def run_subtask(subtask: TaskInterface) -> Generator[TaskDTO, None, None]:
        yield from run_subtask_util(subtask=subtask)


class PreEmbedMixin:
    def _pre_embed_with_db(
        self,
        embedder_name: str,
        sequence_input: List[SequenceData],
        reduced: bool,
        update_dto_callback: Optional[Callable] = None,
        custom_tokenizer_config: Optional[Dict[str, Any]] = None,
    ) -> Tuple[Optional[TaskDTO], List[SequenceData]]:
        from ...embeddings import (
            LoadEmbeddingsTask,
        )  # Local import to avoid circular dependency

        load_embeddings_task = LoadEmbeddingsTask(
            embedder_name=embedder_name,
            sequence_input=sequence_input,
            reduced=reduced,
            use_half_precision=False,
            custom_tokenizer_config=custom_tokenizer_config,
        )
        load_dto = None
        # TaskInterface is expected to be a base class of any class using this mixin
        for current_dto in self.run_subtask(load_embeddings_task):  # type: ignore
            load_dto = current_dto
            if update_dto_callback and load_dto.embedding_progress is not None:
                update_dto_callback(load_dto)

        if not load_dto:
            return TaskDTO.errored("Could not compute embeddings!"), []

        embeddings: List[SequenceData] = load_dto.embeddings
        if embeddings is None or len(embeddings) == 0:
            return TaskDTO.errored("Did not receive embeddings for training!"), []

        if len(embeddings) != len(sequence_input):
            return TaskDTO.errored(
                f"Number of embeddings ({len(embeddings)}) does not match "
                f"number of input sequences ({len(sequence_input)})!"
            ), []

        return None, embeddings
