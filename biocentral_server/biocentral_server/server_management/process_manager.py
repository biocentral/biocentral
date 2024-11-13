import asyncio

from typing import Dict, Coroutine

from .task_interface import TaskInterface, TaskStatus

_task_dict: Dict[str, TaskInterface] = {}


class ProcessManager:
    """
    Class with only static functions as wrapper. Accesses _task_dict like a singleton module
    """
    @staticmethod
    def add_task(task_id: str, task: TaskInterface):
        _task_dict[task_id] = task

    @staticmethod
    async def start_task(task_id: str):
        if task_id not in _task_dict.keys():
            raise Exception(f"task_id {task_id} not found to start task!")
        else:
            await _task_dict[task_id].start()

    @staticmethod
    def get_task_status(task_id: str) -> TaskStatus:
        if task_id not in _task_dict.keys():
            return TaskStatus.FINISHED
        else:
            return _task_dict[task_id].get_task_status()

    @staticmethod
    def get_task_update(task_id: str) -> Dict:
        if task_id not in _task_dict.keys():
            return {}
        else:
            return _task_dict[task_id].update()

    @staticmethod
    def get_current_number_of_running_tasks() -> int:
        return len([task for task in _task_dict.values() if task.get_task_status() == TaskStatus.RUNNING])
