from flask import Blueprint, jsonify

from .models import get_metadata_for_all_models

prediction_metadata_route = Blueprint('prediction_service_metadata', __name__)

# Endpoint to get all available model metadata
@prediction_metadata_route.route('/prediction_service/model_metadata', methods=['GET'])
def model_metadata():
    return jsonify({name: mdata.to_dict() for name, mdata in get_metadata_for_all_models().items()})
