import torch
import logging

from typing import List, Dict, Any
from biocentral_server.bayesian_optimization import gaussian_process_models as gp
from biotrainer.utilities import read_FASTA

from ..server_management import EmbeddingsDatabaseTriple, FileContextManager

logger = logging.getLogger(__name__)

SUPPORTED_MODELS = ["gaussian_process"]


def parse_description_to_label(description: str, discrete: bool, feature_name: str = 'TARGET'):
    """
    parse feature from descriptions
    return value: none | [target_val, if this is training]
    Note
    - description is expected to be space separated list of strings
    - feature_name and value should not contain space and '='
    - first feature_name=feature_value will be considered
      - as a result, classification target is expected to have only one label
    - sequence with feature_name=Unknown (case-insensitive unknown)
    or feature name doesn't appear will be considered as inference sample
    """
    feature_value = None
    # if feature_name=XX appear in description, it will be training
    for kvstr in description.split(' '):  # k=v
        kv = kvstr.split('=')
        if len(kv) != 2:
            continue
        if kv[0].lower() == feature_name.lower():
            feature_value = kv[1] if kv[1].lower() != 'unknown' and len(kv[1]) != 0 else None
            if not discrete and feature_value is not None:
                try:
                    feature_value = float(feature_value)
                except:
                    raise ValueError(f"not supported regression label: {feature_value}")
            break
    return feature_value


def get_datasets(config_dict: dict, seqs: dict):
    """
    train_data = {"ids": [], "X": [], "y": []}
    inference_data = {"ids": [], "X": []}
    if dataset is empty, the type of 'X' will be a list. 
    """
    if config_dict['discrete']:
        target_classes = {label: idx for idx, label in enumerate(config_dict['discrete_labels'])}

    train_data = {"ids": [], "X": [], "y": []}
    inference_data = {"ids": [], "X": []}

    def is_training(val_1) -> bool:
        if val_1 is None:
            return False
        return True

    device = torch.device(config_dict.get('device', 'cpu'))

    for id, val in seqs.items():
        if is_training(val[1]):
            train_data["ids"].append(id)
            train_data["X"].append(val[2])
            if config_dict['discrete']:
                if val[1] in target_classes:
                    target = target_classes[val[1]]
                else:
                    ValueError(f"get_datasets: illegal label {val[1]} in labels: {target_classes.keys()}")
            else:
                target = val[1]
            train_data["y"].append(target)
        else:
            inference_data["ids"].append(id)
            inference_data["X"].append(val[2])
    if train_data["X"]:
        train_data["X"] = torch.stack(train_data["X"]).float()
        train_data["X"] = train_data["X"].to(device=device)
    if inference_data["X"]:
        inference_data["X"] = torch.stack(inference_data["X"]).float()
        inference_data["X"] = inference_data["X"].to(device=device)
    if train_data['y']:
        train_data['y'] = torch.tensor(train_data['y'])
        train_data["y"] = train_data["y"].to(device=device)
    if config_dict["discrete"] and isinstance(train_data['y'], torch.Tensor):
        train_data["y"] = torch.nn.functional.one_hot(
            train_data['y'], len(config_dict["discrete_labels"])
        )
    return train_data, inference_data


def data_prep(config_dict: dict, embeddings: List[EmbeddingsDatabaseTriple]) -> tuple[
    dict[str, list], dict[str, list], dict]:
    """
    train_data = {"ids": [], "X": （n_sample, dim）, "y": (n_sample), (n_sample, n_class))}
    inference_data = {"ids": [], "X": []}
    dict[seq_id] = [seq, description, embedding]
    """
    # read labels and seqs
    sequence_path = config_dict['sequence_file']
    file_context_manager = FileContextManager()
    with file_context_manager.storage_read(file_path=sequence_path) as sequence_file:
        fasta_list = read_FASTA(sequence_file)

    fasta_seqs = {seq.id: [str(seq.seq), seq.description] for seq in fasta_list}
    # Add embeddings
    for embedding in embeddings:
        if embedding.id not in fasta_seqs:
            raise ValueError(f"{embedding.id} not in {fasta_seqs.keys()}")
        fasta_seqs[embedding.id].append(embedding.embd)

    # parse labels
    for key in fasta_seqs.keys():
        fasta_seqs[key][1] = parse_description_to_label(
            description=fasta_seqs[key][1],
            discrete=config_dict["discrete"],
            feature_name=config_dict.get('feature_name', 'TARGET')
        )
    # train & test set split
    train_data, inference_data = get_datasets(config_dict, fasta_seqs)
    if len(train_data['ids']) * len(inference_data) == 0:
        raise ValueError("data_prep: training set / inference set is empty. Have you set feature_name?")
    return train_data, inference_data, fasta_seqs


def calculate_distance_penalty(means: torch.Tensor, config_dict):
    mode = config_dict.get('optimization_mode', '').lower()
    match mode:
        case "maximize":
            return means.max() - means
        case "minimize":
            return means
        case "value":
            target_val = config_dict['target_value']
            dist = torch.abs(target_val - means)
            return dist
        case "interval":
            dist = torch.zeros_like(means)
            lb, ub = config_dict['target_lb'], config_dict['target_ub']
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
    '''
    Args: 
    - train_data: dict {'X': [], 'y': [], 'ids': []}
    - inference_data: dict {'X': [], 'ids': []}
    - config_dict: dict containing configuration parameters like coefficient, lb, ub
    Return:
    - scores: tensor of shape (n_inference_data)
    - means
    - uncertainties
    '''
    if isinstance(train_data['X'], list) or isinstance(inference_data['X'], list):
        raise ValueError("train_and_inference_regression: data should not be empty")
    model, likelihood = gp.train_gp_regression_model(train_data, epoch=120, device=config_dict.get('device', 'cpu'))
    with torch.no_grad():
        prediction_dist = likelihood(model(inference_data['X']))
        dist = calculate_distance_penalty(prediction_dist.mean, config_dict)
        stds = prediction_dist.covariance_matrix.diag().sqrt()
        beta = config_dict['coefficient']
        score = calculate_acquisition(dist, stds, beta)
    return score, prediction_dist.mean, stds  # (n_inference)


def target_index(config_dict):
    target = config_dict['discrete_targets'][0]
    labels = config_dict['discrete_labels']
    for idx, label in enumerate(labels):
        if label.lower() == target.lower():
            return idx
    raise ValueError(f"Target '{target}' not found in discrete labels: {labels}")


def train_and_inference_classification(train_data, inference_data, config_dict):
    '''
    Args: 
    - train_data: dict {'X': [], 'y': [], 'ids': []}
    - inference_data: dict {'X': [], 'ids': []}
    - config_dict: dict containing configuration parameters like coefficient, lb, ub
    Return:
    - scores: tensor of shape (n_inference_data)
    - means
    - uncertainties
    '''
    if isinstance(train_data['X'], list) or isinstance(inference_data['X'], list):
        raise ValueError("train_and_inference_classification: data should not be empty")
    model, likelihood = gp.train_gp_classification_model(train_data, epoch=200, device=config_dict.get('device', 'cpu'))
    with torch.no_grad():
        prediction = likelihood(model(inference_data['X']))
        logger.info(f"Prediction mean: {prediction.mean}")
    tgt_idx = target_index(config_dict)
    means = prediction.mean[tgt_idx]
    uncer = prediction.covariance_matrix[tgt_idx].diag()
    scores = means + config_dict['coefficient'] * uncer
    return scores, means, uncer


def pipeline(config_dict: Dict[str, Any], embeddings: List[EmbeddingsDatabaseTriple]) -> List:
    train_data, inference_data, seqs = data_prep(config_dict, embeddings=embeddings)
    logger.info("BO Data preparation finished!")

    # train model, inference and add with acquisition function score
    if config_dict['discrete']:
        scores, means, uncertainties = train_and_inference_classification(train_data, inference_data, config_dict)
    else:
        scores, means, uncertainties = train_and_inference_regression(train_data, inference_data, config_dict)
    # ranking
    results = []
    for idx in range(len(inference_data['ids'])):
        sid = inference_data['ids'][idx]
        score = scores[idx].item()
        mean = means[idx].item()
        uncertainty = uncertainties[idx].item()
        seq = seqs[sid][0]
        results.append(
            {
                "id": sid,
                "sequence": seq,
                "mean": mean,
                "uncertainty": uncertainty,
                "score": score,
            }
        )
    results.sort(key=lambda x: x["score"], reverse=True)

    return results
