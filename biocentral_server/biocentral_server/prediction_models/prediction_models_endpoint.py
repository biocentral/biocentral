import json

from biotrainer.input_files import BiotrainerSequenceRecord
from biotrainer.protocols import Protocol
from flask import request, jsonify, Blueprint
from biotrainer.config import Configurator, ConfigurationException

from .biotrainer_task import BiotrainerTask
from .biotrainer_inference_task import BiotrainerInferenceTask

from ..server_management import TaskManager, UserManager, FileManager, TaskStatus

prediction_models_service_route = Blueprint("prediction_models_service", __name__)


def _get_config_dict_from_string(config_string: str) -> dict:
    config_dict = {}

    def _eval_value(val: str):
        for v in [val, val.capitalize(), val.lower(), val.upper()]:
            try:
                ev = eval(v)
                return ev
            except NameError:
                continue
        return val

    for line in config_string.split("\n"):
        if line == "":
            continue
        key_value = line.strip().split(":")
        if len(key_value) == 2:
            key = key_value[0].strip()
            value = key_value[1].strip()
            config_dict[key] = _eval_value(value)
        else:
            raise ConfigurationException(f"Invalid config: {key_value}")
    return config_dict


# Endpoint to get configuration options by protocol from biotrainer
@prediction_models_service_route.route(
    "/prediction_models_service/config_options/<protocol>", methods=["GET"]
)
def config_options(protocol):
    options = Configurator.get_option_dicts_by_protocol(
        protocol=Protocol.from_string(protocol), sub_configs_to_include=[]
    )
    presets = BiotrainerTask.get_config_presets()
    filtered_options = [
        {k: v for k, v in option_dict.items() if k not in presets}
        for option_dict in options
    ]
    return jsonify({"options": filtered_options})


# Endpoint to verify configuration options
@prediction_models_service_route.route(
    "/prediction_models_service/verify_config/", methods=["POST"]
)
def verify_config():
    config = request.get_json()
    # Validate and extract task parameters from the request data
    config_string = config.get("config_file")
    try:
        config_dict = _get_config_dict_from_string(config_string)
        configurator = Configurator.from_config_dict(config_dict)
        configurator.verify_config(ignore_file_checks=True)
    except ConfigurationException as config_exception:
        return jsonify({"error": str(config_exception)})
    # Verification successful - no error
    return jsonify({"error": ""})


# Endpoint to get available protocols from biotrainer
@prediction_models_service_route.route(
    "/prediction_models_service/protocols", methods=["GET"]
)
def protocols():
    all_protocols = list(map(str, Protocol.all()))
    return jsonify({"protocols": all_protocols})


# Endpoint to start model training for biotrainer
@prediction_models_service_route.route(
    "/prediction_models_service/start_training", methods=["POST"]
)
def start_training():
    task_data = request.get_json()
    # Validate and extract task parameters from the request data
    config_string = task_data.get("config_file")
    try:
        config_dict = _get_config_dict_from_string(config_string)
    except ConfigurationException as config_exception:
        return jsonify({"error": str(config_exception)})

    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)
    database_hash: str = task_data.get("database_hash")
    try:
        input_file = file_manager.get_file_path_for_training(
            database_hash=database_hash
        )
    except FileNotFoundError as e:
        return jsonify({"error": str(e)})

    config_dict["input_file"] = input_file

    task_manager = TaskManager()
    # TODO Replace this by a appropriate model hash in the future to avoid costly retraining
    task_id = task_manager.get_unique_task_id(task=BiotrainerTask)

    model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)
    # TODO Move this to the file backend
    # if model_path.exists():
    #    return jsonify({"task_id": task_id})

    biotrainer_process = BiotrainerTask(model_path=model_path, config_dict=config_dict)
    task_id = task_manager.add_task(task=biotrainer_process, task_id=task_id)

    return jsonify({"task_id": task_id})


# Endpoint to retrieve model files after training is finished
@prediction_models_service_route.route(
    "/prediction_models_service/model_files", methods=["POST"]
)
def model_files():
    model_file_data = request.get_json()
    model_hash = model_file_data.get("model_hash")

    task_status = TaskManager().get_task_status(model_hash)
    if task_status != TaskStatus.FINISHED:
        return jsonify(
            {"error": "Trying to retrieve model files before task has finished!"}
        )

    user_id = UserManager.get_user_id_from_request(request)
    file_manager = FileManager(user_id=user_id)
    model_file_dict = file_manager.get_biotrainer_result_files(model_hash=model_hash)
    return jsonify(model_file_dict)


# Endpoint to make inference predictions from trained models
@prediction_models_service_route.route(
    "/prediction_models_service/start_inference", methods=["POST"]
)
def start_inference():
    model_file_data = request.get_json()
    model_hash = model_file_data.get("model_hash")
    model_hash = (
        "biocentral-BiotrainerTask-8d6699e6-4378-45c8-8f8a-23c103c9abb8"  # TODO DEBUG
    )

    sequence_input = json.loads(model_file_data.get("sequence_input", ""))

    if sequence_input is None or not isinstance(sequence_input, dict):
        return jsonify({"error": "Invalid sequence input!"})
    seq_records = [
        BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
        for seq_id, seq in sequence_input.items()
    ]

    user_id = UserManager.get_user_id_from_request(request)
    file_manager = FileManager(user_id=user_id)
    model_out_path = file_manager.get_biotrainer_model_path(model_hash=model_hash)
    if model_out_path is None:
        return jsonify({"error": "No model output file found!"})

    inference_task = BiotrainerInferenceTask(
        model_out_path=model_out_path, seq_records=seq_records
    )
    task_manager = TaskManager()
    task_id = task_manager.add_task(task=inference_task)

    return jsonify({"task_id": task_id})
