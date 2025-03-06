from __future__ import annotations

from enum import Enum
from pathlib import Path
from dataclasses import dataclass
from abc import ABC, abstractmethod
from typing import Any, Dict, Callable, Generator, Optional

from .task_utils import run_subtask_util

from ..file_management import FileContextManager
from ..embedding_database import EmbeddingsDatabase


class TaskStatus(Enum):
    PENDING = 0
    RUNNING = 1
    FINISHED = 2
    FAILED = 3

    @staticmethod
    def _all():
        return [TaskStatus.PENDING, TaskStatus.RUNNING, TaskStatus.FINISHED, TaskStatus.FAILED]

    @staticmethod
    def from_string(status: str) -> TaskStatus:
        return {s.name: s for s in TaskStatus._all()}[status.upper()]

@dataclass
class TaskDTO:
    status: TaskStatus
    error: str
    update: Dict[str, Any]

    @classmethod
    def pending(cls):
        return TaskDTO(status=TaskStatus.PENDING, error="", update={})

    @classmethod
    def running(cls):
        return TaskDTO(status=TaskStatus.RUNNING, error="", update={})

    @classmethod
    def finished(cls, result: Dict[str, Any]):
        return TaskDTO(
            status=TaskStatus.FINISHED,
            error="",
            update=result,
        )

    @classmethod
    def failed(cls, error: str):
        return TaskDTO(status=TaskStatus.FAILED, error=error, update={})

    def add_update(self, update: Dict[str, Any]) -> 'TaskDTO':
        return TaskDTO(status=self.status, error=self.error, update=update)

    def finished_task_postprocessing(self):
        # TODO This could be improved architecturally to be registered by the embedding module as a hook
        if "embeddings_file" in self.update.keys() and self.update["embeddings_file"] is not None:
            embeddings_path = Path(self.update["embeddings_file"])
            file_context_manager = FileContextManager()
            with file_context_manager.storage_read(embeddings_path) as embeddings_file:
                h5_string = EmbeddingsDatabase.h5_file_to_base64(h5_file_path=embeddings_file)
                self.update["embeddings_file"] = h5_string

    def dict(self):
        if self.status == TaskStatus.FINISHED:
            self.finished_task_postprocessing()

        return {"status": self.status.name, "error": self.error, **self.update}

    def __getstate__(self):
        """Called when pickling - return a serializable state"""
        return {
            'status': self.status.name,
            'error': self.error,
            'update': self.update,
        }

    def __setstate__(self, state):
        """Called when unpickling - restore from serializable state"""
        self.status = TaskStatus.from_string(state['status'])
        self.error = state['error']
        self.update = state['update']


class TaskInterface(ABC):
    @abstractmethod
    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        pass

    @staticmethod
    def run_subtask(subtask: TaskInterface) -> Generator[TaskDTO, None, None]:
        yield from run_subtask_util(subtask=subtask)
