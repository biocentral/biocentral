from __future__ import annotations

from enum import Enum
from dataclasses import dataclass
from abc import ABC, abstractmethod
from typing import Any, Dict, Callable, Generator

from .task_utils import run_subtask_util


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

    def add_update(self, update: Dict[str, Any]) -> TaskDTO:
        return TaskDTO(status=self.status, error=self.error, update=update)

    def dict(self):
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
