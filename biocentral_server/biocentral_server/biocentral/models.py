from typing import Any, Dict
from pydantic import BaseModel, Field


class TransferFileRequest(BaseModel):
    hash: str
    file_type: str
    file: str


class TaskStatusResponse(BaseModel):
    dtos: Dict[str, Any] = Field(description="Dictionary of task DTOs")
