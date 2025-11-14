from typing import List, Optional
from pydantic import BaseModel, Field, field_validator, model_validator


class BayesianOptimizationRequest(BaseModel):
    """Request model for Bayesian optimization training"""

    database_hash: str = Field(description="Hash identifier for the training database")
    model_type: str = Field(description="Type of model to use")
    coefficient: float = Field(
        description="Coefficient value (must be non-negative)", ge=0.0
    )
    embedder_name: str = Field(description="Name of embedder to use")

    @field_validator("model_type")
    @classmethod
    def validate_model_type(cls, v):
        from .bayesian_optimization_task import BayesTask

        v_lower = v.lower()
        if v_lower not in BayesTask.SUPPORTED_MODELS:
            raise ValueError(
                f"Unsupported model type. Valid types: {BayesTask.SUPPORTED_MODELS}"
            )
        return v_lower

    """Configuration for continuous optimization"""
    discrete: bool = Field(
        description="Whether to perform discrete optimization or continuous optimization"
    )
    optimization_mode: str = Field(description="Optimization mode selection")
    target_lb: Optional[float] = None
    target_ub: Optional[float] = None
    target_value: Optional[float] = None

    @field_validator("optimization_mode")
    @classmethod
    def validate_optimization_mode(cls, v):
        v_lower = v.lower()
        if v_lower not in ["interval", "value", "maximize", "minimize"]:
            raise ValueError(
                "Unsupported optimization mode. Valid modes: ['interval', 'value']"
            )
        return v_lower

    @model_validator(mode="after")
    def validate_continuous_config(self):
        if not self.discrete:
            mode = self.optimization_mode

            if mode == "interval":
                if self.target_lb is None and self.target_ub is None:
                    raise ValueError(
                        "Interval optimization needs target_lb or target_ub"
                    )

                # Set defaults
                if self.target_lb is None:
                    self.target_lb = float("-inf")
                if self.target_ub is None:
                    self.target_ub = float("inf")

                if self.target_lb >= self.target_ub:
                    raise ValueError("target_lb should be < target_ub")

            elif mode == "value":
                if self.target_value is None:
                    raise ValueError("Value optimization needs target_value")

        return self

    """Configuration for discrete optimization"""
    discrete_labels: Optional[List[str]] = Field(
        description="List of all possible discrete labels"
    )
    discrete_targets: Optional[List[str]] = Field(
        description="List of target labels (must be subset of labels)"
    )

    @model_validator(mode="after")
    def validate_discrete_config(self):
        if self.discrete:
            labels_set = set(self.discrete_labels)
            targets_set = set(self.discrete_targets)

            if not (
                labels_set.issuperset(targets_set)
                and len(labels_set) > len(targets_set)
            ):
                raise ValueError("targets should be true subset of labels")

            if len(targets_set) != 1:
                raise ValueError("discrete_targets should have exactly 1 element")

        return self
