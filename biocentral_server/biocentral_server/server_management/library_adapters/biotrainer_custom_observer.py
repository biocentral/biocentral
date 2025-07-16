from typing import Callable
from biotrainer.output_files import BiotrainerOutputObserver
from biotrainer.output_files.biotrainer_output_observer import OutputData

from ..task_management import TaskDTO


class TrainingDTOObserver(BiotrainerOutputObserver):
    def __init__(self, update_dto_callback: Callable):
        self.update_dto_callback = update_dto_callback

    def update(self, data: OutputData) -> None:
        if data.config:
            dto = TaskDTO.running().add_update(update={"config": data.config})
            self.update_dto_callback(dto)

        if data.derived_values:
            dto = TaskDTO.running().add_update(
                update={"derived_values": data.derived_values}
            )
            self.update_dto_callback(dto)

        if data.training_iteration:
            split_name, metrics = data.training_iteration
            dto = TaskDTO.running().add_update(
                update={
                    "training_iteration": {"split_name": split_name, "metrics": metrics}
                }
            )
            self.update_dto_callback(dto)

        if data.test_results:
            dto = TaskDTO.running().add_update(
                update={"test_results": data.test_results}
            )
            self.update_dto_callback(dto)

        if data.split_specific_values:
            dto = TaskDTO.running().add_update(
                update={"split_specific_values": data.split_specific_values}
            )
            self.update_dto_callback(dto)

    def close(self) -> None:
        pass
