import torch

from typing import List, Dict, Any
from biotrainer.input_files import read_FASTA, BiotrainerSequenceRecord

from .gaussian_process_models import (
    train_gp_regression_model,
    train_gp_classification_model,
)

from ..utils import get_logger
from ..server_management import FileContextManager

logger = get_logger(__name__)

SUPPORTED_MODELS = ["gaussian_process"]


def get_datasets(config_dict: dict, embd_records: List[BiotrainerSequenceRecord]):
    """
    train_data = {"ids": [], "X": [], "y": []}
    inference_data = {"ids": [], "X": []}
    if dataset is empty, the type of 'X' will be a list.
    """
    target_classes = {}
    if config_dict["discrete"]:
        target_classes = {
            label: idx for idx, label in enumerate(config_dict["discrete_labels"])
        }

    train_data = {"ids": [], "X": [], "y": []}
    inference_data = {"ids": [], "X": []}

    device = torch.device(config_dict.get("device", "cpu"))

    for embd_record in embd_records:
        target = embd_record.get_target()
        target = None if target is None or target == "None" else target
        if target is not None:  # Train Set
            train_data["ids"].append(embd_record.seq_id)
            train_data["X"].append(torch.tensor(embd_record.embedding))
            # Convert target
            if config_dict["discrete"]:
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
            inference_data["X"].append(torch.tensor(embd_record.embedding))

    if train_data["X"]:
        train_data["X"] = torch.stack(train_data["X"]).float()
        train_data["X"] = train_data["X"].to(device=device)
    if inference_data["X"]:
        inference_data["X"] = torch.stack(inference_data["X"]).float()
        inference_data["X"] = inference_data["X"].to(device=device)
    if train_data["y"]:
        train_data["y"] = torch.tensor(train_data["y"])
        train_data["y"] = train_data["y"].to(device=device)
    if config_dict["discrete"] and isinstance(train_data["y"], torch.Tensor):
        train_data["y"] = torch.nn.functional.one_hot(
            train_data["y"], len(config_dict["discrete_labels"])
        )
    return train_data, inference_data


def data_prep(
    config_dict: dict, embeddings: List[BiotrainerSequenceRecord]
) -> tuple[dict[str, list], dict[str, list], List[BiotrainerSequenceRecord]]:
    """
    train_data = {"ids": [], "X": （n_sample, dim）, "y": (n_sample), (n_sample, n_class))}
    inference_data = {"ids": [], "X": []}
    dict[seq_id] = [seq, description, embedding]
    """
    # read labels and seqs
    input_file_path = config_dict["input_file"]
    file_context_manager = FileContextManager()
    with file_context_manager.storage_read(file_path=input_file_path) as input_file:
        seq_records = read_FASTA(input_file)

    id2record = {seq_record.get_hash(): seq_record for seq_record in seq_records}
    embd_records = [
        id2record[seq_record.get_hash()].copy_with_embedding(seq_record.embedding)
        for seq_record in embeddings
    ]

    # train & test set split
    train_data, inference_data = get_datasets(config_dict, embd_records)
    if len(train_data["ids"]) * len(inference_data) == 0:
        raise ValueError(
            "data_prep: training set or inference set is empty. Have you set feature_name?"
        )
    return train_data, inference_data, embd_records


def calculate_distance_penalty(means: torch.Tensor, config_dict):
    mode = config_dict.get("optimization_mode", "").lower()
    match mode:
        case "maximize":
            return means.max() - means
        case "minimize":
            return means
        case "value":
            target_val = config_dict["target_value"]
            dist = torch.abs(target_val - means)
            return dist
        case "interval":
            dist = torch.zeros_like(means)
            lb, ub = config_dict["target_lb"], config_dict["target_ub"]
            below_lb = means < lb
            above_ub = means > ub
            dist[below_lb] = lb - means[below_lb]
            dist[above_ub] = means[above_ub] - ub
            return dist
        case _:
            raise ValueError("distance_penalty: invalid optimization_mode")


def calculate_acquisition(distance_penalty, uncertainties, beta):
    proximity = distance_penalty.max() - distance_penalty
    acquisition = proximity + beta * uncertainties
    return acquisition


def train_and_inference_regression(train_data, inference_data, config_dict):
    """
    Args:
    - train_data: dict {'X': [], 'y': [], 'ids': []}
    - inference_data: dict {'X': [], 'ids': []}
    - config_dict: dict containing configuration parameters like coefficient, lb, ub
    Return:
    - scores: tensor of shape (n_inference_data)
    - means
    - uncertainties
    """
    if isinstance(train_data["X"], list) or isinstance(inference_data["X"], list):
        raise ValueError("train_and_inference_regression: data should not be empty")
    model, likelihood = train_gp_regression_model(
        train_data, epoch=120, device=config_dict.get("device", "cpu")
    )
    with torch.no_grad():
        prediction_dist = likelihood(model(inference_data["X"]))
        dist = calculate_distance_penalty(prediction_dist.mean, config_dict)
        stds = prediction_dist.covariance_matrix.diag().sqrt()
        beta = config_dict["coefficient"]
        score = calculate_acquisition(dist, stds, beta)
    return score, prediction_dist.mean, stds  # (n_inference)


def target_index(config_dict):
    target = config_dict["discrete_targets"][0]
    labels = config_dict["discrete_labels"]
    for idx, label in enumerate(labels):
        if label.lower() == target.lower():
            return idx
    raise ValueError(f"Target '{target}' not found in discrete labels: {labels}")


def train_and_inference_classification(train_data, inference_data, config_dict):
    """
    Args:
    - train_data: dict {'X': [], 'y': [], 'ids': []}
    - inference_data: dict {'X': [], 'ids': []}
    - config_dict: dict containing configuration parameters like coefficient, lb, ub
    Return:
    - scores: tensor of shape (n_inference_data)
    - means
    - uncertainties
    """
    if isinstance(train_data["X"], list) or isinstance(inference_data["X"], list):
        raise ValueError("train_and_inference_classification: data should not be empty")
    model, likelihood = train_gp_classification_model(
        train_data, epoch=200, device=config_dict.get("device", "cpu")
    )
    with torch.no_grad():
        prediction = likelihood(model(inference_data["X"]))
        logger.info(f"Prediction mean: {prediction.mean}")
    tgt_idx = target_index(config_dict)
    means = prediction.mean[tgt_idx]
    uncer = prediction.covariance_matrix[tgt_idx].diag()
    scores = means + config_dict["coefficient"] * uncer
    return scores, means, uncer


def pipeline(
    config_dict: Dict[str, Any], embeddings: List[BiotrainerSequenceRecord]
) -> List:
    train_data, inference_data, embd_records = data_prep(
        config_dict, embeddings=embeddings
    )
    logger.info("BO Data preparation finished!")

    # train model, inference and add with acquisition function score
    if config_dict["discrete"]:
        scores, means, uncertainties = train_and_inference_classification(
            train_data, inference_data, config_dict
        )
    else:
        scores, means, uncertainties = train_and_inference_regression(
            train_data, inference_data, config_dict
        )
    # ranking
    results = []
    for idx in range(len(inference_data["ids"])):
        sid = inference_data["ids"][idx]
        score = scores[idx].item()
        mean = means[idx].item()
        uncertainty = uncertainties[idx].item()
        results.append(
            {
                "id": sid,
                "mean": mean,
                "uncertainty": uncertainty,
                "score": score,
            }
        )
    results.sort(key=lambda x: x["score"], reverse=True)

    return results
