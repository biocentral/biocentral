import os
import uuid

from redis import Redis
from rq import Queue, get_current_job
from typing import Type, List, Optional

from .task_interface import TaskStatus, TaskInterface, TaskDTO

from ...utils import get_logger

logger = get_logger(__name__)


def run_task_with_updates(task: TaskInterface) -> TaskDTO:
    def update_dto_callback(dto: TaskDTO):
        current_job = get_current_job()
        if "dto" not in current_job.meta:
            current_job.meta["dto"] = []
        current_job.meta["dto"].append(dto)
        current_job.save_meta()

    return task.run_task(update_dto_callback=update_dto_callback)


class TaskManager:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(TaskManager, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        # Initialize Redis connection
        redis_jobs_host = os.environ.get("REDIS_JOBS_HOST", "redis-jobs")
        redis_jobs_port = os.environ.get("REDIS_JOBS_PORT", 6379)
        self.redis_conn = Redis(host=redis_jobs_host, port=redis_jobs_port, db=0)

        # TODO [Feature] Add priority queues not only for subtasks
        self.default_queue = Queue("default", connection=self.redis_conn)
        self.subtask_queue = Queue("high", connection=self.redis_conn)

    def _get_job(self, task_id: str):
        queues = [self.default_queue, self.subtask_queue]
        for queue in queues:
            job = queue.fetch_job(task_id)
            if job is not None:
                return job
        return None  # Job not found in any queue

    def _cleanup_task(self, task_id: str):
        redis_task_counter_key = self._get_redis_task_counter_key(task_id)
        self.redis_conn.delete(redis_task_counter_key)

    def _enqueue(self, task: TaskInterface, task_id: str, queue, user_id: str = ""):
        _ = queue.enqueue(
            run_task_with_updates,
            args=(task,),
            job_id=task_id,
            result_ttl=500,  # How long to keep successful job results
            failure_ttl=3600 * 24,  # Keep failed jobs for 24 hours
            job_timeout=3600 * 24,
            # TODO Callbacks
            # on_success=lambda jb, connection, result, *args, **kwargs: self._cleanup_task(task_id=task_id),
            # on_failure=lambda jb, connection, type, value, traceback: self._cleanup_task(task_id=task_id),
            # on_stopped=lambda jb, connection: self._cleanup_task(task_id=task_id),
            meta={"task_class": task.__class__.__name__, "user_id": user_id},
        )

    def add_task(
        self, task: TaskInterface, task_id: Optional[str] = "", user_id: str = ""
    ) -> str:
        if task_id == "" or "biocentral" not in task_id:
            task_id = self._generate_task_id(task=task.__class__)

        self._enqueue(
            task=task, task_id=task_id, queue=self.default_queue, user_id=user_id
        )

        return task_id

    def add_subtask(self, task: TaskInterface, user_id: str = "") -> str:
        task_id = self._generate_task_id(task=task.__class__)

        self._enqueue(
            task=task, task_id=task_id, queue=self.subtask_queue, user_id=user_id
        )

        return task_id

    def get_task_status(self, task_id: str) -> TaskStatus:
        job = self._get_job(task_id)
        if job is None:
            return TaskStatus.PENDING

        # Map RQ job status to your TaskStatus enum
        if job.is_finished:
            return TaskStatus.FINISHED
        elif job.is_failed:
            return TaskStatus.FAILED
        elif job.is_started:
            return TaskStatus.RUNNING
        else:
            return TaskStatus.PENDING

    def get_current_number_of_running_tasks(self) -> int:
        # Count jobs that are currently being processed
        return len(self.default_queue.started_job_registry)

    def get_unique_task_id(self, task: Type) -> str:
        return self._generate_task_id(task=task)

    @staticmethod
    def _get_redis_task_counter_key(task_id: str):
        return f"rq:{task_id}:counter"

    @staticmethod
    def _generate_task_id(task):
        return f"biocentral-{task.__name__}-{str(uuid.uuid4())}"

    def _read_task_updates_from_job(
        self, task_id: str, read_counter: int = 0
    ) -> (List[TaskDTO], int):
        job = self._get_job(task_id)

        dtos = []
        length_read = 0
        if job is not None:
            if "dto" in job.meta.keys() and len(job.meta["dto"]) > 0:
                all_dtos = job.meta["dto"]
                dtos = all_dtos[read_counter:]
                length_read = len(all_dtos)

        additional_dto = None
        if job is None:
            additional_dto = TaskDTO(
                status=TaskStatus.FAILED, error=f"task {task_id} not found on server!"
            )
        elif job.is_failed:
            additional_dto = TaskDTO(
                status=TaskStatus.FAILED, error=str(job.latest_result())
            )
        elif job.is_finished:
            additional_dto = job.latest_result().return_value

        if additional_dto is not None:
            dtos.append(additional_dto)
        return dtos, length_read

    def get_new_task_updates(self, task_id: str) -> List[TaskDTO]:
        redis_task_counter_key = self._get_redis_task_counter_key(task_id=task_id)
        counter: Optional[int] = self.redis_conn.get(redis_task_counter_key)
        if counter is None:
            counter = 0
        counter = int(counter)

        dtos, length_read = self._read_task_updates_from_job(
            task_id=task_id, read_counter=counter
        )
        self.redis_conn.set(redis_task_counter_key, length_read)

        return dtos

    def get_all_task_updates_from_start(self, task_id: str) -> List[TaskDTO]:
        redis_task_counter_key = self._get_redis_task_counter_key(task_id=task_id)
        counter = 0
        dtos, length_read = self._read_task_updates_from_job(
            task_id=task_id, read_counter=counter
        )
        self.redis_conn.set(redis_task_counter_key, length_read)

        return dtos

    def is_task_finished(self, task_id: str) -> bool:
        job = self._get_job(task_id)
        return job is not None and job.is_finished

    def get_task_owner(self, task_id: str) -> Optional[str]:
        """Return the user_id associated with this task or None if task not found."""
        job = self._get_job(task_id)
        if job is None:
            return None
        meta = getattr(job, "meta", {}) or {}
        return meta.get("user_id", "")
