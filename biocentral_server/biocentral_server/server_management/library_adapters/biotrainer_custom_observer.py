from typing import Callable
from biotrainer.output_files import BiotrainerOutputObserver
from biotrainer.output_files.biotrainer_output_observer import OutputData

from .. import TaskStatus
from ..task_management import TaskDTO


class TrainingDTOObserver(BiotrainerOutputObserver):
    def __init__(self, update_dto_callback: Callable):
        self.update_dto_callback = update_dto_callback

    def update(self, data: OutputData) -> None:
        dto = TaskDTO(status=TaskStatus.RUNNING, biotrainer_update=data)
        self.update_dto_callback(dto)

    def close(self) -> None:
        pass
