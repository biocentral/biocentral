import random
import numpy as np

from biotrainer.utilities import get_device
from typing import Callable, Tuple, List, Optional
from biotrainer.input_files import BiotrainerSequenceRecord

from .al_iteration_pipeline import al_pipeline
from .al_config import (
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningSimulationConfig,
    ActiveLearningOptimizationMode,
)

from ..utils import get_logger
from ..embeddings import LoadEmbeddingsTask
from ..custom_models import SequenceTrainingData
from ..server_management import (
    TaskInterface,
    TaskDTO,
    TaskStatus,
    ActiveLearningIterationResult,
)

logger = get_logger(__name__)


class ActiveLearningIterationTask(TaskInterface):
    def __init__(
        self,
        al_campaign_config: ActiveLearningCampaignConfig,
        al_simulation_config: ActiveLearningSimulationConfig,
    ):
        super().__init__()
        self.al_campaign_config = al_campaign_config
        self.al_simulation_config = al_simulation_config

    def _get_start_data(self):
        if self.al_simulation_config.start_ids:
            start_ids_set = set(self.al_simulation_config.start_ids)
            return [
                data_point
                for data_point in self.al_simulation_config.simulation_data
                if data_point.id in start_ids_set
            ]
        random_instance = random.Random(42)
        return random_instance.sample(
            self.al_simulation_config.simulation_data, self.al_simulation_config.n_start
        )

    def _run_single_iteration(
        self,
        current_training_data: List[SequenceTrainingData],
        embeddings: List[BiotrainerSequenceRecord],
    ):
        # TODO [Refactoring] Might be better to run al_iteration_task as a subtask here
        al_iteration_config = ActiveLearningIterationConfig(
            iteration_data=current_training_data,
            coefficient=0.5,  # TODO Adjust coefficient dynamically
            n_suggestions=self.al_simulation_config.n_suggestions_per_iteration,
        )
        al_iteration_result = al_pipeline(
            al_campaign_config=self.al_campaign_config,
            al_iteration_config=al_iteration_config,
            embeddings=embeddings,
        )
        return al_iteration_result

    def _check_convergence(self, al_iteration_result: ActiveLearningIterationResult):
        convergence_criterion = self.al_simulation_config.convergence_criterion
        min_max_percentile = 0.05  # TODO Make this configurable
        target_delta = 0.5  # TODO Make this configurable
        all_labels = [
            data_point.label for data_point in self.al_simulation_config.simulation_data
        ]
        iteration_suggestions = al_iteration_result.suggestions
        suggestion_labels = [
            data_point.label
            for data_point in self.al_simulation_config.simulation_data
            if data_point.seq_id in iteration_suggestions
        ]

        mode = self.al_campaign_config.optimization_mode
        match mode:
            case ActiveLearningOptimizationMode.MAXIMIZE:
                all_labels_float = list(map(float, all_labels))
                suggestion_labels_float = list(map(float, suggestion_labels))
                max_percentile = np.percentile(all_labels_float, 1 - min_max_percentile)
                over_percentile = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if sugg_label >= max_percentile
                ]
                return (
                    len(over_percentile) / len(iteration_suggestions)
                    >= convergence_criterion
                )
            case ActiveLearningOptimizationMode.MINIMIZE:
                all_labels_float = list(map(float, all_labels))
                suggestion_labels_float = list(map(float, suggestion_labels))
                min_percentile = np.percentile(all_labels_float, min_max_percentile)
                under_percentile = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if sugg_label <= min_percentile
                ]
                return (
                    len(under_percentile) / len(iteration_suggestions)
                    >= convergence_criterion
                )
            case ActiveLearningOptimizationMode.VALUE:
                target_value = self.al_campaign_config.target_value
                suggestion_labels_float = list(map(float, suggestion_labels))
                within_delta = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if abs(sugg_label - target_value) <= target_delta
                ]
                return (
                    len(within_delta) / len(iteration_suggestions)
                    >= convergence_criterion
                )
            case ActiveLearningOptimizationMode.INTERVAL:
                target_lb, target_ub = (
                    self.al_campaign_config.target_lb,
                    self.al_campaign_config.target_ub,
                )
                suggestion_labels_float = list(map(float, suggestion_labels))
                within_interval = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if target_lb <= sugg_label <= target_ub
                ]
                return (
                    len(within_interval) / len(iteration_suggestions)
                    >= convergence_criterion
                )
            case ActiveLearningOptimizationMode.DISCRETE:
                target_labels = self.al_campaign_config.discrete_targets
                correct = [
                    sugg_label
                    for sugg_label in suggestion_labels
                    if sugg_label in target_labels
                ]
                return (
                    len(correct) / len(iteration_suggestions) >= convergence_criterion
                )

    def _run_simulation(
        self, embeddings: List[BiotrainerSequenceRecord], update_dto_callback: Callable
    ):
        current_training_data = self._get_start_data()
        for iteration in range(self.al_simulation_config.n_max_iterations):
            al_iteration_result = self._run_single_iteration(
                current_training_data, embeddings
            )
            update_dto_callback(
                TaskDTO(
                    status=TaskStatus.RUNNING, al_iteration_result=al_iteration_result
                )
            )
            converged = self._check_convergence(al_iteration_result)
            if converged:
                return TaskDTO(status=TaskStatus.FINISHED)
        return TaskDTO(status=TaskStatus.FINISHED)

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        # Embed all simulation data
        error_dto, embeddings = self._pre_embed_with_db()
        if error_dto:
            return error_dto
        assert embeddings is not None, (
            "embeddings is None after pre-embedding before active learning iteration!"
        )

        return self._run_simulation(embeddings, update_dto_callback)

    def _pre_embed_with_db(
        self,
    ) -> Tuple[Optional[TaskDTO], List[BiotrainerSequenceRecord]]:
        # TODO [Refactoring] Duplicated code in biotrainer(_inference_)task
        simulation_data = [
            data_point.to_biotrainer_seq_record()
            for data_point in self.al_simulation_config.simulation_data
        ]
        embedder_name = self.al_campaign_config.embedder_name

        load_embeddings_task = LoadEmbeddingsTask(
            embedder_name=embedder_name,
            sequence_input=simulation_data,
            reduced=True,
            use_half_precision=False,
            device=get_device(),
            custom_tokenizer_config=None,
        )
        load_dto = None
        for dto in self.run_subtask(load_embeddings_task):
            load_dto = dto

        if not load_dto:
            return TaskDTO(
                status=TaskStatus.FAILED, error="Could not compute embeddings!"
            ), []

        embeddings: List[BiotrainerSequenceRecord] = load_dto.embeddings
        if len(embeddings) == 0:
            return TaskDTO(
                status=TaskStatus.FAILED,
                error="Did not receive embeddings for training!",
            ), []

        return None, embeddings
