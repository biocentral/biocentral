import torch

from junban import PipelineStep
from typing import Dict, Optional, Tuple, Literal, List
from biotrainer_core.data_classes import SequenceData

from ....al_config import (
    ActiveLearningOptimizationMode,
)

from ..al_context import ALContext


class InferenceStep(PipelineStep[ALContext]):
    def _check_entry_assumptions(self, context: ALContext) -> bool:
        assert len(context.inference_data) > 0
        if context.uses_biotrainer():
            assert context.biotrainer_result is not None
        return True

    def _check_exit_assumptions(self, context: ALContext) -> bool:
        assert len(context.predictions) > 0
        assert context.uncertainty is not None
        assert context.desirability is not None
        return True

    def get_start_message(self) -> str:
        return "Running inference on unlabeled data..."

    def get_end_message(self) -> str:
        return "Finished inference."

    @staticmethod
    def _random_classification_predictions(
        train_data: Dict[str, SequenceData],
        n_inference: int,
        uncertainty_strategy: str,
        class_str2int: Dict[str, int],
        discrete_targets: Optional[List[str]] = None,
    ) -> Tuple[List, List, torch.Tensor]:
        """Generate random class-probability predictions for classification."""

        # Calculate probability of target class in training data
        al_targets = set([t.lower() for t in discrete_targets or []])
        assert len(al_targets) > 0, (
            "No target classes given for random classification predictions!"
        )
        assert all(t in class_str2int for t in al_targets), (
            "Target classes must be in class_str2int!"
        )

        train_labels = [
            str(data_point.get_target()).lower() for data_point in train_data.values()
        ]
        train_labels_set = set(train_labels)
        assert all(t in class_str2int for t in train_labels_set), (
            "Training labels must be in class_str2int!"
        )
        for class_label in class_str2int.keys():
            if class_label not in train_labels_set:
                train_labels.append(
                    class_label
                )  # Have at least one entry for each class

        train_labels = torch.tensor(
            [class_str2int[str(t).lower()] for t in train_labels]
        )
        class_counts = torch.bincount(train_labels)
        class_probabilities = class_counts.float() / len(train_labels)
        mean_al_target_prob = (
            class_probabilities[[class_str2int[t] for t in al_targets]].mean().item()
        )

        # Sample one probability distribution over classes per inference sample.
        # Shape: (n_inference, n_classes), each row sums to 1.
        concentration = class_counts.float()
        random_means = (
            torch.distributions.Dirichlet(concentration).sample((n_inference,)).tolist()
        )
        class_int2str = {v: k.lower() for k, v in class_str2int.items()}
        assert len(class_int2str) == len(class_str2int), (
            "Found duplicated class labels in class dictionary!"
        )

        random_predictions = [
            class_int2str[torch.max(torch.tensor(m), dim=0)[1].item()]
            for m in random_means
        ]

        # Generate uncertainties
        uncertainty = InferenceStep._generate_uncertainty(
            n_inference,
            uncertainty_strategy,
            task_type="classification",
            target_prob=mean_al_target_prob,
        )

        return random_means, random_predictions, uncertainty

    @staticmethod
    def _random_regression_predictions(
        train_data: Dict[str, SequenceData],
        n_inference: int,
        uncertainty_strategy: str,
    ) -> Tuple[List, List, torch.Tensor]:
        """Generate random predictions for regression."""
        train_labels = torch.tensor(
            [float(data_point.get_target()) for data_point in train_data.values()]
        )
        y_min = train_labels.min().item()
        y_max = train_labels.max().item()

        # Sample uniformly between min and max
        means = [m.item() for m in torch.rand(n_inference) * (y_max - y_min) + y_min]
        preds = list(means)

        # Generate uncertainties
        uncertainty = InferenceStep._generate_uncertainty(
            n_inference,
            uncertainty_strategy,
            task_type="regression",
            train_std=train_labels.std().item(),
            train_range=y_max - y_min,
        )

        return means, preds, uncertainty

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
                    uncertainty_val = torch.tensor(0.0)
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
        context: ALContext,
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
        n_inference = len(context.inference_data)
        class_str2int = {
            label.lower(): idx
            for idx, label in enumerate(list(context.all_labels_in_data or {}))
        }
        if task_type == "classification":
            means, preds, uncertainty = self._random_classification_predictions(
                train_data=train_data,
                n_inference=n_inference,
                discrete_targets=context.al_discrete_targets,
                uncertainty_strategy=uncertainty_strategy,
                class_str2int=class_str2int,
            )
        else:  # regression
            means, preds, uncertainty = self._random_regression_predictions(
                train_data=train_data,
                n_inference=n_inference,
                uncertainty_strategy=uncertainty_strategy,
            )
        desirability = self._calculate_desirability(
            context=context,
            predicted_means=torch.tensor(means),
            class_str2int=class_str2int,
        )

        return preds, uncertainty, desirability

    def _handle_biotrainer_result(
        self, context: ALContext
    ) -> Tuple[List, torch.Tensor, torch.Tensor]:
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
        if context.al_optimization_mode == ActiveLearningOptimizationMode.DISCRETE:
            uncertainty = torch.tensor(
                [pred.bald_score for pred in ordered_predictions]
            )
        else:  # mcd_std for regression
            uncertainty = torch.tensor([pred.mcd_std for pred in ordered_predictions])
        desirability = self._calculate_desirability(
            context=context,
            predicted_means=means,
            class_str2int=result.derived_values.class_str2int,
        )

        return preds, uncertainty, desirability

    @staticmethod
    def _calculate_desirability(
        context: ALContext,
        predicted_means: torch.Tensor,
        class_str2int: Optional[dict] = None,
    ) -> torch.Tensor:
        """Calculate desirability based on distance penalty to target value/label.
        Higher desirability = closer to target value/label => Better acquisition scoring.
        """
        # Distance penalty: Lower is better
        dist = InferenceStep._calculate_distance_penalty(
            predicted_means,
            al_optimization_mode=context.al_optimization_mode,
            target_value=context.al_target_value,
            target_lb=context.al_target_lb,
            target_ub=context.al_target_ub,
            discrete_targets=context.al_discrete_targets,
            class_str2int=class_str2int,
        )

        # Proximity: Higher is better
        proximity = dist.max() - dist
        return proximity

    @staticmethod
    def _calculate_distance_penalty(
        means: torch.Tensor,
        al_optimization_mode: ActiveLearningOptimizationMode,
        target_value: Optional[float] = None,
        target_lb: Optional[float] = None,
        target_ub: Optional[float] = None,
        class_str2int: Optional[dict] = None,
        discrete_targets: Optional[List[str]] = None,
    ) -> torch.Tensor:
        match al_optimization_mode:
            case ActiveLearningOptimizationMode.MAXIMIZE:
                return means.max() - means
            case ActiveLearningOptimizationMode.MINIMIZE:
                return means
            case ActiveLearningOptimizationMode.VALUE:
                target_val = target_value
                assert target_val is not None, (
                    "Target value must be provided for VALUE optimization mode"
                )
                dist = torch.abs(target_val - means)
                return dist
            case ActiveLearningOptimizationMode.INTERVAL:
                dist = torch.zeros_like(means)
                lb, ub = target_lb, target_ub
                assert lb is not None and ub is not None, (
                    "Target bounds must be provided for INTERVAL optimization mode"
                )
                below_lb = means < lb
                above_ub = means > ub
                dist[below_lb] = lb - means[below_lb]
                dist[above_ub] = means[above_ub] - ub
                return dist
            case ActiveLearningOptimizationMode.DISCRETE:
                assert class_str2int is not None
                assert len(class_str2int) == means.shape[1], (
                    f"Mismatch between number of classes and means shape: "
                    f"{len(class_str2int)} != {means.shape[1]}. "
                    f"This means that the model did not predict "
                    f"a value for each possible class!"
                )

                target_classes = discrete_targets or []
                assert len(target_classes) > 0, (
                    "No target classes given for discrete optimization!"
                )

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
                raise ValueError(f"Invalid optimization mode: {al_optimization_mode}")

    def _execute(self, context: ALContext) -> ALContext:
        if context.uses_biotrainer():
            preds, uncertainty, desirability = self._handle_biotrainer_result(context)
        else:
            preds, uncertainty, desirability = self._random_baseline_inference(
                context, context.al_task_type, uncertainty_strategy="constant", seed=42
            )
        context.predictions = preds
        context.uncertainty = uncertainty
        context.desirability = desirability
        return context
