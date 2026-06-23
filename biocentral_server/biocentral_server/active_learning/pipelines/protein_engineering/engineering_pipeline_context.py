from junban import PipelineContext
from typing import List, Callable, Optional, Set
from biotrainer_core.data_classes import SequenceData, BiotrainerModelResult

from ...al_config import (
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningModelType,
)
from ....server_management import ActiveLearningIterationResult


class EngineeringPipelineContext(PipelineContext):
    """Large struct to hold pipeline context during execution"""

    def __init__(
        self,
        al_campaign_config: ActiveLearningCampaignConfig,
        al_iteration_config: ActiveLearningIterationConfig,
        embeddings: List[SequenceData],
        biotrainer_subtask_wrapper: Callable,
        all_labels_in_data: Optional[Set[str]] = None,
    ):
        self.al_campaign_config = al_campaign_config
        self.al_iteration_config = al_iteration_config
        self.embeddings = embeddings
        self.biotrainer_subtask_wrapper = biotrainer_subtask_wrapper
        self.all_labels_in_data = all_labels_in_data

        # Prepare step
        self.training_data = None
        self.inference_data = None

        # Mutation Generation Step
        self.wildtype_sequence: str = None
        self.n_mutations: int = None
        self.mutation_depth: int = None
        self.mutations: List[str] = None

        # Training step
        self.biotrainer_result: Optional[BiotrainerModelResult] = None

        # Inference step
        self.predictions = None
        self.uncertainty = None
        self.desirability = None

        # Acquisition step
        self.scores = None  # Gets sorted in batch_selection step
        self.al_results = None

        # Batch Selection step
        self.suggestions = None

    def uses_biotrainer(self) -> bool:
        model_type = self.al_campaign_config.model_type
        if (
            model_type == ActiveLearningModelType.GAUSSIAN_PROCESS
            or model_type == ActiveLearningModelType.FNN_MCD
        ):
            return True
        return False

    def collect_iteration_result(self) -> ActiveLearningIterationResult:
        assert self.al_results is not None
        assert self.suggestions is not None
        al_iteration_result = ActiveLearningIterationResult(
            iteration=self.al_iteration_config.iteration,
            results=self.al_results,
            suggestions=self.suggestions,
        )
        return al_iteration_result
