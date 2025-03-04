import time
from typing import Generator


def run_subtask_util(subtask) -> Generator:
    # Separated to task_utils because of circular import
    from .task_manager import TaskManager
    task_manager = TaskManager()
    subtask_id = task_manager.add_subtask(subtask)
    while not task_manager.is_task_finished(subtask_id):
        time.sleep(1)
        task_dtos = task_manager.get_all_task_updates(subtask_id)
        for task_dto in task_dtos:
            yield task_dto

    # Get remaining updates
    remaining_task_dtos = task_manager.get_all_task_updates(subtask_id)
    for task_dto in remaining_task_dtos:
        yield task_dto