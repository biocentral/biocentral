from pydantic import BaseModel, Field, model_validator

from .al_config import (
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningOptimizationMode,
    ActiveLearningSimulationConfig,
)


class ActiveLearningIterationRequest(BaseModel):
    """Request model for an active learning iteration"""

    campaign_config: ActiveLearningCampaignConfig = Field(
        description="Campaign configuration"
    )
    iteration_config: ActiveLearningIterationConfig = Field(
        description="Iteration configuration"
    )

    @model_validator(mode="after")
    def validate_discrete_config(self):
        if (
            self.campaign_config.optimization_mode
            == ActiveLearningOptimizationMode.DISCRETE
        ):
            labels_set = set(
                [
                    data_point.label
                    for data_point in self.iteration_config.iteration_data
                    if data_point.label is not None
                ]
            )
            targets_set = set(self.campaign_config.discrete_targets)

            if len(labels_set) == 0:
                raise ValueError("No labels found for discrete optimization iteration!")

            if len(targets_set) == 0:
                raise ValueError(
                    "No discrete optimization targets given for discrete optimization iteration!"
                )

            if not (
                labels_set.issuperset(targets_set)
                and len(labels_set) > len(targets_set)
            ):
                raise ValueError(
                    "Optimization target labels must be a true subset of all labels!"
                )

        return self


class ActiveLearningSimulationRequest(BaseModel):
    """Request model for an active learning simulation"""

    campaign_config: ActiveLearningCampaignConfig = Field(
        description="Campaign configuration"
    )
    simulation_config: ActiveLearningSimulationConfig = Field(
        description="Simulation configuration"
    )
