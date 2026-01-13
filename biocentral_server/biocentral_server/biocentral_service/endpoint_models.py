from typing import List
from pydantic import BaseModel, Field

from ..server_management import TaskDTO


class TaskStatusResponse(BaseModel):
    dtos: List[TaskDTO] = Field(
        description="List of task DTOs generated during task execution since last request for the given task id"
    )
