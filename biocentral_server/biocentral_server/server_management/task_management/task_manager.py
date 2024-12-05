import uuid
import logging
import threading

from queue import Queue, Empty
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from typing import Dict, Any, Type, List, Set

from .task_interface import TaskStatus, TaskInterface, TaskDTO

logger = logging.getLogger(__name__)

class TaskManager:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(TaskManager, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self._task_dtos: Dict[str, Queue] = defaultdict(lambda: Queue())
        self._finished_tasks: Dict[str, TaskStatus] = dict()
        _max_concurrent_tasks = 5  # TODO [CONFIG] Make this configurable from config and UI
        self._executor = ThreadPoolExecutor(max_workers=_max_concurrent_tasks)
        self._lock = threading.Lock()  # TODO [OPTIMIZATION] Maybe use a log-free data structure

    def add_task(self, task: TaskInterface, task_id: str = "") -> str:
        if task_id == "" or "biocentral" not in task_id:  # biocentral: Sanity check
            task_id = self._generate_task_id(task=task.__class__)
        self._task_dtos[task_id].put(TaskDTO.pending())
        future = self._executor.submit(self._execute_task, task_id, task)
        future.add_done_callback(lambda f: self._task_completed_callback(task_id, f))
        return task_id

    def get_unique_task_id(self, task: Type) -> str:
        return self._generate_task_id(task=task)

    @staticmethod
    def _generate_task_id(task):
        return f"biocentral-{task.__name__}-{str(uuid.uuid4())}"

    def _execute_task(self, task_id: str, task: TaskInterface):
        self._task_dtos[task_id].put(TaskDTO.running())

        def dto_callback(dto: TaskDTO):
            self._update_task_dto_callback(task_id=task_id, task_dto=dto)

        return task.run_task(update_dto_callback=dto_callback)

    def _task_completed_callback(self, task_id: str, future):
        try:
            result_dto = future.result()
            self._update_task_dto_callback(task_id=task_id, task_dto=result_dto)
            self._finished_tasks[task_id] = result_dto.status
        except Exception as e:
            logger.error(f"Task {task_id} failed with error: {e}")
            self._task_dtos[task_id].put(TaskDTO.failed(str(e)))
            self._finished_tasks[task_id] = TaskStatus.FAILED

    def _update_task_dto_callback(self, task_id: str, task_dto: TaskDTO):
        with self._lock:
            self._task_dtos[task_id].put(task_dto)

    def get_task_status(self, task_id: str) -> TaskStatus:
        if self.is_task_finished(task_id):
            return self._finished_tasks[task_id]

        queue = self._task_dtos.get(task_id)
        return queue.queue[-1].status if queue and not queue.empty() else TaskStatus.PENDING

    def is_task_finished(self, task_id: str) -> bool:
        return task_id in self._finished_tasks

    def get_task_dto(self, task_id: str) -> Any:
        if task_id in self._task_dtos:
            queue = self._task_dtos.get(task_id)
            if queue and not queue.empty():
                dto = queue.get()
                return dto
            # No updates
            last_status = self.get_task_status(task_id)
            return TaskDTO(status=last_status, error="", update={})
        return TaskDTO.failed(error=f"task {task_id} not found on server!")

    def get_all_task_updates(self, task_id: str) -> List[TaskDTO]:
        with self._lock:
            queue = self._task_dtos.get(task_id)
            list_copy = []
            # Use while loop to ensure lock safety
            while True:
                try:
                    elem = queue.get(block=False)
                except Empty:
                    break
                else:
                    list_copy.append(elem)
            return list_copy

    def get_current_number_of_running_tasks(self) -> int:
        return sum(1 for queue in self._task_dtos.values() if
                   not queue.empty() and queue.queue[-1].status == TaskStatus.RUNNING)
    def __del__(self):
        self._executor.shutdown(wait=True)
