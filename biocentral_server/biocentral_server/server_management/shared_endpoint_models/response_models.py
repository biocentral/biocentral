from pydantic import BaseModel, Field


class StartTaskResponse(BaseModel):
    """Response model for job submission"""

    task_id: str = Field(
        description="Unique task identifier for tracking the computation job"
    )
