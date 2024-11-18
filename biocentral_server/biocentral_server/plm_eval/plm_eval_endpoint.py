import uuid
import logging
import requests

from functools import lru_cache
from flask import request, jsonify, Blueprint, current_app

from .autoeval_task import AutoEvalTask
from ..server_management import UserManager, ProcessManager

logger = logging.getLogger(__name__)

plm_eval_service_route = Blueprint("plm_eval_service", __name__)


# TODO Improve caching such that results that are older than one hour are omitted for new huggingface models
@lru_cache(maxsize=12)
def _validate_model_id(model_id: str):
    if model_id == "one_hot_encoding":
        return ""

    url = f"https://huggingface.co/api/models/{model_id}"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            # Model exists
            return {}
        elif response.status_code == 401:
            # Model not found
            return f"Model not found on huggingface!"
        else:
            # Handle other status codes
            return f"Unexpected huggingface status code: {response.status_code}"
    except requests.RequestException as e:
        return f"Error checking model availability on huggingface: {e}"


@plm_eval_service_route.route('/plm_eval_service/validate', methods=['POST'])
def validate():
    plm_eval_data = request.get_json()
    model_id: str = str(plm_eval_data["modelID"])

    error = _validate_model_id(model_id)
    if error != "":
        return jsonify({"error": error})
    return jsonify({})


@plm_eval_service_route.route('/plm_eval_service/get_benchmark_datasets', methods=['GET'])
def get_splits():
    flip_dict = current_app.config['FLIP_DICT']

    return jsonify(
        {dataset: [split_dict["name"] for split_dict in values["splits"]] for dataset, values in flip_dict.items()})


@plm_eval_service_route.route('/plm_eval_service/autoeval', methods=['POST'])
def autoeval():
    plm_eval_data = request.get_json()
    model_id: str = str(plm_eval_data["modelID"])

    error = _validate_model_id(model_id)
    if error != "":
        return jsonify({"error": error})

    flip_dict = current_app.config['FLIP_DICT']
    user_id = UserManager.get_user_id_from_request(req=request)
    task = AutoEvalTask(flip_dict=flip_dict, embedder_name=model_id, user_id=user_id,
                        embeddings_db_instance=current_app.config["EMBEDDINGS_DATABASE"])
    task_id = f"autoeval_{model_id}_" + str(uuid.uuid4())

    ProcessManager.add_task(task_id=task_id, task=task)
    ProcessManager.start_task(task_id=task_id)

    return jsonify({"task_id": task_id})


@plm_eval_service_route.route('/plm_eval_service/task_status/<task_id>', methods=['GET'])
def task_status(task_id):
    return ProcessManager.get_task_update(task_id=task_id)

