import json
import logging
import requests

from biotrainer.embedders import _get_embedder
from flask import request, jsonify, Blueprint, current_app

from .autoeval import autoeval_flow

logger = logging.getLogger(__name__)

plm_eval_service_route = Blueprint("plm_eval_service", __name__)


def _validate_model_id(model_id: str):
    # TODO Caching
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
    model_id: str = plm_eval_data["modelID"]

    error = _validate_model_id(model_id)
    if error != "":
        return jsonify({"error": error})
    return jsonify({})


@plm_eval_service_route.route('/plm_eval_service/get_benchmark_datasets', methods=['GET'])
def get_splits():
    flip_dict = current_app.config['FLIP_DICT']
    autoeval_flow(flip_dict)

    return jsonify(
        {dataset: [split_dict["name"] for split_dict in values["splits"]] for dataset, values in flip_dict.items()})


@plm_eval_service_route.route('/plm_eval_service/autoeval', methods=['POST'])
def autoeval():
    plm_eval_data = request.get_json()
    model_id: str = plm_eval_data["modelID"]

    error = _validate_model_id(model_id)
    if error != "":
        return jsonify({"error": error})

    # autoeval_flow()
