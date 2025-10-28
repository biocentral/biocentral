from flask import Blueprint

# TODO Update ProtSpace API
# from protspace.utils.prepare_json import DataProcessor as ProtSpaceDataProcessor
# from protspace.utils.prepare_json import (
#    DimensionReductionConfig as ProtSpaceDimensionReductionConfig,
# )

# from .protspace_task import ProtSpaceTask


projection_route = Blueprint(
    "projection_route", __name__, url_prefix="/embeddings_service"
)


# Endpoint for ProtSpace dimensionality reduction methods for sequences
"""
@projection_route.route("/projection_config", methods=["GET"])
def projection_config():
    methods = list(ProtSpaceDataProcessor.REDUCERS.keys())

    protspace_default_config = ProtSpaceDimensionReductionConfig()
    projection_config_by_method = {
        method: protspace_default_config.parameters_by_method(method)
        for method in methods
    }
    return jsonify(projection_config_by_method)


# Endpoint for ProtSpace dimensionality reduction methods for sequences
@projection_route.route("/projection_for_sequences", methods=["POST"])
def projection_for_sequences():
    projection_data = request.get_json()

    method = projection_data.get("method")
    sequences = json.loads(projection_data.get("sequences"))
    config = json.loads(projection_data.get("config"))
    embedder_name = projection_data.get("embedder_name")

    if method not in ProtSpaceDataProcessor.REDUCERS:
        return jsonify({"error": f"Unsupported reduction method: {method}"})

    protspace_task = ProtSpaceTask(
        embedder_name=embedder_name,
        sequences=[
            BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
            for seq_id, seq in sequences.items()
        ],
        method=method,
        config=config,
    )
    task_manager = TaskManager()
    task_id = task_manager.add_task(task=protspace_task)

    return jsonify({"task_id": task_id})
"""
