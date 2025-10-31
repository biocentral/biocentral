from tqdm import tqdm
from typing import List
from abc import ABC, abstractmethod

from ..._generated import TaskStatusResponse, TaskDTO


class DTOHandler(ABC):
    @abstractmethod
    def handle(self, dtos: List[TaskDTO]):
        pass

    @abstractmethod
    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        return pbar  # Don't update by default