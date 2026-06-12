import torch

from junban import PipelineStep
from typing import Dict, Optional, Tuple, Literal, List
from biotrainer_core.data_classes import SequenceData

from ....al_config import (
    ActiveLearningOptimizationMode,
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
)

from ..screening_pipeline_context import ScreeningPipelineContext


class InferenceStep(PipelineStep[ScreeningPipelineContext]):
    def _check_entry_assumptions(self, context: ScreeningPipelineContext) -> bool:
        assert len(context.inference_data) > 0
        if context.uses_biotrainer():
            assert context.biotrainer_result is not None
        return True

    def _check_exit_assumptions(self, context: ScreeningPipelineContext) -> bool:
        assert len(context.predictions) > 0
        assert context.uncertainty is not None
        assert context.desirability is not None
        return True

    def get_start_message(self) -> str:
        return "Running inference on unlabeled data..."

    def get_end_message(self) -> str:
        return "Finished inference."

    @staticmethod
    def _get_target_index(discrete_targets, discrete_labels):
        """Find the index of the target label in the list of discrete labels."""
        target = discrete_targets[0]
        labels = discrete_labels
        for idx, label in enumerate(labels):
            if label.lower() == target.lower():
                return idx
        raise ValueError(f"Target '{target}' not found in discrete labels: {labels}")

    @staticmethod
    def _random_classification_predictions(
        train_data: Dict[str, SequenceData],
        n_inference: int,
        al_campaign_config: ActiveLearningCampaignConfig,
        al_iteration_config: ActiveLearningIterationConfig,
        uncertainty_strategy: str,
    ) -> Tuple[List, torch.Tensor]:
        """Generate random predictions for classification."""
        # Get target index
        tgt_idx = InferenceStep._get_target_index(
            discrete_targets=al_campaign_config.discrete_targets,
            discrete_labels=al_iteration_config.get_all_labels(),
        )

        # Calculate probability of target class in training data
        train_labels = torch.tensor(
            [data_point.get_target() for data_point in train_data.values()]
        )
        target_prob = (train_labels == tgt_idx).float().mean().item()

        # Sample predictions based on training distribution
        # Probability that each inference sample belongs to target class
        means = torch.rand(n_inference) < target_prob
        means = [m.item() for m in means.float()]

        # Generate uncertainties
        uncertainty = InferenceStep._generate_uncertainty(
            n_inference,
            uncertainty_strategy,
            task_type="classification",
            target_prob=target_prob,
        )

        return means, uncertainty

    @staticmethod
    def _random_regression_predictions(
        train_data: Dict[str, SequenceData],
        n_inference: int,
        al_campaign_config: ActiveLearningCampaignConfig,
        uncertainty_strategy: str,
    ) -> Tuple[List, torch.Tensor]:
        """Generate random predictions for regression."""
        train_labels = torch.tensor(
            [float(data_point.get_target()) for data_point in train_data.values()]
        )
        y_min = train_labels.min().item()
        y_max = train_labels.max().item()

        # Sample uniformly between min and max
        means = [m.item() for m in torch.rand(n_inference) * (y_max - y_min) + y_min]

        # Generate uncertainties
        uncertainty = InferenceStep._generate_uncertainty(
            n_inference,
            uncertainty_strategy,
            task_type="regression",
            train_std=train_labels.std().item(),
            train_range=y_max - y_min,
        )

        return means, uncertainty

    @staticmethod
    def _generate_uncertainty(
        n_samples: int,
        strategy: str,
        task_type: str,
        target_prob: Optional[float] = None,
        train_std: Optional[float] = None,
        train_range: Optional[float] = None,
    ) -> torch.Tensor:
        """
        Generate uncertainty values based on strategy.

        Strategies:
            - constant: Based on training data statistics (most principled)
            - random: Random values to simulate uninformed model
            - uniform: All samples get maximum uncertainty (pure exploration)
        """
        if strategy == "constant":
            if task_type == "classification":
                # Use entropy of training distribution as constant uncertainty
                # Binary entropy: -p*log(p) - (1-p)*log(1-p)
                p = target_prob
                if p == 0 or p == 1:
                    uncertainty_val = 0.0
                else:
                    uncertainty_val = -p * torch.log(torch.tensor(p)) - (
                        1 - p
                    ) * torch.log(torch.tensor(1 - p))
                uncertainty = torch.full((n_samples,), uncertainty_val.item())
            else:  # regression
                # Use training data standard deviation
                uncertainty = torch.full((n_samples,), train_std)

        # elif strategy == "random":
        #     if task_type == "classification":
        #         # Random uncertainty between 0 and max entropy (ln(2) for binary)
        #         max_entropy = torch.log(torch.tensor(2.0))
        #         uncertainty = torch.rand(n_samples) * max_entropy
        #     else:  # regression
        #         # Random uncertainty between 0 and training std
        #         uncertainty = torch.rand(n_samples) * train_std
        #
        # elif strategy == "uniform":
        #     if task_type == "classification":
        #         # Maximum uncertainty (uniform distribution over classes)
        #         max_entropy = torch.log(torch.tensor(2.0))  # Binary case
        #         uncertainty = torch.full((n_samples,), max_entropy.item())
        #     else:  # regression
        #         # Use training std as uniform uncertainty
        #         uncertainty = torch.full((n_samples,), train_std)
        #
        else:
            raise ValueError(f"Unknown uncertainty strategy: {strategy}")

        return uncertainty

    def _random_baseline_inference(
        self,
        context: ScreeningPipelineContext,
        task_type: Literal["classification", "regression"],
        uncertainty_strategy: Literal["constant", "random", "uniform"] = "constant",
        seed: Optional[int] = None,
    ) -> Tuple[List, torch.Tensor, torch.Tensor]:
        """
        Random baseline that mimics the train_and_inference interface.

        Args:
            task_type: 'classification' or 'regression'
            uncertainty_strategy: How to assign uncertainties:
                - 'constant': Use a constant uncertainty for all samples
                - 'random': Sample random uncertainties
                - 'uniform': All samples get the same fixed uncertainty value
            seed: Random seed for reproducibility

        Returns:
            scores: tensor of shape (n_inference_data)
            means: predicted means
            uncertainties: predicted uncertainties
        """
        if seed is not None:
            torch.manual_seed(seed)

        train_data = context.training_data
        al_campaign_config = context.al_campaign_config
        al_iteration_config = context.al_iteration_config
        n_inference = len(context.inference_data)

        if task_type == "classification":
            means, uncertainty = self._random_classification_predictions(
                train_data,
                n_inference,
                al_campaign_config,
                al_iteration_config,
                uncertainty_strategy,
            )
            desirability = torch.tensor(means)
        else:  # regression
            means, uncertainty = self._random_regression_predictions(
                train_data, n_inference, al_campaign_config, uncertainty_strategy
            )
            desirability = self._calculate_desirability(
                torch.tensor(means), al_campaign_config
            )

        # Predictions are means here
        return means, uncertainty, desirability

    def _handle_biotrainer_result(self, context: ScreeningPipelineContext):
        # Extract predictions and uncertainties
        result = context.biotrainer_result
        predictions_dict = {pred.seq_id: pred for pred in result.predictions}
        ordered_predictions = [
            predictions_dict[key] for key in context.inference_data.keys()
        ]
        assert (
            len(ordered_predictions)
            == len(context.inference_data)
            == len(result.predictions)
        )
        means = torch.tensor([pred.mcd_mean for pred in ordered_predictions])
        preds = [pred.prediction for pred in ordered_predictions]
        if (
            context.al_campaign_config.optimization_mode
            == ActiveLearningOptimizationMode.DISCRETE
        ):
            uncertainty = torch.tensor(
                [pred.bald_score for pred in ordered_predictions]
            )
        else:  # mcd_std for regression
            uncertainty = torch.tensor([pred.mcd_std for pred in ordered_predictions])
        desirability = self._calculate_desirability(
            means,
            context.al_campaign_config,
            class_str2int=result.derived_values.class_str2int,
        )

        return preds, uncertainty, desirability

    @staticmethod
    def _calculate_desirability(
        predicted_means: torch.Tensor,
        al_campaign_config: ActiveLearningCampaignConfig,
        class_str2int: Optional[dict] = None,
    ) -> torch.Tensor:
        """Calculate desirability based on distance penalty to target value/label.
        Higher desirability = closer to target value/label => Better acquisition scoring.
        """
        # Distance penalty: Lower is better
        dist = InferenceStep._calculate_distance_penalty(
            predicted_means,
            al_campaign_config=al_campaign_config,
            class_str2int=class_str2int,
        )

        # Proximity: Higher is better
        proximity = dist.max() - dist
        return proximity

    @staticmethod
    def _calculate_distance_penalty(
        means: torch.Tensor,
        al_campaign_config: ActiveLearningCampaignConfig,
        class_str2int: Optional[dict] = None,
    ) -> torch.Tensor:
        mode = al_campaign_config.optimization_mode
        match mode:
            case ActiveLearningOptimizationMode.MAXIMIZE:
                return means.max() - means
            case ActiveLearningOptimizationMode.MINIMIZE:
                return means
            case ActiveLearningOptimizationMode.VALUE:
                target_val = al_campaign_config.target_value
                dist = torch.abs(target_val - means)
                return dist
            case ActiveLearningOptimizationMode.INTERVAL:
                dist = torch.zeros_like(means)
                lb, ub = al_campaign_config.target_lb, al_campaign_config.target_ub
                below_lb = means < lb
                above_ub = means > ub
                dist[below_lb] = lb - means[below_lb]
                dist[above_ub] = means[above_ub] - ub
                return dist
            case ActiveLearningOptimizationMode.DISCRETE:
                assert class_str2int is not None
                target_classes = al_campaign_config.discrete_targets
                class_str2int_lower = {
                    cl.lower(): idx for cl, idx in class_str2int.items()
                }
                target_class_indexes = [
                    class_str2int_lower[tc.lower()] for tc in target_classes
                ]

                # Penalty: 1.0 for non-target classes, (1 - prob) for target classes
                penalty = torch.ones_like(means)
                penalty[:, target_class_indexes] = 1.0 - means[:, target_class_indexes]
                return penalty.min(dim=1)[0]  # Minimum penalty across target classes

            case _:
                raise ValueError(f"Invalid optimization mode: {mode}")

    def _execute(self, context: ScreeningPipelineContext) -> ScreeningPipelineContext:
        if context.uses_biotrainer():
            preds, uncertainty, desirability = self._handle_biotrainer_result(context)
        else:
            mode = context.al_campaign_config.optimization_mode
            task_type = (
                "classification"
                if mode == ActiveLearningOptimizationMode.DISCRETE
                else "regression"
            )
            preds, uncertainty, desirability = self._random_baseline_inference(
                context, task_type, uncertainty_strategy="constant", seed=42
            )
        context.predictions = preds
        context.uncertainty = uncertainty
        context.desirability = desirability
        return context
