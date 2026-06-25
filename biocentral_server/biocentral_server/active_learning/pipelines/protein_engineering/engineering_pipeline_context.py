from typing import List, Callable, Optional, Set, Tuple
from biotrainer_core.data_classes import SequenceData

from ..al_shared import ALContext

from ...al_config import (
    ActiveLearningOptimizationMode,
    ActiveLearningModelType,
)

from ....server_management import TaskDTO


class EngineeringPipelineContext(ALContext):
    """Large struct to hold pipeline context during execution"""

    def __init__(
        self,
        al_optimization_mode: ActiveLearningOptimizationMode,
        al_model_type: ActiveLearningModelType,
        al_training_data: List[SequenceData],
        base_sequences: List[str],
        embedding_subtask_wrapper: Callable[
            [List[SequenceData]], Tuple[Optional[TaskDTO], List[SequenceData]]
        ],
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
        super().__init__(
            al_optimization_mode,
            al_model_type,
            biotrainer_subtask_wrapper,
            iteration,
            coefficient,
            n_suggestions,
            al_target_value,
            al_target_lb,
            al_target_ub,
            al_discrete_targets,
            all_labels_in_data,
        )

        self.al_training_data = al_training_data

        # Embedding Step
        self.embedding_subtask_wrapper = embedding_subtask_wrapper

        # Mutation Generation Step
        self.base_sequences = base_sequences
        self.n_mutations: int = 1000  # TODO CONFIG
        self.mutation_depth: int = 1  # TODO CONFIG
        self.mutations: Optional[List[str]] = None
