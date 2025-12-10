from __future__ import annotations

import torch

from typing import List
from biotrainer.input_files import BiotrainerSequenceRecord
from biotrainer.utilities import get_device

from .al_config import (
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningOptimizationMode,
)
from .gaussian_process_models import (
    train_gp_regression_model,
    train_gp_classification_model,
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
    means: torch.Tensor, al_campaign_config: ActiveLearningCampaignConfig
):
    # TODO Add discrete mode here as well
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
        case _:
            raise ValueError(
                "distance_penalty: invalid optimization_mode for regression"
            )


def calculate_acquisition(distance_penalty, uncertainties, beta):
    proximity = distance_penalty.max() - distance_penalty
    acquisition = proximity + beta * uncertainties
    return acquisition


def train_and_inference_regression(
    train_data,
    inference_data,
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
):
    """
    Args:
    - train_data: dict {'X': [], 'y': [], 'ids': []}
    - inference_data: dict {'X': [], 'ids': []}
    Return:
    - scores: tensor of shape (n_inference_data)
    - means
    - uncertainties
    """
    if isinstance(train_data["X"], list) or isinstance(inference_data["X"], list):
        raise ValueError("train_and_inference_regression: data should not be empty")
    model, likelihood = train_gp_regression_model(
        train_data, epoch=120, device=get_device()
    )
    with torch.no_grad():
        prediction_dist = likelihood(model(inference_data["X"]))
        dist = calculate_distance_penalty(
            prediction_dist.mean, al_campaign_config=al_campaign_config
        )
        stds = prediction_dist.covariance_matrix.diag().sqrt()
        beta = al_iteration_config.coefficient
        score = calculate_acquisition(dist, stds, beta)
    return score, prediction_dist.mean, stds  # (n_inference)


def _get_target_index(discrete_targets, discrete_labels):
    target = discrete_targets[0]
    labels = discrete_labels
    for idx, label in enumerate(labels):
        if label.lower() == target.lower():
            return idx
    raise ValueError(f"Target '{target}' not found in discrete labels: {labels}")


def train_and_inference_classification(
    train_data,
    inference_data,
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
):
    """
    Args:
    - train_data: dict {'X': [], 'y': [], 'ids': []}
    - inference_data: dict {'X': [], 'ids': []}
    Return:
    - scores: tensor of shape (n_inference_data)
    - means
    - uncertainties
    """
    if isinstance(train_data["X"], list) or isinstance(inference_data["X"], list):
        raise ValueError("train_and_inference_classification: data should not be empty")
    model, likelihood = train_gp_classification_model(
        train_data, epoch=200, device=get_device()
    )
    with torch.no_grad():
        prediction = likelihood(model(inference_data["X"]))
        logger.info(f"Prediction mean: {prediction.mean}")
    tgt_idx = _get_target_index(
        discrete_targets=al_campaign_config.discrete_targets,
        discrete_labels=al_iteration_config.get_all_labels(),
    )
    means = prediction.mean[tgt_idx]
    uncertainty = prediction.covariance_matrix[tgt_idx].diag()
    scores = means + al_iteration_config.coefficient * uncertainty
    return scores, means, uncertainty


def al_pipeline(
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    embeddings: List[BiotrainerSequenceRecord],
) -> ActiveLearningIterationResult:
    train_data, inference_data, embd_records = data_prep(
        al_campaign_config=al_campaign_config,
        al_iteration_config=al_iteration_config,
        embeddings=embeddings,
    )
    logger.info("AL - Data preparation finished!")

    # train model, inference and add with acquisition function score
    mode = al_campaign_config.optimization_mode
    if mode == ActiveLearningOptimizationMode.DISCRETE:
        scores, means, uncertainties = train_and_inference_classification(
            train_data=train_data,
            inference_data=inference_data,
            al_campaign_config=al_campaign_config,
            al_iteration_config=al_iteration_config,
        )
    else:
        scores, means, uncertainties = train_and_inference_regression(
            train_data=train_data,
            inference_data=inference_data,
            al_campaign_config=al_campaign_config,
            al_iteration_config=al_iteration_config,
        )

    # Gather results
    results: List[ActiveLearningResult] = []
    for idx in range(len(inference_data["ids"])):
        sid = inference_data["ids"][idx]
        mean = means[idx].item()
        uncertainty = uncertainties[idx].item()
        score = scores[idx].item()
        al_result = ActiveLearningResult(
            entity_id=sid, prediction=mean, uncertainty=uncertainty, score=score
        )
        results.append(al_result)

    # Sort results by score and create suggestions
    results.sort(key=lambda al_r: al_r.score, reverse=True)
    suggestions = [
        result.entity_id for result in results[: al_iteration_config.n_suggestions]
    ]

    return ActiveLearningIterationResult(results=results, suggestions=suggestions)
