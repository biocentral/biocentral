import os
import uuid
import logging

from redis import Redis
from rq import Queue, get_current_job
from typing import Dict, Any, Type, List, Optional

from .task_interface import TaskStatus, TaskInterface, TaskDTO

logger = logging.getLogger(__name__)


def run_task_with_updates(task: TaskInterface) -> TaskDTO:
    current_job = get_current_job()

    def update_dto_callback(dto: TaskDTO):
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

        # TODO [Feature] Add priority queues
        self.default_queue = Queue('default', connection=self.redis_conn)

    def add_task(self, task: TaskInterface, task_id: Optional[str] = "") -> str:
        if task_id == "" or "biocentral" not in task_id:
            task_id = self._generate_task_id(task=task.__class__)

        # Enqueue the task using RQ
        job = self.default_queue.enqueue(
            run_task_with_updates,
            args=(task,),
            job_id=task_id,
            result_ttl=500,  # How long to keep successful job results
            failure_ttl=3600 * 24,  # Keep failed jobs for 24 hours
            meta={'task_class': task.__class__.__name__}
        )

        return task_id

    def get_task_status(self, task_id: str) -> TaskStatus:
        job = self.default_queue.fetch_job(task_id)
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
    def _generate_task_id(task):
        return f"biocentral-{task.__name__}-{str(uuid.uuid4())}"

    def get_all_task_updates(self, task_id: str) -> List[TaskDTO]:
        job = self.default_queue.fetch_job(task_id)

        dtos = []
        if "dto" in job.meta.keys():
            dtos = job.meta["dto"]

        additional_dto = None
        if job is None:
            additional_dto = TaskDTO.failed(error=f"task {task_id} not found on server!")

        if job.is_failed:
            additional_dto = TaskDTO.failed(error=str(job.latest_result()))
        elif job.is_finished:
            additional_dto = job.latest_result().return_value

        if additional_dto is not None:
            dtos.append(additional_dto)
        return dtos

    def is_task_finished(self, task_id: str) -> bool:
        job = self.default_queue.fetch_job(task_id)
        return job is not None and job.is_finished
