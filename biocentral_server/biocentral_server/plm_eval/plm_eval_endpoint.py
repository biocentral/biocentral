import json
import logging
import requests

from flask import request, jsonify, Blueprint

from biotrainer.embedders import _get_embedder

logger = logging.getLogger(__name__)

plm_eval_service_route = Blueprint("plm_eval_service", __name__)


@plm_eval_service_route.route('/plm_eval_service/validate', methods=['POST'])
def validate():
    plm_eval_data = request.get_json()
    model_id: str = plm_eval_data["modelID"]
    url = f"https://huggingface.co/api/models/{model_id}"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            # Model exists
            return jsonify({})
        elif response.status_code == 401:
            # Model not found
            return jsonify({"error": f"Model not found on huggingface!"})
        else:
            # Handle other status codes
            return jsonify({"error": f"Unexpected huggingface status code: {response.status_code}"})
    except requests.RequestException as e:
        return jsonify({"error": f"Error checking model availability on huggingface: {e}"})

