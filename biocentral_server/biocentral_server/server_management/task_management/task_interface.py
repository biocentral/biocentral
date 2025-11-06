from __future__ import annotations

from enum import Enum

from abc import ABC, abstractmethod
from pydantic import BaseModel, ConfigDict
from biotrainer.output_files import OutputData
from biotrainer.autoeval import AutoEvalProgress
from biotrainer.input_files import BiotrainerSequenceRecord
from typing import Any, Dict, Callable, Generator, Optional, List

from .task_utils import run_subtask_util

from ..shared_endpoint_models import Prediction


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

    """ Fat-struct that contains all possible (intermediate) results from tasks """
    status: TaskStatus
    error: Optional[str] = None

    # predict/inference
    predictions: Optional[Dict[str, List[Prediction]]] = None  # seq_id -> predictions

    # custom_models
    # TODO Pydantic class
    biotrainer_update: Optional[OutputData] = None
    biotrainer_result: Optional[Dict[str, Any]] = None

    # embeddings
    embedding_current: Optional[int] = None
    embedding_total: Optional[int] = None
    embedded_sequences: Optional[Dict[str, str]] = None
    embeddings: Optional[List[BiotrainerSequenceRecord]] = None
    embeddings_file: Optional[str] = None

    # plm_eval
    embedder_name: Optional[str] = None
    autoeval_progress: Optional[AutoEvalProgress] = None

    # bay_opt
    bay_opt_results: Optional[List] = None

    def model_dump_json(self, **kwargs) -> str:
        """Serialize to JSON excluding None values"""
        kwargs["exclude_none"] = True
        return super().model_dump_json(**kwargs)

    def model_dump(self, **kwargs) -> Dict[str, Any]:
        """Serialize to dict excluding None values"""
        kwargs["exclude_none"] = True
        return super().model_dump(**kwargs)


class TaskInterface(ABC):
    @abstractmethod
    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        pass

    @staticmethod
    def run_subtask(subtask: TaskInterface) -> Generator[TaskDTO, None, None]:
        yield from run_subtask_util(subtask=subtask)
