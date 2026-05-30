from typing import Callable
from biotrainer_core.data_classes import BiotrainerModelUpdate
from biotrainer.training.output_files import BiotrainerOutputObserver

from ..task_management import TaskDTO, TaskStatus


class TrainingDTOObserver(BiotrainerOutputObserver):
    def __init__(self, update_dto_callback: Callable):
        self.update_dto_callback = update_dto_callback

    def update(self, data: BiotrainerModelUpdate) -> None:
        dto = TaskDTO(status=TaskStatus.RUNNING, biotrainer_update=data)
        self.update_dto_callback(dto)

    def close(self) -> None:
        pass
