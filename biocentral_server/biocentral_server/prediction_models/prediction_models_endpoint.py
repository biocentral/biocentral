import yaml

from flask import request, jsonify, Blueprint, current_app

from biotrainer.protocols import Protocol
from biotrainer.config import Configurator, ConfigurationException

from .biotrainer_task import BiotrainerTask

from ..server_management import TaskManager, UserManager, FileManager, \
    StorageFileType, TaskStatus

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
@prediction_models_service_route.route('/prediction_models_service/config_options/<protocol>', methods=['GET'])
def config_options(protocol):
    options = Configurator.get_option_dicts_by_protocol(protocol=Protocol.from_string(protocol),
                                                        sub_configs_to_include=[])

    return jsonify({"options": options})


# Endpoint to verify configuration options
@prediction_models_service_route.route('/prediction_models_service/verify_config/', methods=['POST'])
def verify_config():
    config = request.get_json()
    # Validate and extract task parameters from the request data
    config_string = config.get('config_file')
    try:
        config_dict = _get_config_dict_from_string(config_string)
        configurator = Configurator.from_config_dict(config_dict)
        configurator.verify_config(ignore_file_checks=True)
    except ConfigurationException as config_exception:
        return jsonify({"error": str(config_exception)})
    # Verification successful - no error
    return jsonify({"error": ""})


# Endpoint to get available protocols from biotrainer
@prediction_models_service_route.route('/prediction_models_service/protocols', methods=['GET'])
def protocols():
    all_protocols = list(map(str, Protocol.all()))
    return jsonify({"protocols": all_protocols})


# Endpoint to start model training for biotrainer
@prediction_models_service_route.route('/prediction_models_service/start_training', methods=['POST'])
def start_training():
    task_data = request.get_json()
    # Validate and extract task parameters from the request data
    config_string = task_data.get('config_file')
    try:
        config_dict = _get_config_dict_from_string(config_string)
    except ConfigurationException as config_exception:
        return jsonify({"error": str(config_exception)})

    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)
    database_hash: str = task_data.get('database_hash')
    embedder_name = config_dict["embedder_name"]
    protocol = Protocol.from_string(config_dict["protocol"])
    try:
        sequence_file, labels_file, mask_file, embeddings_file = file_manager.get_file_paths_for_biotrainer(
            database_hash=database_hash, embedder_name=embedder_name, protocol=protocol)
    except FileNotFoundError as e:
        return jsonify({"error": str(e)})

    for file_name, file_path in [("sequence_file", sequence_file), ("labels_file", labels_file),
                                 ("mask_file", mask_file)]:
        if file_path != "":
            config_dict[file_name] = file_path

    # Remove embedder_name from config if embeddings_file exists, because they are mutually exclusive
    if str(embeddings_file) != "":
        # TODO [Optimization] Might add an existing embeddings_file or remove embeddings_file from file_manager
        # config_dict["embedder_name"] = ""
        pass  # Ignore embeddings_file for now

    task_manager = TaskManager()
    # TODO Replace this by a appropriate model hash in the future to avoid costly retraining
    task_id = task_manager.get_unique_task_id(task=BiotrainerTask)

    model_path = file_manager.get_biotrainer_model_path(database_hash=database_hash, model_hash=task_id)
    if model_path.exists():
        return jsonify({"task_id": task_id})

    config_dict["output_dir"] = str(model_path.absolute())

    config_file_yaml = yaml.dump(config_dict)
    config_file_path = file_manager.save_file(database_hash=database_hash, file_type=StorageFileType.BIOTRAINER_CONFIG,
                                              file_content=config_file_yaml, model_hash=task_id)
    log_path = file_manager.get_file_path(database_hash=database_hash,
                                          file_type=StorageFileType.BIOTRAINER_LOGGING,
                                          model_hash=task_id, check_exists=False)

    biotrainer_process = BiotrainerTask(config_path=config_file_path, config_dict=config_dict,
                                        database_instance=current_app.config["EMBEDDINGS_DATABASE"],
                                        log_path=log_path)
    task_id = task_manager.add_task(task=biotrainer_process, task_id=task_id)

    return jsonify({"task_id": task_id})


# Endpoint to retrieve model files after training is finished
@prediction_models_service_route.route('/prediction_models_service/model_files', methods=['POST'])
def model_files():
    model_file_data = request.get_json()
    database_hash = model_file_data.get("database_hash")
    model_hash = model_file_data.get("model_hash")

    task_status = TaskManager().get_task_status(model_hash)
    if task_status != TaskStatus.FINISHED:
        return jsonify({"error": "Trying to retrieve model files before task has finished!"})

    user_id = UserManager.get_user_id_from_request(request)
    file_manager = FileManager(user_id=user_id)
    model_file_dict = file_manager.get_biotrainer_result_files(database_hash=database_hash, model_hash=model_hash)
    return jsonify(model_file_dict)
