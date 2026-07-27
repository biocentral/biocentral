from junban import PipelineContext
from typing import List, Callable, Optional, Set
from biotrainer_core.data_classes import BiotrainerModelResult

from ...al_config import (
    ActiveLearningOptimizationMode,
    ActiveLearningModelType,
)
from ....server_management import ActiveLearningIterationResult


class ALContext(PipelineContext):
    """Large struct to hold pipeline context during execution"""

    def __init__(
        self,
        al_optimization_mode: ActiveLearningOptimizationMode,
        al_model_type: ActiveLearningModelType,
        embedder_name: str,
        biotrainer_subtask_wrapper: Callable,
        iteration: int,  # Number of the iteration
        coefficient: float,
        n_suggestions: int,
        al_target_value: Optional[float] = None,
        al_target_lb: Optional[float] = None,
        al_target_ub: Optional[float] = None,
        al_discrete_targets: Optional[List[str]] = None,
        all_labels_in_data: Optional[Set[str]] = None,
    ):
        self.al_optimization_mode = al_optimization_mode
        self.al_model_type = al_model_type
        self.al_task_type = (
            "classification"
            if al_optimization_mode == ActiveLearningOptimizationMode.DISCRETE
            else "regression"
        )
        self.embedder_name = embedder_name
        self.biotrainer_subtask_wrapper = biotrainer_subtask_wrapper

        self.iteration = iteration
        self.coefficient = coefficient
        self.n_suggestions = n_suggestions

        self.al_target_value = al_target_value
        self.al_target_lb = al_target_lb
        self.al_target_ub = al_target_ub

        self.al_discrete_targets = al_discrete_targets
        self.all_labels_in_data = all_labels_in_data

        # Prepare step
        self.training_data = None
        self.inference_data = None

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
        return self.al_model_type in [
            ActiveLearningModelType.GAUSSIAN_PROCESS,
            ActiveLearningModelType.FNN_MCD,
        ]

    def collect_iteration_result(self) -> ActiveLearningIterationResult:
        assert self.al_results is not None
        assert self.suggestions is not None
        al_iteration_result = ActiveLearningIterationResult(
            iteration=self.iteration,
            results=self.al_results,
            suggestions=self.suggestions,
        )
        return al_iteration_result
