from typing import List
from pydantic import BaseModel, Field

from ..server_management import TaskDTO


class TransferFileRequest(BaseModel):
    hash: str
    file_type: str
    file: str


class TaskStatusResponse(BaseModel):
    dtos: List[TaskDTO] = Field(
        description="List of task DTOs generated during task execution"
    )
