from typing import List

from pydantic import BaseModel, Field


class ActiveLearningResult(BaseModel):
    entity_id: str = Field(description="Entity identifier")
    prediction: float = Field(description="Predicted value")
    uncertainty: float = Field(description="Uncertainty of the prediction")
    score: float = Field(
        description="Score of the entity for using it for the next iteration"
    )


class ActiveLearningIterationResult(BaseModel):
    results: List[ActiveLearningResult] = Field(
        description="List of active learning results", min_length=1
    )
    suggestions: List[str] = Field(
        description="List of suggested entity IDs for next iteration"
    )
