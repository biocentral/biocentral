import dataclasses

from flask import request, Blueprint, jsonify

from .models import get_metadata_for_all_models, filter_models
from .multi_prediction_task import MultiPredictionTask

from ..server_management import TaskManager

prediction_service_route = Blueprint("prediction_service_predict", __name__)

def verify_sequences(sequence_input: dict[str, str]) -> str:
    min_seq_length = 7
    max_seq_length = 5000  # TODO Make this configurable
    for seq_id, seq in sequence_input.items():
        if not isinstance(seq, str):
            return f"{seq_id} is not a string"
        if len(seq) < min_seq_length:
            return f"{seq_id} is too short, min_seq_length={min_seq_length}, max_seq_length={max_seq_length}"
        elif len(seq) > max_seq_length:
            return f"{seq_id} is too long, max_seq_length={max_seq_length}, min_seq_length={min_seq_length}"

    return ""


# Endpoint for ProtSpace dimensionality reduction methods for sequences
@prediction_service_route.route('/prediction_service/predict', methods=['POST'])
def predict():
    request_data = PredictionRequestData(**request.get_json())
    model_names = request_data.model_names
    model_metadata = get_metadata_for_all_models()

    if any(model_name not in model_metadata.keys() for model_name in model_names):
        return jsonify({"error": "A requested model was not found!"})

    sequence_input = request_data.sequence_input
    sequence_verification_error = verify_sequences(sequence_input)
    if sequence_verification_error != "":
        return jsonify({"error": sequence_verification_error})

    models = filter_models(model_names=model_names)
    prediction_task = MultiPredictionTask(models=models,
                                          sequence_input=sequence_input,
                                          batch_size=request_data.batch_size)
    task_id = TaskManager().add_task(prediction_task)
    return jsonify({"task_id": task_id})


@dataclasses.dataclass
class PredictionRequestData:
    model_names: list[str]
    sequence_input: dict[str, str]  # sequence_id: sequence
    batch_size: int
