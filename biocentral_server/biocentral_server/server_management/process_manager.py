import asyncio
import threading

from typing import Dict

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
    def start_task(task_id: str):
        if task_id not in _task_dict.keys():
            raise Exception(f"task_id {task_id} not found to start task!")
        else:
            def _run_async_loop():
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                loop.run_until_complete(_task_dict[task_id].start())
                loop.close()

            threading.Thread(target=_run_async_loop).start()

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
