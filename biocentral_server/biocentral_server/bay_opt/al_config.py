from __future__ import annotations

from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field, model_validator

from ..custom_models import SequenceTrainingData


class ActiveLearningModelType(str, Enum):
    GAUSSIAN_PROCESS = "GAUSSIAN_PROCESS"
    FNN_MCD = "FNN_MCD"

    @staticmethod
    def from_string(status: str) -> ActiveLearningModelType:
        return ActiveLearningModelType(status.upper())


class ActiveLearningOptimizationMode(str, Enum):
    INTERVAL = "INTERVAL"
    VALUE = "VALUE"
    MAXIMIZE = "MAXIMIZE"
    MINIMIZE = "MINIMIZE"
    DISCRETE = "DISCRETE"

    @staticmethod
    def from_string(status: str) -> ActiveLearningOptimizationMode:
        return ActiveLearningOptimizationMode(status.upper())


class ActiveLearningCampaignConfig(BaseModel):
    """Configuration for an active learning campaign"""

    name: str = Field(description="Name of the active learning campaign")
    model_type: ActiveLearningModelType = Field(description="Type of model to use")
    embedder_name: str = Field(description="Name of embedder to use")
    optimization_mode: ActiveLearningOptimizationMode = Field(
        description="Optimization mode selection"
    )

    """Configuration for continuous optimization"""
    target_lb: Optional[float] = Field(
        default=None,
        description="Lower bound of the target value to optimize (mode: INTERVAL)",
    )
    target_ub: Optional[float] = Field(
        default=None,
        description="Upper bound of the target value to optimize (mode: INTERVAL)",
    )
    target_value: Optional[float] = Field(
        default=None, description="Target value to optimize (mode: VALUE)"
    )

    @model_validator(mode="after")
    def validate_continuous_config(self):
        if self.optimization_mode != ActiveLearningOptimizationMode.DISCRETE:
            if self.optimization_mode == ActiveLearningOptimizationMode.INTERVAL:
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
                    raise ValueError("target_lb must be < target_ub")

            elif self.optimization_mode == ActiveLearningOptimizationMode.VALUE:
                if self.target_value is None:
                    raise ValueError("Value optimization needs target_value")

        return self

    """Configuration for discrete optimization"""
    discrete_targets: Optional[List[str]] = Field(
        default=None, description="List of target labels (must be subset of all labels)"
    )


class ActiveLearningIterationConfig(BaseModel):
    """Configuration for a single iteration of active learning"""

    iteration_data: List[SequenceTrainingData] = Field(
        description="List of sequence training data for this iteration", min_length=2
    )
    coefficient: float = Field(
        description="Exploitation-Exploration Coefficient value (must be between 0 and 1, 1 is maximum exploration)",
        ge=0.0,
        le=1.0,
    )
    n_suggestions: int = Field(
        description="Number of suggestions to propose from this iteration", ge=1
    )

    def get_all_labels(self):
        return set([data_point.label for data_point in self.iteration_data])


class ActiveLearningSimulationConfig(BaseModel):
    """Configuration for a simulation of active learning on a complete dataset"""

    simulation_data: List[SequenceTrainingData] = Field(
        description="List of all sequence data for the simulation", min_length=2
    )
    n_start: int = Field(
        description="Number of initial sequences to use for training", ge=1
    )
    n_suggestions_per_iteration: int = Field(
        description="Number of suggestions to propose per iteration", ge=1
    )
    convergence_criterion: float = Field(
        description="Convergence criterion for the simulation. "
        "The simulation stops after two iterations that fulfill "
        "the criterion "
        "(>= convergence_criterion suggestions "
        "fulfill the optimization target)",
        ge=0.0,
        le=1.0,
    )
