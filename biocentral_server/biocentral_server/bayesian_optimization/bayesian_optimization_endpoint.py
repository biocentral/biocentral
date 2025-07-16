import torch
import json
import hashlib

from flask import request, jsonify, Blueprint

from .bayesian_optimization_task import BayesTask

from ..utils import str2bool, get_logger
from ..server_management import (
    TaskManager,
    UserManager,
    FileManager,
)

"""
for this functionality:
    1. take uploaded dataset from the file manager
    2. embed the sequences
    3. launch BO model training process and obtain a ranking based on score
    4. return the data back to client
break into APIs:
    1. upload api: upload dataset to backend
    2. train & inference api: launch training and inference task
    3. query API: obtaining status
    4. fetch result api: fetch results
train & inference api:
    1. take uploaded dataset from the file manager
    2. embed the sequences
    3. launch BO model training process, that run training, inference and
        save the output to somewhere in file manager when finished
    4. return a handle to query and fetch result for current inference run
fetch result api: fetch the result according to handle
"""

logger = get_logger(__name__)

bayesian_optimization_service_route = Blueprint(
    "bayesian_optimization_service", __name__
)


def float_if_possible(num):
    mapping = {
        "Infinity": float("inf"),
        "-Infinity": float("-inf"),
    }
    if num in mapping:
        return mapping[num]
    try:
        num = float(num)
    except ValueError:
        pass
    return num


def verify_config(config_dict: dict):
    """
    ### Configuration Requirements
    - `databsase_hash :: str`
    - `model_type = "gaussian_process"`
    - `coefficient :: float`
    ### Optional arguent
    - `embedder_name :: str`, default: `one_hot_encoding`
    #### Configurating optimization target
    - `discrete :: bool`
    - When `discrete = true`
        - `discrete_labels :: list`
        - `discrete_targets :: list`
        - targets should only contain single target label
    - When `discrete` = false
        - `optimization_mode` (str): mode selection
    """
    database_hash: str = config_dict.get("database_hash")
    model_type: str = config_dict.get("model_type").lower()
    coefficient = float_if_possible(config_dict.get("coefficient"))
    config_dict["coefficient"] = coefficient
    if (
        not isinstance(database_hash, str)
        or not isinstance(model_type, str)
        or not isinstance(coefficient, float)
    ):
        raise TypeError(
            "[verify_config]: Config need to include: database_hash :: str, model_type :: str and coefficient :: float"
        )
    if model_type not in BayesTask.SUPPORTED_MODELS:
        raise ValueError(
            f"[verify_config]: unsupported model type. Valid model types: {BayesTask.SUPPORTED_MODELS}"
        )
    if coefficient < 0:
        raise ValueError("[verify_config]: Coefficient should be non-negative")
    device: str = config_dict.get("device", "")
    if device and device.lower() not in ["cuda", "cpu"]:
        raise ValueError("[verify_config]: Device should be either 'cuda' or 'cpu'")
    if device == "cuda" and not torch.cuda.is_available():
        raise ValueError("[verify_config]: CUDA device is not available")
    return verify_optim_target(config_dict)


def parse_str_to_list(s, delim=","):
    strlist: list[str] = s[1:-1].split(delim)
    strlist = [strr.strip() for strr in strlist]
    return strlist


def verify_optim_target(config_dict: dict):
    is_discrete: bool = config_dict.get("discrete")
    if is_discrete is None:
        raise KeyError("[verify_config]: Config need to include: is_discrete :: bool")
    if isinstance(is_discrete, str):
        is_discrete = str2bool(is_discrete)
        config_dict["discrete"] = is_discrete
    if is_discrete:
        labels = config_dict.get("discrete_labels")
        targets = config_dict.get("discrete_targets")
        if not (labels and targets):
            raise KeyError(
                "[verify_config]: Config for discrete target need to include discrete_labels and discrete_targets field"
            )
        if isinstance(labels, str):
            labels = parse_str_to_list(labels)
            config_dict["discrete_labels"] = labels
        if isinstance(targets, str):
            targets = parse_str_to_list(targets)
            config_dict["discrete_targets"] = targets

        sl, st = set(labels), set(targets)
        if not (sl.issuperset(st) and len(sl) > len(st)):
            raise ValueError("[verify_config]: targets should be true subset of labels")
        # limit to binary classification
        if len(st) != 1:
            raise ValueError(
                "[verify_config]: discrete_targets should have exactly 1 element"
            )
    else:
        optimization_mode = config_dict.get("optimization_mode")
        if not optimization_mode or optimization_mode.lower() not in [
            "interval",
            "value",
            "maximize",
            "minimize",
        ]:
            raise ValueError(
                "[verify_config]: require optimization_mode::str\n"
                "Options: interval, value, maximize, minimize"
            )
        match optimization_mode:
            case "interval":
                lb = float_if_possible(config_dict.get("target_lb"))
                ub = float_if_possible(config_dict.get("target_ub"))
                if not (lb or ub):
                    raise KeyError(
                        "[verify_config]: Config for continuous target need to include "
                        + "target_lb :: float or target_ub :: float"
                    )
                if lb is None:
                    lb = float("-inf")
                if ub is None:
                    ub = float("inf")
                if lb >= ub:
                    raise ValueError(
                        "[verify_config]: target_interval_lb should < target_interval_ub"
                    )
                config_dict["target_lb"] = lb
                config_dict["target_ub"] = ub
            case "value":
                val = float_if_possible(config_dict.get("target_value"))
                config_dict["target_value"] = val
                if not val:
                    raise KeyError(
                        "[verify_config]: Config for value target needs to include target_value :: float"
                    )
    return config_dict


@bayesian_optimization_service_route.route(
    "/bayesian_optimization_service/training", methods=["POST"]
)
def train_and_inference():
    # verify configuration dict
    config_dict: dict = request.get_json()
    logger.info(f"Request train_and_inference: \n {config_dict}")
    try:
        verify_config(config_dict)
    except Exception as e:
        return jsonify({"error": str(e)})
    database_hash = config_dict.get("database_hash")
    # fetch util classes
    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)
    task_manager = TaskManager()
    # get task id that's unique w.r.t config dict
    task_hash = hashlib.md5(
        json.dumps(config_dict, sort_keys=True).encode("utf-8")
    ).hexdigest()
    task_id = f"biocentral-bayesian_optimization-{task_hash}"
    # get output path
    output_dir = file_manager.get_biotrainer_model_path(model_hash=task_id)
    logger.info(f"Output_path: {output_dir}")
    # idempotence
    # prepare more training configurations
    config_dict["output_dir"] = str(output_dir.absolute())
    try:
        input_file = file_manager.get_file_path_for_training(
            database_hash=database_hash,
        )
        config_dict["input_file"] = input_file
    except FileNotFoundError as e:
        return jsonify({"error": str(e)})
    # launch process
    bo_process = BayesTask(
        config_dict,
    )
    task_manager.add_task(task=bo_process, task_id=task_id)
    return jsonify({"task_id": task_id})


def verify_request(req_body: dict):
    database_hash = req_body.get("database_hash")
    task_id = req_body.get("task_id")
    if (
        database_hash is None
        or task_id is None
        or not isinstance(database_hash, str)
        or not isinstance(task_id, str)
    ):
        raise KeyError(
            "model_results require database_hash :: str and task_id :: str in request"
        )
