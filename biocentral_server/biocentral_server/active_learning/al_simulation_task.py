import torch
import random
import numpy as np
import torchmetrics

from biotrainer_core.functions.seeding import seed_all
from biotrainer_core.data_classes import SequenceData
from typing import Callable, Tuple, List, Optional, Set, Dict
from biotrainer.shared import SimpleTorchMetricsCalculator, Bootstrapper

from .al_iteration_task import ActiveLearningIterationTask
from .al_config import (
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningSimulationConfig,
    ActiveLearningOptimizationMode,
)

from ..utils import get_logger
from ..server_management import (
    TaskInterface,
    TaskDTO,
    TaskStatus,
    ActiveLearningIterationResult,
    ActiveLearningSimulationResult,
    PreEmbedMixin,
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


class ActiveLearningSimulationTask(TaskInterface, PreEmbedMixin):
    def __init__(
        self,
        al_campaign_config: ActiveLearningCampaignConfig,
        al_simulation_config: ActiveLearningSimulationConfig,
    ):
        super().__init__()
        self.al_campaign_config = al_campaign_config
        self.al_simulation_config = al_simulation_config

        self.all_labels_dict: Dict[str, str] = {
            data_point.seq_id: str(data_point.label)
            for data_point in self.al_simulation_config.simulation_data
        }
        # Save all labels for discrete optimization mode to avoid problems with label masking
        self.all_discrete_labels_set: Optional[Set[str]] = (
            {
                str(data_point.label).lower()
                for data_point in self.al_simulation_config.simulation_data
                if data_point.label is not None
            }
            if self.al_campaign_config.optimization_mode
            == ActiveLearningOptimizationMode.DISCRETE
            else None
        )

        self.al_simulation_result = ActiveLearningSimulationResult(
            campaign_name=self.al_campaign_config.name,
            potential_hits=self._get_potential_hits(),
        )

    def _get_potential_hits(self) -> List[str]:
        sim_data_ids = set(
            [
                data_point.seq_id
                for data_point in self.al_simulation_config.simulation_data
            ]
        )
        # Re-use the hits calculation to calculate all potential targets across the simulation data
        return self._calculate_hits(iteration_suggestions=sim_data_ids)

    def _get_start_data(self) -> Tuple[List[SequenceData], int]:
        start_ids_set: set[str]
        if self.al_simulation_config.start_ids:
            start_ids_set = set(self.al_simulation_config.start_ids)
        else:
            random_instance = random.Random(self.al_campaign_config.seed)
            random_sample = random_instance.sample(
                self.al_simulation_config.simulation_data,
                self.al_simulation_config.n_start,
            )
            start_ids_set = set([data_point.seq_id for data_point in random_sample])
        return [
            data_point.copy_with_label(label=data_point.label, set_name="train")
            if data_point.seq_id in start_ids_set
            else data_point.copy_without_label()
            for data_point in self.al_simulation_config.simulation_data
        ], len(start_ids_set)

    def _run_single_iteration(
        self,
        iteration_number: int,
        n_total_suggestions: int,
        current_training_data: List[SequenceData],
        embeddings: List[SequenceData],
        update_dto_callback: Callable,
    ) -> ActiveLearningIterationResult:
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

        al_iteration_task = ActiveLearningIterationTask(
            al_campaign_config=self.al_campaign_config,
            al_iteration_config=al_iteration_config,
            embeddings=embeddings,
            all_labels_in_data=self.all_discrete_labels_set,
        )
        al_iteration_dto: Optional[TaskDTO] = None
        for current_dto in self.run_subtask(al_iteration_task):
            al_iteration_dto = current_dto
            update_dto_callback(al_iteration_dto)

        if not al_iteration_dto or al_iteration_dto.al_iteration_result is None:
            update_dto_callback(TaskDTO.errored("AL iteration failed!"))
            raise Exception("No AL iteration result received!")

        return al_iteration_dto.al_iteration_result

    def _calculate_hits(self, iteration_suggestions: Set[str]) -> List[str]:
        """Calculate the number of target successes (hits) for the given iteration suggestions (seq_ids)."""
        min_max_percentile = (
            _ActiveLearningSimulationFixedParameters.min_max_percentile()
        )
        target_delta = _ActiveLearningSimulationFixedParameters.target_delta()
        suggestion_labels = {
            seq_id: self.all_labels_dict[seq_id] for seq_id in iteration_suggestions
        }

        mode = self.al_campaign_config.optimization_mode
        match mode:
            case ActiveLearningOptimizationMode.MAXIMIZE:
                all_labels_float = {
                    seq_id: float(self.all_labels_dict[seq_id])
                    for seq_id in self.all_labels_dict
                }
                suggestion_labels_float = {
                    seq_id: float(label) for seq_id, label in suggestion_labels.items()
                }
                max_percentile = np.percentile(
                    list(all_labels_float.values()), 100 - min_max_percentile
                )
                over_percentile = [
                    sugg_id
                    for sugg_id, sugg_label in suggestion_labels_float.items()
                    if sugg_label >= max_percentile
                ]
                assert len(over_percentile) == len(set(over_percentile)), (
                    f"Found duplicates: {over_percentile}"
                )
                return over_percentile
            case ActiveLearningOptimizationMode.MINIMIZE:
                all_labels_float = {
                    seq_id: float(self.all_labels_dict[seq_id])
                    for seq_id in self.all_labels_dict
                }
                suggestion_labels_float = {
                    seq_id: float(label) for seq_id, label in suggestion_labels.items()
                }
                min_percentile = np.percentile(
                    list(all_labels_float.values()), min_max_percentile
                )
                under_percentile = [
                    sugg_id
                    for sugg_id, sugg_label in suggestion_labels_float.items()
                    if sugg_label <= min_percentile
                ]
                assert len(under_percentile) == len(set(under_percentile)), (
                    f"Found duplicates: {under_percentile}"
                )
                return under_percentile
            case ActiveLearningOptimizationMode.VALUE:
                target_value = self.al_campaign_config.target_value
                suggestion_labels_float = {
                    seq_id: float(label) for seq_id, label in suggestion_labels.items()
                }
                within_delta = [
                    sugg_id
                    for sugg_id, sugg_label in suggestion_labels_float.items()
                    if abs(sugg_label - target_value) <= target_delta
                ]
                assert len(within_delta) == len(set(within_delta)), (
                    f"Found duplicates: {within_delta}"
                )
                return within_delta
            case ActiveLearningOptimizationMode.INTERVAL:
                target_lb, target_ub = (
                    self.al_campaign_config.target_lb,
                    self.al_campaign_config.target_ub,
                )
                suggestion_labels_float = {
                    seq_id: float(label) for seq_id, label in suggestion_labels.items()
                }
                within_interval = [
                    sugg_id
                    for sugg_id, sugg_label in suggestion_labels_float.items()
                    if target_lb <= sugg_label <= target_ub
                ]
                assert len(within_interval) == len(set(within_interval)), (
                    f"Found duplicates: {within_interval}"
                )
                return within_interval
            case ActiveLearningOptimizationMode.DISCRETE:
                target_labels = self.al_campaign_config.discrete_targets
                correct = [
                    sugg_id
                    for sugg_id, sugg_label in suggestion_labels.items()
                    if sugg_label in target_labels
                ]
                assert len(correct) == len(set(correct)), f"Found duplicates: {correct}"
                return correct

    def _check_convergence(
        self,
        n_total_suggestions: int,
        n_total_hits: int,
        n_consecutive_failures: int,
    ) -> Tuple[bool, List[str]]:
        convergence_config = self.al_simulation_config.convergence_config
        max_labels_exceeded = (
            n_total_suggestions >= convergence_config.max_labels_budget
            if convergence_config.max_labels_budget is not None
            else False
        )
        n_hits_reached = (
            n_total_hits >= convergence_config.n_hits
            if convergence_config.n_hits is not None
            else False
        )
        consecutive_failures_exceeded = (
            n_consecutive_failures >= convergence_config.max_consecutive_failures
            if convergence_config.max_consecutive_failures is not None
            else False
        )
        if max_labels_exceeded or n_hits_reached or consecutive_failures_exceeded:
            mle_message = (
                f"Max labels budget ({convergence_config.max_labels_budget}) exceeded!"
                if max_labels_exceeded
                else None
            )
            n_hits_message = (
                f"Number of hits ({convergence_config.n_hits}) accomplished!"
                if n_hits_reached
                else None
            )
            cfe_message = (
                f"Consecutive failures ({convergence_config.max_consecutive_failures}) exceeded!"
                if consecutive_failures_exceeded
                else None
            )
            return True, [
                m for m in [mle_message, n_hits_message, cfe_message] if m is not None
            ]
        else:
            return False, []

    def _update_classification_metrics(
        self,
        al_iteration_result: ActiveLearningIterationResult,
    ):
        all_preds_vs_actual = {
            data_point.entity_id: (
                str(data_point.prediction).lower(),
                str(self.all_labels_dict[data_point.entity_id]).lower(),
            )
            for data_point in al_iteration_result.results
        }
        suggestion_preds_vs_actual = {
            entity_id: p_v_a
            for entity_id, p_v_a in all_preds_vs_actual.items()
            if entity_id in set(al_iteration_result.suggestions)
        }
        all_labels_list = list(self.all_discrete_labels_set or [])

        accuracy_metric = torchmetrics.Accuracy(
            task="multiclass", num_classes=len(all_labels_list)
        )
        metrics_calculator = SimpleTorchMetricsCalculator(
            device=torch.device("cpu"), name="accuracy", torch_metric=accuracy_metric
        )
        # Calculate accuracy for all predictions
        all_preds_dict = {
            entity_id: torch.tensor(all_labels_list.index(p[0]))
            for entity_id, p in all_preds_vs_actual.items()
        }

        all_actuals_dict = {
            entity_id: torch.tensor(all_labels_list.index(p[1]))
            for entity_id, p in all_preds_vs_actual.items()
        }
        seq_ids = list(all_preds_dict.keys())

        bootstrapped_metrics_all = Bootstrapper._do_bootstrapping(
            iterations=30,
            sample_size=-1,
            confidence_level=0.05,
            seq_ids=seq_ids,
            all_predictions_dict=all_preds_dict,
            all_targets_dict=all_actuals_dict,
            metrics_calculator=metrics_calculator,
        )
        metrics_calculator.reset()

        # Calculate accuracy for suggestions only
        sugg_preds_dict = {
            entity_id: torch.tensor(all_labels_list.index(p[0]))
            for entity_id, p in suggestion_preds_vs_actual.items()
        }

        sugg_actuals_dict = {
            entity_id: torch.tensor(all_labels_list.index(p[1]))
            for entity_id, p in suggestion_preds_vs_actual.items()
        }
        seq_ids = list(sugg_preds_dict.keys())

        bootstrapped_metrics_suggs = Bootstrapper._do_bootstrapping(
            iterations=30,
            sample_size=-1,
            confidence_level=0.05,
            seq_ids=seq_ids,
            all_predictions_dict=sugg_preds_dict,
            all_targets_dict=sugg_actuals_dict,
            metrics_calculator=metrics_calculator,
        )

        self.al_simulation_result.iteration_metrics_total.extend(
            bootstrapped_metrics_all
        )
        self.al_simulation_result.iteration_metrics_suggestions.extend(
            bootstrapped_metrics_suggs
        )

    def _update_regression_metrics(
        self, al_iteration_result: ActiveLearningIterationResult
    ):
        all_preds_vs_actual = {
            data_point.entity_id: (
                float(data_point.prediction),
                float(self.all_labels_dict[data_point.entity_id]),
            )
            for data_point in al_iteration_result.results
        }
        suggestion_preds_vs_actual = {
            entity_id: p_v_a
            for entity_id, p_v_a in all_preds_vs_actual.items()
            if entity_id in set(al_iteration_result.suggestions)
        }

        rmse_metric = torchmetrics.MeanSquaredError(squared=False)
        metrics_calculator = SimpleTorchMetricsCalculator(
            device=torch.device("cpu"), name="rmse", torch_metric=rmse_metric
        )

        # Calculate RMSE for all predictions
        all_preds_dict = {
            entity_id: torch.tensor(p[0])
            for entity_id, p in all_preds_vs_actual.items()
        }
        all_actuals_dict = {
            entity_id: torch.tensor(p[1])
            for entity_id, p in all_preds_vs_actual.items()
        }
        seq_ids = list(all_preds_dict.keys())

        bootstrapped_metrics_all = Bootstrapper._do_bootstrapping(
            iterations=30,
            sample_size=-1,
            confidence_level=0.05,
            seq_ids=seq_ids,
            all_predictions_dict=all_preds_dict,
            all_targets_dict=all_actuals_dict,
            metrics_calculator=metrics_calculator,
        )
        metrics_calculator.reset()

        # Calculate RMSE for suggestions only
        sugg_preds_dict = {
            entity_id: torch.tensor(p[0])
            for entity_id, p in suggestion_preds_vs_actual.items()
        }
        sugg_actuals_dict = {
            entity_id: torch.tensor(p[1])
            for entity_id, p in suggestion_preds_vs_actual.items()
        }
        sugg_seq_ids = list(sugg_preds_dict.keys())

        bootstrapped_metrics_suggs = Bootstrapper._do_bootstrapping(
            iterations=30,
            sample_size=-1,
            confidence_level=0.05,
            seq_ids=sugg_seq_ids,
            all_predictions_dict=sugg_preds_dict,
            all_targets_dict=sugg_actuals_dict,
            metrics_calculator=metrics_calculator,
        )

        self.al_simulation_result.iteration_metrics_total.extend(
            bootstrapped_metrics_all
        )
        self.al_simulation_result.iteration_metrics_suggestions.extend(
            bootstrapped_metrics_suggs
        )

    def _update_metrics(
        self,
        iteration_hits: List[str],
        n_consecutive_failures: int,
        al_iteration_result: ActiveLearningIterationResult,
    ):
        self.al_simulation_result.iteration_hits.append(iteration_hits)
        self.al_simulation_result.iteration_consecutive_failures.append(
            n_consecutive_failures
        )

        if (
            self.al_campaign_config.optimization_mode
            == ActiveLearningOptimizationMode.DISCRETE
        ):
            self._update_classification_metrics(al_iteration_result)
        else:
            self._update_regression_metrics(al_iteration_result)

    def _run_simulation(
        self, embeddings: List[SequenceData], update_dto_callback: Callable
    ):
        # Set seed for simulation reproducibility
        seed_all(self.al_campaign_config.seed)

        current_data_with_masking, n_start_data = self._get_start_data()
        n_total_suggestions = 0
        n_total_hits = 0
        n_consecutive_failures = 0
        n_sim_data_total = len(self.al_simulation_config.simulation_data)
        for iteration_idx in range(
            _ActiveLearningSimulationFixedParameters.n_max_iterations()
        ):
            iteration = iteration_idx + 1
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
                update_dto_callback=update_dto_callback,
            )

            # Update iteration metrics
            iteration_suggestions = set(al_iteration_result.suggestions)
            n_total_suggestions += len(iteration_suggestions)
            iteration_hits = self._calculate_hits(iteration_suggestions)
            n_iteration_hits = len(iteration_hits)
            logger.info(
                f"Hits (target successes) for iteration {iteration}: {n_iteration_hits}"
            )
            n_total_hits += n_iteration_hits
            n_consecutive_failures = (
                0 if n_iteration_hits > 0 else n_consecutive_failures + 1
            )
            self._update_metrics(
                iteration_hits=iteration_hits,
                n_consecutive_failures=n_consecutive_failures,
                al_iteration_result=al_iteration_result,
            )

            # Check convergence
            converged, stop_reasons = self._check_convergence(
                n_total_suggestions=n_total_suggestions,
                n_total_hits=n_total_hits,
                n_consecutive_failures=n_consecutive_failures,
            )
            if converged:
                logger.info(f"AL - Simulation converged after {iteration} iterations!")
                self.al_simulation_result.stop_reasons = stop_reasons
                return TaskDTO(
                    status=TaskStatus.FINISHED,
                    al_simulation_result=self.al_simulation_result,
                )

            # Next iteration with updated training data
            current_data_with_masking = [
                data_point.copy_with_label(
                    label=self.all_labels_dict[data_point.seq_id],
                    set_name="train",
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
        simulation_data = self.al_simulation_config.simulation_data
        embedder_name = self.al_campaign_config.embedder_name
        error_dto, embeddings = self._pre_embed_with_db(
            embedder_name=embedder_name,
            sequence_input=simulation_data,
            reduced=True,
            update_dto_callback=update_dto_callback,
        )
        if error_dto:
            return error_dto
        assert embeddings is not None, (
            "embeddings is None after pre-embedding before active learning iteration!"
        )

        return self._run_simulation(embeddings, update_dto_callback)
