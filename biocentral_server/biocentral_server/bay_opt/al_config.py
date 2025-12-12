from __future__ import annotations

from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field, model_validator, field_validator

from ..custom_models import SequenceTrainingData


class ActiveLearningModelType(str, Enum):
    GAUSSIAN_PROCESS = "GAUSSIAN_PROCESS"
    FNN_MCD = "FNN_MCD"
    RANDOM = "RANDOM"

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

    iteration: int = Field(description="Iteration number")
    iteration_data: List[SequenceTrainingData] = Field(
        description="List of sequence training data for this iteration", min_length=2
    )
    coefficient: float = Field(
        description="Exploitation-Exploration coefficient value (must be between 0 and 1, 1 is maximum exploration)",
        ge=0.0,
        le=1.0,
    )
    n_suggestions: int = Field(
        description="Number of suggestions to propose from this iteration", ge=1
    )

    def get_all_labels(self):
        return set([data_point.label for data_point in self.iteration_data])

    @field_validator("iteration_data")
    @classmethod
    def validate_iteration_data(cls, v: List[SequenceTrainingData]):
        iteration_ids = [data_point.seq_id for data_point in v]
        if len(iteration_ids) != len(set(iteration_ids)):
            raise ValueError("iteration_data contains duplicate entries!")
        return v


class ActiveLearningSimulationConfig(BaseModel):
    """Configuration for a simulation of active learning on a complete dataset"""

    simulation_data: List[SequenceTrainingData] = Field(
        description="List of all sequence data for the simulation", min_length=2
    )
    n_start: Optional[int] = Field(
        default=None,
        description="Number of initial sequences to use for training (chosen at random)",
        ge=1,
    )
    start_ids: Optional[List[str]] = Field(
        default=None,
        description="List of sequence IDs to start the simulated campaign",
        min_length=1,
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
    n_max_iterations: int = Field(
        description="Maximum number of iterations to run the simulation", ge=1
    )

    @field_validator("simulation_data")
    @classmethod
    def validate_simulation_data(cls, v: List[SequenceTrainingData]):
        simulation_ids = []
        for seq_data in v:
            label = seq_data.label
            if label is None or label == "None" or label == "":
                raise ValueError(
                    "All sequence data must have a label for an active learning simulation!"
                )
            simulation_ids.append(seq_data.seq_id)
        if len(simulation_ids) != len(set(simulation_ids)):
            raise ValueError("simulation_data contains duplicate entries!")
        return v

    @model_validator(mode="after")
    def validate_start_data(self):
        if self.n_start is not None and self.start_ids is not None:
            raise ValueError("Cannot specify both n_start and start_ids")
        if self.n_start:
            if len(self.simulation_data) < self.n_start:
                raise ValueError(f"Not enough sequence data for n_start={self.n_start}")
        if self.start_ids:
            start_ids_unique = set(self.start_ids)
            if len(start_ids_unique) != len(self.start_ids):
                raise ValueError("start_ids contains duplicate entries!")

            simulation_ids = set(
                [data_point.seq_id for data_point in self.simulation_data]
            )
            if not start_ids_unique.issubset(simulation_ids):
                raise ValueError("start_ids not a subset of simulation_data ids!")
        return self
