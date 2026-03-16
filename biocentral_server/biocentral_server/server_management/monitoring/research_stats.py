from datetime import datetime
from pydantic import BaseModel, Field


class ResearchStats(BaseModel):
    total_sequences_today: int = Field(
        description="Total number of sequences uploaded in the last 24 hours"
    )
    total_sequences_all_time: int = Field(
        description="Total number of sequences uploaded in all time"
    )
    avg_sequence_length: float = Field(
        description="Average length of sequences uploaded"
    )
    aa_distribution: dict[str, int] = Field(
        description="Distribution of amino acids in the sequences"
    )
    top_embedders: dict[str, float] = Field(description="Top embedders based on usage")
    top_predictors: dict[str, float] = Field(
        description="Top prediction models based on usage"
    )
    updated_at: datetime = Field(description="Timestamp of the last update")
