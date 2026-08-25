from pydantic import BaseModel, Field


class EmbeddingProgress(BaseModel):
    current: int = Field(description="Current progress")
    total: int = Field(description="Total number of embeddings to compute")
