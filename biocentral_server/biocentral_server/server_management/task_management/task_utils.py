import time
import threading

from typing import Generator


def _run_subtask_util_task_manager(subtask) -> Generator:
    # Separated to task_utils because of circular import
    from .task_manager import TaskManager

    task_manager = TaskManager()
    subtask_id = task_manager.add_subtask(subtask)
    while not task_manager.is_task_finished(subtask_id):
        time.sleep(1)
        task_dtos = task_manager.get_new_task_updates(subtask_id)
        for task_dto in task_dtos:
            yield task_dto

    # Get remaining updates
    remaining_task_dtos = task_manager.get_new_task_updates(subtask_id)
    for task_dto in remaining_task_dtos:
        yield task_dto


def run_subtask_util(subtask) -> Generator:
    updates = []
    task_result = []

    def callback(dto):
        updates.append(dto)

    def _run_task():
        result = subtask.run_task(callback)
        task_result.append(result)

    # Run in thread to avoid blocking
    thread = threading.Thread(target=lambda: _run_task(), daemon=True)
    thread.start()

    # TODO Add TTL for thread
    last_update_count = 0
    while thread.is_alive():
        if len(updates) > last_update_count:
            for i in range(last_update_count, len(updates)):
                yield updates[i]
            last_update_count = len(updates)
        time.sleep(1)

    # Get final result if not already yielded
    if len(updates) > last_update_count:
        for i in range(last_update_count, len(updates)):
            yield updates[i]

    # Make sure thread is done
    thread.join(timeout=0.5)

    if len(task_result) == 1 and task_result[0] is not None:
        yield task_result[0]
