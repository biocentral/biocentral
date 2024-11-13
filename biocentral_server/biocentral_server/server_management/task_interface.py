import asyncio

from enum import Enum
from typing import Dict, Any
from abc import ABC, abstractmethod


class TaskStatus(Enum):
    RUNNING = 1
    FINISHED = 2
    FAILED = 3


class TaskInterface(ABC):
    @abstractmethod
    async def start(self):
        raise NotImplementedError

    @abstractmethod
    def get_task_status(self) -> TaskStatus:
        raise NotImplementedError

    @abstractmethod
    def update(self) -> Dict[str, Any]:
        raise NotImplementedError
