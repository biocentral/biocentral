from typing import List, Optional

from pydantic import BaseModel, Field


class ActiveLearningResult(BaseModel):
    entity_id: str = Field(description="Entity identifier")
    prediction: float = Field(description="Predicted value")
    uncertainty: float = Field(description="Uncertainty of the prediction")
    score: float = Field(
        description="Score of the entity for using it for the next iteration"
    )


class ActiveLearningIterationResult(BaseModel):
    iteration: int = Field(
        description="Iteration number (zero indexed for simulations, "
        "otherwise matches the given number in the iteration config)"
    )
    results: List[ActiveLearningResult] = Field(
        description="List of active learning results", min_length=1
    )
    suggestions: List[str] = Field(
        description="List of suggested entity IDs for next iteration"
    )


class ActiveLearningSimulationResult(BaseModel):
    """Result of a simulated active learning campaign - used as a mutable object to store intermediate results"""

    campaign_name: str = Field(
        description="Name of the simulated active learning campaign"
    )
    iteration_metrics_total: List[float] = Field(
        default_factory=list,
        description="Total metrics (rmse/acc) for each iteration on all data",
    )
    iteration_metrics_suggestions: List[float] = Field(
        default_factory=list,
        description="Metrics (rmse/acc) for each iteration on suggested data",
    )
    iteration_target_successes: List[int] = Field(
        default_factory=list,
        description="Number of successful targets found in each iteration",
    )
    iteration_consecutive_failures: List[int] = Field(
        default_factory=list,
        description="Number of consecutive failures since the last successful target was found",
    )
    stop_reasons: Optional[List[str]] = Field(
        default=None,
        description="Reason(s) for stopping the simulation (convergence criteria reached)",
    )
    # iteration_results is kept empty and only filled by the api to decrease amount of data sent
    iteration_results: List[ActiveLearningIterationResult] = Field(
        default_factory=list,
        description="List of active learning iteration results",
    )
