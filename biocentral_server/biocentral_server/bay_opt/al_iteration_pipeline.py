from __future__ import annotations

import random

import torch

from typing import List, Literal, Optional, Tuple, Dict, Callable
from biotrainer.protocols import Protocol
from biotrainer.utilities import get_device
from biotrainer.input_files import BiotrainerSequenceRecord

from .al_config import (
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningOptimizationMode,
    ActiveLearningModelType,
)
from .gaussian_process_models import (
    train_gp_model,
)

from ..utils import get_logger
from ..server_management import ActiveLearningResult, ActiveLearningIterationResult

logger = get_logger(__name__)


def get_datasets(
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    embd_records: List[BiotrainerSequenceRecord],
):
    """
    train_data = {"ids": [], "X": [], "y": []}
    inference_data = {"ids": [], "X": []}
    if dataset is empty, the type of 'X' will be a list.
    """
    mode = al_campaign_config.optimization_mode
    target_classes = {}
    if mode == ActiveLearningOptimizationMode.DISCRETE:
        all_labels = al_iteration_config.get_all_labels()
        target_classes = {label: idx for idx, label in enumerate(all_labels)}

    train_data = {"ids": [], "X": [], "y": []}
    inference_data = {"ids": [], "X": []}

    device = get_device()

    for embd_record in embd_records:
        target = embd_record.get_target()
        target = None if target is None or target == "None" else target
        if target is not None:  # Train Set
            train_data["ids"].append(embd_record.seq_id)
            train_data["X"].append(torch.tensor(embd_record.embedding))
            # Convert target
            if mode == ActiveLearningOptimizationMode.DISCRETE:
                if target in target_classes:
                    target = target_classes[target]
                else:
                    ValueError(
                        f"get_datasets: illegal label {target} in labels: {target_classes.keys()}"
                    )
            else:
                target = float(target)
            train_data["y"].append(target)
        else:  # Inference Set
            inference_data["ids"].append(embd_record.seq_id)
            embedding = (
                embd_record.embedding
                if isinstance(embd_record.embedding, torch.Tensor)
                else torch.tensor(embd_record.embedding)
            )
            inference_data["X"].append(embedding)

    if train_data["X"]:
        train_data["X"] = torch.stack(train_data["X"]).float()
        train_data["X"] = train_data["X"].to(device=device)
    if inference_data["X"]:
        inference_data["X"] = torch.stack(inference_data["X"]).float()
        inference_data["X"] = inference_data["X"].to(device=device)
    if train_data["y"]:
        train_data["y"] = torch.tensor(train_data["y"])
        train_data["y"] = train_data["y"].to(device=device)
    if mode == ActiveLearningOptimizationMode.DISCRETE and isinstance(
        train_data["y"], torch.Tensor
    ):
        train_data["y"] = torch.nn.functional.one_hot(train_data["y"], len(all_labels))
    return train_data, inference_data


def data_prep(
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    embeddings: List[BiotrainerSequenceRecord],
) -> tuple[dict[str, list], dict[str, list], List[BiotrainerSequenceRecord]]:
    """
    train_data = {"ids": [], "X": （n_sample, dim）, "y": (n_sample), (n_sample, n_class))}
    inference_data = {"ids": [], "X": []}
    dict[seq_id] = [seq, description, embedding]
    """

    seq_records = [
        data_point.to_biotrainer_seq_record()
        for data_point in al_iteration_config.iteration_data
    ]
    id2record = {seq_record.get_hash(): seq_record for seq_record in seq_records}
    embd_records = [
        id2record[seq_record.get_hash()].copy_with_embedding(seq_record.embedding)
        for seq_record in embeddings
    ]

    # train & test set split
    train_data, inference_data = get_datasets(
        al_campaign_config=al_campaign_config,
        al_iteration_config=al_iteration_config,
        embd_records=embd_records,
    )
    if len(train_data["ids"]) * len(inference_data) == 0:
        raise ValueError(
            "data_prep: training set or inference set is empty. Have you set feature_name?"
        )
    return train_data, inference_data, embd_records


def calculate_distance_penalty(
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
            class_str2int_lower = {cl.lower(): idx for cl, idx in class_str2int.items()}
            target_class_indexes = [
                class_str2int_lower[tc.lower()] for tc in target_classes
            ]

            # Penalty: 1.0 for non-target classes, (1 - prob) for target classes
            penalty = torch.ones_like(means)
            penalty[:, target_class_indexes] = 1.0 - means[:, target_class_indexes]
            return penalty.min(dim=1)[0]  # Minimum penalty across target classes

        case _:
            raise ValueError(f"Invalid optimization mode: {mode}")


def _extract_classification_predictions(
    prediction,
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
) -> Tuple[torch.Tensor, torch.Tensor]:
    """Extract means and uncertainties for classification task."""
    logger.info(f"Prediction mean: {prediction.mean}")

    tgt_idx = _get_target_index(
        discrete_targets=al_campaign_config.discrete_targets,
        discrete_labels=al_iteration_config.get_all_labels(),
    )

    means = prediction.mean[tgt_idx]
    uncertainty = prediction.covariance_matrix[tgt_idx].diag()

    return means, uncertainty


def _calculate_desirability(
    predicted_means: torch.Tensor,
    al_campaign_config: ActiveLearningCampaignConfig,
    class_str2int: Optional[dict] = None,
) -> torch.Tensor:
    """Calculate desirability based on distance penalty to target value/label.
    Higher desirability = closer to target value/label => Better acquisition scoring.
    """
    # Distance penalty: Lower is better
    dist = calculate_distance_penalty(
        predicted_means,
        al_campaign_config=al_campaign_config,
        class_str2int=class_str2int,
    )

    # Proximity: Higher is better
    proximity = dist.max() - dist
    return proximity


def _get_target_index(discrete_targets, discrete_labels):
    """Find the index of the target label in the list of discrete labels."""
    target = discrete_targets[0]
    labels = discrete_labels
    for idx, label in enumerate(labels):
        if label.lower() == target.lower():
            return idx
    raise ValueError(f"Target '{target}' not found in discrete labels: {labels}")


def _train_and_inference_gp(
    train_data: dict,
    inference_data: dict,
    task_type: Literal["classification", "regression"],
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    epoch: Optional[int] = None,
    inference_device: str = "cpu",
) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
    """
    Unified training and inference for GP models.

    Args:
        train_data: dict {'X': [], 'y': [], 'ids': []}
        inference_data: dict {'X': [], 'ids': []}
        task_type: 'classification' or 'regression'
        al_campaign_config: Campaign configuration
        al_iteration_config: Iteration configuration
        epoch: Number of training epochs (default: 200 for classification, 120 for regression)
        inference_device: Device to use for inference (default: 'cpu')

    Returns:
        scores: tensor of shape (n_inference_data)
        means: predicted means
        uncertainties: predicted uncertainties
    """
    # Validation
    if isinstance(train_data["X"], list) or isinstance(inference_data["X"], list):
        raise ValueError(f"train_and_inference_{task_type}: data should not be empty")

    # Set default epochs based on task type
    if epoch is None:
        epoch = 200 if task_type == "classification" else 120

    # Training
    model, likelihood = train_gp_model(
        train_data, task_type=task_type, epoch=epoch, device=get_device()
    )

    # Inference
    with torch.no_grad():
        # Move to inference device (CPU for memory limitations)
        model.to(device=inference_device)
        likelihood.to(device=inference_device)

        # Get predictions
        inference_x = inference_data["X"].to(device=inference_device)
        prediction = likelihood(model(inference_x))

        # Extract means and uncertainties based on task type
        if task_type == "classification":
            means, uncertainty = _extract_classification_predictions(
                prediction, al_campaign_config, al_iteration_config
            )
            desirability = means
        else:  # regression
            means = prediction.mean
            uncertainty = prediction.covariance_matrix.diag().sqrt()  # std
            desirability = _calculate_desirability(means, al_campaign_config)

        # Calculate acquisition scores
        beta = al_iteration_config.coefficient
        scores = _calculate_acquisition(
            desirability=desirability, uncertainty=uncertainty, beta=beta
        )

    return scores, means, uncertainty


def _train_and_inference_biotrainer(
    train_data: Dict[str, BiotrainerSequenceRecord],
    inference_data: Dict[str, BiotrainerSequenceRecord],
    task_type: Literal["classification", "regression"],
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    biotrainer_subtask_wrapper: Callable,
    all_target_classes: Optional[List[str]] = None,
) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
    """
    Unified training and inference for GP models.

    Args:
        train_data
        inference_data
        task_type: 'classification' or 'regression'
        al_campaign_config: Campaign configuration
        al_iteration_config: Iteration configuration
        epoch: Number of training epochs (default: 200 for classification, 120 for regression)
        inference_device: Device to use for inference (default: 'cpu')

    Returns:
        scores: tensor of shape (n_inference_data)
        means: predicted means
        uncertainties: predicted uncertainties
    """
    assert len(train_data) > 0 and len(inference_data) > 0, (
        "Biotrainer data must not be empty!"
    )

    # Create dummy test set
    # TODO Improve in biotrainer to not need a test set strictly
    first_embedding = next(iter(train_data.values())).embedding
    if al_campaign_config.optimization_mode == ActiveLearningOptimizationMode.DISCRETE:
        assert all_target_classes is not None, (
            "all_target_classes must be provided for discrete optimization"
        )
        test_data = [
            BiotrainerSequenceRecord(
                seq_id=f"DummyTestSeq{idx}",
                seq="DUMMY" * idx,
                embedding=torch.zeros_like(first_embedding),
                attributes={"set": "test", "target": target},
            )
            for idx, target in enumerate(all_target_classes)
        ]
    else:  # a single sequence is sufficient for regression
        test_data = [
            BiotrainerSequenceRecord(
                seq_id="DummyTestSeq",
                seq="DUMMY",
                embedding=torch.zeros_like(first_embedding),
                attributes={"set": "test", "target": "0"},
            )
        ]

    # Create validation set: Assign random seqs from train to validation
    val_data_k = max(1, len(train_data) // 10)
    val_data: List[BiotrainerSequenceRecord] = random.sample(
        list(train_data.values()), k=val_data_k
    )
    val_data = [
        BiotrainerSequenceRecord(
            seq_id=data_point.seq_id,
            seq=data_point.seq,
            attributes={
                k: v if str(k).lower() != "set" else "val"
                for k, v in data_point.attributes.items()
            },
            embedding=data_point.embedding,
        )
        for data_point in val_data
    ]
    val_data_ids = set([data_point.seq_id for data_point in val_data])
    train_data = [
        data_point
        for data_point in train_data.values()
        if data_point.seq_id not in val_data_ids
    ]

    # Prepare config
    config = _prepare_biotrainer_config(al_campaign_config, al_iteration_config)
    # Set default epochs based on task type
    config["num_epochs"] = 200 if task_type == "classification" else 120
    config["patience"] = (
        120
        if al_campaign_config.model_type == ActiveLearningModelType.GAUSSIAN_PROCESS
        else 50
    )
    input_data = [*train_data, *val_data, *test_data, *inference_data.values()]

    # Run biotrainer
    result = biotrainer_subtask_wrapper(config, input_data)

    # Extract predictions and uncertainties
    predictions = result["predictions"]
    ordered_predictions = [predictions[key] for key in inference_data.keys()]
    assert len(ordered_predictions) == len(inference_data) == len(predictions)
    means = torch.tensor([pred_dict["mcd_mean"] for pred_dict in ordered_predictions])
    preds = [pred_dict["prediction"] for pred_dict in ordered_predictions]
    if al_campaign_config.optimization_mode == ActiveLearningOptimizationMode.DISCRETE:
        uncertainty = torch.tensor(
            [pred_dict["bald_score"] for pred_dict in ordered_predictions]
        )
    else:  # mcd_std for regression
        uncertainty = torch.tensor(
            [pred_dict["mcd_std"] for pred_dict in ordered_predictions]
        )
    desirability = _calculate_desirability(
        means,
        al_campaign_config,
        class_str2int=result["derived_values"]["class_str2int"],
    )
    # Calculate acquisition scores
    beta = al_iteration_config.coefficient
    scores = _calculate_acquisition(
        desirability=desirability, uncertainty=uncertainty, beta=beta
    )

    return scores, preds, uncertainty


def _calculate_acquisition(desirability, uncertainty, beta):
    """Calculate acquisition score as desirability + beta * uncertainty. (Upper Confidence Bound)"""
    acquisition = desirability + beta * uncertainty
    return acquisition


def _random_baseline_inference(
    train_data: Dict[str, BiotrainerSequenceRecord],
    inference_data: Dict[str, BiotrainerSequenceRecord],
    task_type: Literal["classification", "regression"],
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    uncertainty_strategy: Literal["constant", "random", "uniform"] = "constant",
    seed: Optional[int] = None,
) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
    """
    Random baseline that mimics the train_and_inference interface.

    Args:
        train_data
        inference_data
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

    n_inference = len(inference_data)

    if task_type == "classification":
        means, uncertainty = _random_classification_predictions(
            train_data,
            n_inference,
            al_campaign_config,
            al_iteration_config,
            uncertainty_strategy,
        )
        desirability = means
    else:  # regression
        means, uncertainty = _random_regression_predictions(
            train_data, n_inference, al_campaign_config, uncertainty_strategy
        )
        desirability = _calculate_desirability(means, al_campaign_config)

    # Calculate acquisition scores
    beta = al_iteration_config.coefficient
    scores = _calculate_acquisition(desirability, uncertainty, beta)

    return scores, means, uncertainty


def _random_classification_predictions(
    train_data: Dict[str, BiotrainerSequenceRecord],
    n_inference: int,
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    uncertainty_strategy: str,
) -> Tuple[torch.Tensor, torch.Tensor]:
    """Generate random predictions for classification."""
    # Get target index
    tgt_idx = _get_target_index(
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
    means = means.float()

    # Generate uncertainties
    uncertainty = _generate_uncertainty(
        n_inference,
        uncertainty_strategy,
        task_type="classification",
        target_prob=target_prob,
    )

    return means, uncertainty


def _random_regression_predictions(
    train_data: Dict[str, BiotrainerSequenceRecord],
    n_inference: int,
    al_campaign_config: ActiveLearningCampaignConfig,
    uncertainty_strategy: str,
) -> Tuple[torch.Tensor, torch.Tensor]:
    """Generate random predictions for regression."""
    train_labels = torch.tensor(
        [float(data_point.get_target()) for data_point in train_data.values()]
    )
    y_min = train_labels.min().item()
    y_max = train_labels.max().item()

    # Sample uniformly between min and max
    means = torch.rand(n_inference) * (y_max - y_min) + y_min

    # Generate uncertainties
    uncertainty = _generate_uncertainty(
        n_inference,
        uncertainty_strategy,
        task_type="regression",
        train_std=train_labels.std().item(),
        train_range=y_max - y_min,
    )

    return means, uncertainty


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
                uncertainty_val = -p * torch.log(torch.tensor(p)) - (1 - p) * torch.log(
                    torch.tensor(1 - p)
                )
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


def _run_model(
    train_data: Dict[str, BiotrainerSequenceRecord],
    inference_data: Dict[str, BiotrainerSequenceRecord],
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    biotrainer_subtask_wrapper: Callable,
    all_target_classes: Optional[List[str]] = None,
):
    mode = al_campaign_config.optimization_mode
    task_type = (
        "classification"
        if mode == ActiveLearningOptimizationMode.DISCRETE
        else "regression"
    )
    model_type = al_campaign_config.model_type
    match model_type:
        case ActiveLearningModelType.GAUSSIAN_PROCESS | ActiveLearningModelType.FNN_MCD:
            return _train_and_inference_biotrainer(
                train_data=train_data,
                inference_data=inference_data,
                task_type=task_type,
                al_campaign_config=al_campaign_config,
                al_iteration_config=al_iteration_config,
                biotrainer_subtask_wrapper=biotrainer_subtask_wrapper,
                all_target_classes=all_target_classes,
            )
        case ActiveLearningModelType.RANDOM:
            return _random_baseline_inference(
                train_data=train_data,
                inference_data=inference_data,
                task_type=task_type,
                al_campaign_config=al_campaign_config,
                al_iteration_config=al_iteration_config,
                uncertainty_strategy="constant",
            )


def _batch_selection(results: List[ActiveLearningResult], n_suggestions: int):
    """Sort results by score and return top n_suggestions."""
    results.sort(key=lambda al_r: al_r.score, reverse=True)
    suggestions = [result.entity_id for result in results[:n_suggestions]]
    return results, suggestions


def _prepare_biotrainer_data(
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    embeddings: List[BiotrainerSequenceRecord],
):
    id2emb = {embd.get_hash(): embd.embedding for embd in embeddings}
    train_data = {}
    inference_data = {}
    for data_point in al_iteration_config.iteration_data:
        biotrainer_seq_record = data_point.to_biotrainer_seq_record()
        if data_point.set == "pred":
            inference_data[biotrainer_seq_record.seq_id] = (
                biotrainer_seq_record.copy_with_embedding(
                    id2emb[biotrainer_seq_record.get_hash()]
                )
            )
        else:
            train_data[biotrainer_seq_record.seq_id] = (
                biotrainer_seq_record.copy_with_embedding(
                    id2emb[biotrainer_seq_record.get_hash()]
                )
            )

    assert len(train_data) + len(inference_data) == len(embeddings)
    return train_data, inference_data


def _prepare_biotrainer_config(
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
):
    model_choice = None
    match al_campaign_config.model_type:
        case ActiveLearningModelType.GAUSSIAN_PROCESS:
            model_choice = "GP"
        case ActiveLearningModelType.FNN_MCD:
            model_choice = "FNN"
    protocol = None
    match al_campaign_config.optimization_mode:
        case ActiveLearningOptimizationMode.DISCRETE:
            protocol = Protocol.sequence_to_class.value
        case _:
            protocol = Protocol.sequence_to_value.value
    return {"model_choice": model_choice, "protocol": protocol}


def al_pipeline(
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    embeddings: List[BiotrainerSequenceRecord],
    biotrainer_subtask_wrapper: Callable,
    all_target_classes: Optional[List[str]] = None,
) -> ActiveLearningIterationResult:
    train_data, inference_data = _prepare_biotrainer_data(
        al_campaign_config=al_campaign_config,
        al_iteration_config=al_iteration_config,
        embeddings=embeddings,
    )
    logger.info("AL - Data preparation finished!")

    # train model, inference and get acquisition function score
    scores, preds, uncertainties = _run_model(
        train_data=train_data,
        inference_data=inference_data,
        al_campaign_config=al_campaign_config,
        al_iteration_config=al_iteration_config,
        biotrainer_subtask_wrapper=biotrainer_subtask_wrapper,
        all_target_classes=all_target_classes,
    )

    # Gather results
    results: List[ActiveLearningResult] = []
    for idx, key in enumerate(inference_data.keys()):
        sid = key
        pred = str(preds[idx])
        uncertainty = uncertainties[idx].item()
        score = scores[idx].item()
        al_result = ActiveLearningResult(
            entity_id=sid, prediction=pred, uncertainty=uncertainty, score=score
        )
        results.append(al_result)

    # Batch Selection
    sorted_results, suggestions = _batch_selection(
        results=results, n_suggestions=al_iteration_config.n_suggestions
    )

    logger.info(
        f"AL - Pipeline finished for iteration: {al_iteration_config.iteration}!"
    )

    return ActiveLearningIterationResult(
        iteration=al_iteration_config.iteration,
        results=sorted_results,
        suggestions=suggestions,
    )
