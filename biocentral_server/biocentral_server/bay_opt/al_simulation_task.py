import random
import numpy as np
import torch
import torchmetrics

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
    ActiveLearningSimulationResult,
)

logger = get_logger(__name__)


class ActiveLearningSimulationTask(TaskInterface):
    def __init__(
        self,
        al_campaign_config: ActiveLearningCampaignConfig,
        al_simulation_config: ActiveLearningSimulationConfig,
    ):
        super().__init__()
        self.al_campaign_config = al_campaign_config
        self.al_simulation_config = al_simulation_config
        self.all_simulation_data_dict = {
            data_point.seq_id: data_point
            for data_point in self.al_simulation_config.simulation_data
        }
        self.al_simulation_result = ActiveLearningSimulationResult(
            campaign_name=self.al_campaign_config.name
        )

    def _get_start_data(self) -> Tuple[List[SequenceTrainingData], int]:
        start_ids_set: set[str]
        if self.al_simulation_config.start_ids:
            start_ids_set = set(self.al_simulation_config.start_ids)
        else:
            random_instance = random.Random(42)
            random_sample = random_instance.sample(
                self.al_simulation_config.simulation_data,
                self.al_simulation_config.n_start,
            )
            start_ids_set = set([data_point.seq_id for data_point in random_sample])
        return [
            data_point
            if data_point.seq_id in start_ids_set
            else data_point.delete_label()
            for data_point in self.al_simulation_config.simulation_data
        ], len(start_ids_set)

    def _run_single_iteration(
        self,
        iteration_number: int,
        current_training_data: List[SequenceTrainingData],
        embeddings: List[BiotrainerSequenceRecord],
    ):
        # TODO [Refactoring] Might be better to run al_iteration_task as a subtask here
        al_iteration_config = ActiveLearningIterationConfig(
            iteration=iteration_number,
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

    def _calculate_convergence(
        self, al_iteration_result: ActiveLearningIterationResult
    ) -> float:
        min_max_percentile = 5  # TODO Make this configurable
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
                max_percentile = np.percentile(
                    all_labels_float, 100 - min_max_percentile
                )
                over_percentile = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if sugg_label >= max_percentile
                ]
                return len(over_percentile) / len(iteration_suggestions)
            case ActiveLearningOptimizationMode.MINIMIZE:
                all_labels_float = list(map(float, all_labels))
                suggestion_labels_float = list(map(float, suggestion_labels))
                min_percentile = np.percentile(all_labels_float, min_max_percentile)
                under_percentile = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if sugg_label <= min_percentile
                ]
                return len(under_percentile) / len(iteration_suggestions)
            case ActiveLearningOptimizationMode.VALUE:
                target_value = self.al_campaign_config.target_value
                suggestion_labels_float = list(map(float, suggestion_labels))
                within_delta = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if abs(sugg_label - target_value) <= target_delta
                ]
                return len(within_delta) / len(iteration_suggestions)
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
                return len(within_interval) / len(iteration_suggestions)
            case ActiveLearningOptimizationMode.DISCRETE:
                target_labels = self.al_campaign_config.discrete_targets
                correct = [
                    sugg_label
                    for sugg_label in suggestion_labels
                    if sugg_label in target_labels
                ]
                return len(correct) / len(iteration_suggestions)

    def _update_metrics(
        self, convergence: float, al_iteration_result: ActiveLearningIterationResult
    ):
        self.al_simulation_result.iteration_convergence.append(convergence)
        all_preds_vs_actual = {
            data_point.entity_id: (
                data_point.prediction,
                float(self.all_simulation_data_dict[data_point.entity_id].label),
            )
            for data_point in al_iteration_result.results
        }
        iteration_suggestions = set(al_iteration_result.suggestions)
        suggestion_preds_vs_actual = {
            entity_id: p_v_a
            for entity_id, p_v_a in all_preds_vs_actual.items()
            if entity_id in iteration_suggestions
        }

        # TODO Add accuracy for discrete optimization mode
        rmse_metric = torchmetrics.MeanSquaredError(squared=False)

        # Calculate RMSE for all predictions
        all_preds = torch.tensor([p[0] for p in all_preds_vs_actual.values()])
        all_actuals = torch.tensor([p[1] for p in all_preds_vs_actual.values()])
        all_rmse = rmse_metric(all_preds, all_actuals)

        # Calculate RMSE for suggestions only
        sugg_preds = torch.tensor([p[0] for p in suggestion_preds_vs_actual.values()])
        sugg_actuals = torch.tensor([p[1] for p in suggestion_preds_vs_actual.values()])
        sugg_rmse = rmse_metric(sugg_preds, sugg_actuals)

        self.al_simulation_result.iteration_metrics_total.append(float(all_rmse))
        self.al_simulation_result.iteration_metrics_suggestions.append(float(sugg_rmse))

    def _run_simulation(
        self, embeddings: List[BiotrainerSequenceRecord], update_dto_callback: Callable
    ):
        ITERATIONS_UNTIL_CONVERGENCE = 5

        current_data_with_masking, n_start_data = self._get_start_data()
        n_total_suggestions = 0
        n_converged = 0
        n_sim_data_total = len(self.al_simulation_config.simulation_data)
        for iteration in range(self.al_simulation_config.n_max_iterations):
            if n_total_suggestions + n_start_data >= n_sim_data_total:
                # No new data left
                break

            # Run iteration
            al_iteration_result = self._run_single_iteration(
                iteration_number=iteration,
                current_training_data=current_data_with_masking,
                embeddings=embeddings,
            )
            update_dto_callback(
                TaskDTO(
                    status=TaskStatus.RUNNING, al_iteration_result=al_iteration_result
                )
            )
            # Calculate convergence and update metrics
            convergence = self._calculate_convergence(al_iteration_result)
            self._update_metrics(convergence, al_iteration_result)

            # Check convergence
            converged = convergence >= self.al_simulation_config.convergence_criterion
            n_converged = n_converged + 1 if converged else 0
            if (
                n_converged >= ITERATIONS_UNTIL_CONVERGENCE
            ):  # TODO Make this configurable
                logger.info(f"Simulation converged after {iteration + 1} iterations!")
                self.al_simulation_result.did_converge = True
                return TaskDTO(
                    status=TaskStatus.FINISHED,
                    al_simulation_result=self.al_simulation_result,
                )

            # Next iteration with updated training data
            iteration_suggestions = set(al_iteration_result.suggestions)
            n_total_suggestions += len(iteration_suggestions)
            current_data_with_masking = [
                data_point.set_label(
                    self.all_simulation_data_dict[data_point.seq_id].label
                )
                if data_point.seq_id in iteration_suggestions
                else data_point
                for data_point in current_data_with_masking
            ]

        # Max epoch exceeded without convergence
        self.al_simulation_result.did_converge = False
        return TaskDTO(
            status=TaskStatus.FINISHED, al_simulation_result=self.al_simulation_result
        )

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
