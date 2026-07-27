from typing import List
from pydantic import BaseModel, Field

from ..server_management import TaskDTO, ResearchStats


class BiocentralServiceStats(BaseModel):
    usable_cpu_count: int = Field(
        description="Number of usable CPU cores available to the process"
    )
    embeddings_database_size: int = Field(
        description="Current size of the embeddings database in bytes"
    )
    total_tasks: int = Field(
        description="Total number of tasks submitted since server startup"
    )
    queue_length: int = Field(
        description="Current number of tasks queued for execution"
    )
    cuda_available: bool = Field(
        description="Whether CUDA GPU acceleration is available"
    )
    cuda_device_names: List[str] = Field(
        description="List of names of available CUDA devices"
    )
    cuda_device_count: int = Field(description="Number of available CUDA devices")


class TaskStatusResponse(BaseModel):
    dtos: List[TaskDTO] = Field(
        description="List of task DTOs generated during task execution since last request for the given task id"
    )


class ServiceStatsResponse(BaseModel):
    service_stats: BiocentralServiceStats = Field(description="Service statistics")


class ResearchStatsResponse(BaseModel):
    research_stats: ResearchStats = Field(description="Research statistics")
