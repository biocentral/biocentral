from tqdm import tqdm
from typing import List, Optional
from abc import ABC, abstractmethod

from ..._generated import TaskStatusResponse, TaskDTO, TaskStatus


class DTOHandler(ABC):
    def handle_failure(self, dtos: List[TaskDTO]) -> Optional[str]:
        for dto in dtos:
            if dto.status == TaskStatus.FAILED:
                return dto.error if dto.error else "Task failed with unknown error"
        return None

    @abstractmethod
    def handle_result(self, dtos: List[TaskDTO]):
        pass

    @abstractmethod
    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        return pbar  # Don't update by default