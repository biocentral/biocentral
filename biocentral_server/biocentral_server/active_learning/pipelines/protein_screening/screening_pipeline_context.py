from typing import List, Callable, Optional, Set
from biotrainer_core.data_classes import SequenceData

from ..al_shared import ALContext

from ...al_config import (
    ActiveLearningModelType,
    ActiveLearningOptimizationMode,
)


class ScreeningPipelineContext(ALContext):
    """Large struct to hold pipeline context during execution"""

    def __init__(
        self,
        al_optimization_mode: ActiveLearningOptimizationMode,
        al_model_type: ActiveLearningModelType,
        embedder_name: str,
        al_iteration_data: List[SequenceData],
        biotrainer_subtask_wrapper: Callable,
        embeddings: List[SequenceData],
        iteration: int,  # Number of the iteration
        coefficient: float,
        n_suggestions: int,
        al_target_value: Optional[float] = None,
        al_target_lb: Optional[float] = None,
        al_target_ub: Optional[float] = None,
        al_discrete_targets: Optional[List[str]] = None,
        all_labels_in_data: Optional[Set[str]] = None,
    ):
        super().__init__(
            al_optimization_mode=al_optimization_mode,
            al_model_type=al_model_type,
            embedder_name=embedder_name,
            biotrainer_subtask_wrapper=biotrainer_subtask_wrapper,
            iteration=iteration,
            coefficient=coefficient,
            n_suggestions=n_suggestions,
            al_target_value=al_target_value,
            al_target_lb=al_target_lb,
            al_target_ub=al_target_ub,
            al_discrete_targets=al_discrete_targets,
            all_labels_in_data=all_labels_in_data,
        )

        self.al_iteration_data = al_iteration_data
        self.embeddings = embeddings
