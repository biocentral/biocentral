from flask import Blueprint, jsonify, request

from ..server_management import UserManager, FileManager, StorageFileType, TaskManager

biocentral_service_route = Blueprint("biocentral_service", __name__)


# Endpoint to get all available services
@biocentral_service_route.route('/biocentral_service/services', methods=['GET'])
def services():
    return jsonify(
        {"services": ["biocentral_service", "embeddings_service", "ppi_service", "prediction_models_service",
                      "protein_service", "plm_eval_service"]})


# Endpoint to check if a file for the given database hash exists
@biocentral_service_route.route('/biocentral_service/hashes/<hash_id>/<file_type>', methods=['GET'])
def hashes(hash_id, file_type):
    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)
    storage_file_type: StorageFileType = FileManager.convert_file_type_str_to_enum(file_type=file_type)

    exists = file_manager.check_file_exists(database_hash=hash_id, file_type=storage_file_type)

    return jsonify({hash_id: exists})


# Endpoint to transfer a file
@biocentral_service_route.route('/biocentral_service/transfer_file', methods=['POST'])
def transfer_file():
    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)

    database_data = request.get_json()
    database_hash = database_data.get('hash')
    file_manager.create_hash_dir_structure_if_necessary(database_hash=database_hash)

    storage_file_type: StorageFileType = FileManager.convert_file_type_str_to_enum(database_data.get('file_type'))
    if file_manager.check_file_exists(database_hash=database_hash, file_type=storage_file_type):
        return jsonify({"error": "Hash already exists at server, "
                                 "this endpoint should not have been used because transferring the file "
                                 "is not necessary."})

    file_content = database_data.get('file')  # Fasta format
    file_manager.save_file(database_hash=database_hash, file_type=storage_file_type, file_content=file_content)
    return jsonify(success=True)


# Endpoint to check task status
@biocentral_service_route.route('/biocentral_service/task_status/<task_id>', methods=['GET'])
def task_status(task_id):
    # Check the status of the task based on task_id
    # Retrieve task status from the distributed server or backend system
    # Return the task status
    dtos = TaskManager().get_all_task_updates(task_id=task_id)
    return jsonify({idx: dto.dict() for idx, dto in enumerate(dtos)})
