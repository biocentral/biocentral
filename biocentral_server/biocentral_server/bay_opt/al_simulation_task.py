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


class _ActiveLearningSimulationFixedParameters:
    @classmethod
    def min_max_percentile(cls) -> float:
        return 1  # 1% / 99%

    @classmethod
    def target_delta(cls) -> float:
        return 0.5  # TODO Merge with interval task

    @classmethod
    def n_max_iterations(cls) -> int:
        return 100


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
        n_total_suggestions: int,
        current_training_data: List[SequenceTrainingData],
        embeddings: List[BiotrainerSequenceRecord],
    ):
        # Limit number of suggestions per iteration to budget if applicable
        if self.al_simulation_config.convergence_config.max_labels_budget is not None:
            n_to_suggest = min(
                self.al_simulation_config.convergence_config.max_labels_budget
                - n_total_suggestions,
                self.al_simulation_config.n_suggestions_per_iteration,
            )
        else:
            n_to_suggest = self.al_simulation_config.n_suggestions_per_iteration
        al_iteration_config = ActiveLearningIterationConfig(
            iteration=iteration_number,
            iteration_data=current_training_data,
            coefficient=0.5,  # TODO Adjust coefficient dynamically
            n_suggestions=n_to_suggest,
        )

        # TODO [Refactoring] Might be better to run al_iteration_task as a subtask here
        al_iteration_result = al_pipeline(
            al_campaign_config=self.al_campaign_config,
            al_iteration_config=al_iteration_config,
            embeddings=embeddings,
        )
        return al_iteration_result

    def _calculate_target_successes(self, iteration_suggestions) -> int:
        min_max_percentile = (
            _ActiveLearningSimulationFixedParameters.min_max_percentile()
        )
        target_delta = _ActiveLearningSimulationFixedParameters.target_delta()
        all_labels = [
            data_point.label for data_point in self.al_simulation_config.simulation_data
        ]
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
                return len(over_percentile)
            case ActiveLearningOptimizationMode.MINIMIZE:
                all_labels_float = list(map(float, all_labels))
                suggestion_labels_float = list(map(float, suggestion_labels))
                min_percentile = np.percentile(all_labels_float, min_max_percentile)
                under_percentile = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if sugg_label <= min_percentile
                ]
                return len(under_percentile)
            case ActiveLearningOptimizationMode.VALUE:
                target_value = self.al_campaign_config.target_value
                suggestion_labels_float = list(map(float, suggestion_labels))
                within_delta = [
                    sugg_label
                    for sugg_label in suggestion_labels_float
                    if abs(sugg_label - target_value) <= target_delta
                ]
                return len(within_delta)
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
                return len(within_interval)
            case ActiveLearningOptimizationMode.DISCRETE:
                target_labels = self.al_campaign_config.discrete_targets
                correct = [
                    sugg_label
                    for sugg_label in suggestion_labels
                    if sugg_label in target_labels
                ]
                return len(correct)

    def _check_convergence(
        self,
        n_total_suggestions: int,
        n_total_target_successes: int,
        n_consecutive_failures: int,
    ) -> Tuple[bool, List[str]]:
        convergence_config = self.al_simulation_config.convergence_config
        max_labels_exceeded = (
            n_total_suggestions >= convergence_config.max_labels_budget
            if convergence_config.max_labels_budget is not None
            else False
        )
        target_successes_reached = (
            n_total_target_successes >= convergence_config.target_successes
            if convergence_config.target_successes is not None
            else False
        )
        consecutive_failures_exceeded = (
            n_consecutive_failures >= convergence_config.max_consecutive_failures
            if convergence_config.max_consecutive_failures is not None
            else False
        )
        if (
            max_labels_exceeded
            or target_successes_reached
            or consecutive_failures_exceeded
        ):
            mle_message = (
                f"Max labels budget ({convergence_config.max_labels_budget}) exceeded!"
                if max_labels_exceeded
                else None
            )
            tsr_message = (
                f"Target successes ({convergence_config.target_successes}) reached!"
                if target_successes_reached
                else None
            )
            cfe_message = (
                f"Consecutive failures ({convergence_config.max_consecutive_failures}) exceeded!"
                if consecutive_failures_exceeded
                else None
            )
            return True, [
                m for m in [mle_message, tsr_message, cfe_message] if m is not None
            ]
        else:
            return False, []

    def _update_metrics(
        self,
        iteration_target_successes: int,
        n_consecutive_failures: int,
        al_iteration_result: ActiveLearningIterationResult,
    ):
        self.al_simulation_result.iteration_target_successes.append(
            iteration_target_successes
        )
        self.al_simulation_result.iteration_consecutive_failures.append(
            n_consecutive_failures
        )
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
        current_data_with_masking, n_start_data = self._get_start_data()
        n_total_suggestions = 0
        n_total_target_successes = 0
        n_consecutive_failures = 0
        n_sim_data_total = len(self.al_simulation_config.simulation_data)
        for iteration in range(
            _ActiveLearningSimulationFixedParameters.n_max_iterations()
        ):
            if n_total_suggestions + n_start_data >= n_sim_data_total:
                # No new data left
                logger.info(
                    f"AL - Simulation has no new data left to label after {iteration} iterations!"
                )
                self.al_simulation_result.stop_reasons = ["No new data left to label!"]
                return TaskDTO(
                    status=TaskStatus.FINISHED,
                    al_simulation_result=self.al_simulation_result,
                )

            # Run iteration
            al_iteration_result = self._run_single_iteration(
                iteration_number=iteration,
                n_total_suggestions=n_total_suggestions,
                current_training_data=current_data_with_masking,
                embeddings=embeddings,
            )
            update_dto_callback(
                TaskDTO(
                    status=TaskStatus.RUNNING, al_iteration_result=al_iteration_result
                )
            )

            # Update iteration metrics
            iteration_suggestions = set(al_iteration_result.suggestions)
            n_total_suggestions += len(iteration_suggestions)
            iteration_target_successes = self._calculate_target_successes(
                iteration_suggestions
            )
            n_total_target_successes += iteration_target_successes
            n_consecutive_failures = (
                0 if iteration_target_successes > 0 else n_consecutive_failures + 1
            )
            self._update_metrics(
                iteration_target_successes=iteration_target_successes,
                n_consecutive_failures=n_consecutive_failures,
                al_iteration_result=al_iteration_result,
            )

            # Check convergence
            converged, stop_reasons = self._check_convergence(
                n_total_suggestions=n_total_suggestions,
                n_total_target_successes=n_total_target_successes,
                n_consecutive_failures=n_consecutive_failures,
            )
            if converged:
                logger.info(
                    f"AL - Simulation converged after {iteration + 1} iterations!"
                )
                self.al_simulation_result.stop_reasons = stop_reasons
                return TaskDTO(
                    status=TaskStatus.FINISHED,
                    al_simulation_result=self.al_simulation_result,
                )

            # Next iteration with updated training data
            current_data_with_masking = [
                data_point.set_label(
                    self.all_simulation_data_dict[data_point.seq_id].label
                )
                if data_point.seq_id in iteration_suggestions
                else data_point
                for data_point in current_data_with_masking
            ]

        # Max iterations exceeded without convergence
        logger.info("AL - Simulation max iterations exceeded without convergence!")
        self.al_simulation_result.stop_reasons = [
            f"Maximum number of iterations ({_ActiveLearningSimulationFixedParameters.n_max_iterations()}) "
            f"exceeded without convergence!"
        ]
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
