import base64
import requests

from pathlib import Path
from typing import Optional
from functools import lru_cache
from flask import request, jsonify, Blueprint
from biotrainer.embedders import get_predefined_embedder_names
from biotrainer.autoeval.flip.flip_datasets import FLIP_DATASETS

from .autoeval_task import AutoEvalTask

from ..utils import str2bool, get_logger
from ..server_management import UserManager, TaskManager, FileManager, StorageFileType

logger = get_logger(__name__)

plm_eval_service_route = Blueprint("plm_eval_service", __name__)


# TODO Improve caching such that results that are older than one hour are omitted for new huggingface models
@lru_cache(maxsize=12)
def _validate_model_id(model_id: str):
    if model_id in get_predefined_embedder_names():
        return ""

    url = f"https://huggingface.co/api/models/{model_id}"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            # Model exists
            return ""
        elif response.status_code == 401:
            # Model not found
            return f"Model not found on huggingface!"
        else:
            # Handle other status codes
            return f"Unexpected huggingface status code: {response.status_code}"
    except requests.RequestException as e:
        return f"Error checking model availability on huggingface: {e}"


def _convert_flip_dict_to_dataset_split_dict(flip_dict: dict) -> dict:
    return {dataset: [split_dict for split_dict in values["splits"]] for dataset, values in flip_dict.items()}


@plm_eval_service_route.route('/plm_eval_service/validate', methods=['POST'])
def validate():
    plm_eval_data = request.get_json()
    model_id: str = str(plm_eval_data["modelID"])

    error = _validate_model_id(model_id)
    if error != "":
        return jsonify({"error": error})
    return jsonify({})


@plm_eval_service_route.route('/plm_eval_service/get_benchmark_datasets', methods=['GET'])
def get_benchmark_datasets():
    flip_dict = FLIP_DATASETS

    return jsonify(_convert_flip_dict_to_dataset_split_dict(flip_dict))

"""
# TODO REMOVE
@plm_eval_service_route.route('/plm_eval_service/get_recommended_benchmark_datasets', methods=['GET'])
def get_recommended_benchmark_datasets():
    flip_dict = current_app.config['FLIP_DICT']

    recommended_only = _get_recommended_only_flip_dict(flip_dict)
    return jsonify(_convert_flip_dict_to_dataset_split_dict(recommended_only))
"""

@plm_eval_service_route.route('/plm_eval_service/autoeval', methods=['POST'])
def autoeval():
    plm_eval_data = request.get_json()
    model_id: str = str(plm_eval_data["modelID"])

    # ONNX
    onnx_file = plm_eval_data.get("onnxFile", None)
    tokenizer_config = plm_eval_data.get("tokenizerConfig", None)

    user_id = UserManager.get_user_id_from_request(req=request)

    onnx_path: Optional[Path] = None
    tokenizer_config_path: Optional[Path] = None
    if onnx_file and tokenizer_config:
        onnx_bytes = base64.b64decode(onnx_file)
        file_manager = FileManager(user_id=user_id)
        onnx_path = file_manager.save_file(file_type=StorageFileType.ONNX_MODEL,
                                           file_content=onnx_bytes,
                                           embedder_name=model_id)
        tokenizer_config_path = file_manager.save_file(file_type=StorageFileType.TOKENIZER_CONFIG,
                                                       file_content=tokenizer_config,
                                                       embedder_name=model_id)
    else:
        error = _validate_model_id(model_id)
        if error != "":
            return jsonify({"error": error})

    task = AutoEvalTask(embedder_name=model_id, user_id=user_id,
                        onnx_path=str(onnx_path) if onnx_path else None,
                        tokenizer_config_path=str(tokenizer_config_path) if tokenizer_config_path else None
                        )

    task_id = TaskManager().add_task(task=task)

    return jsonify({"task_id": task_id})
