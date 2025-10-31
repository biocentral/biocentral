import torch
import psutil
from biocentral_server.biocentral.models import TaskStatusResponse

from fastapi import APIRouter, Request

from .models import TransferFileRequest
from ..server_management import (
    UserManager,
    FileManager,
    StorageFileType,
    TaskManager,
    ErrorResponse,
    NotFoundErrorResponse,
)

router = APIRouter(
    prefix="/biocentral_service",
    tags=["biocentral"],
    responses={404: {"model": NotFoundErrorResponse}},
)


# Endpoint to get all available services
@router.get("/services")
def services():
    return {
        "services": [
            "biocentral_service",
            "embeddings_service",
            "ppi_service",
            "custom_models_service",
            "protein_service",
            "plm_eval_service",
            "prediction_service",
        ]
    }


# Endpoint to check if a file for the given database hash exists
@router.get("/hashes/{hash_id}/{file_type}")
def hashes(hash_id: str, file_type: str, request: Request):
    # Adapt FastAPI request to expected interface for UserManager

    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)
    storage_file_type: StorageFileType = StorageFileType.from_string(
        file_type=file_type
    )

    exists = file_manager.check_file_exists(
        database_hash=hash_id, file_type=storage_file_type
    )

    return {hash_id: exists}


# Endpoint to transfer a database file
@router.post(
    "/transfer_file",
    responses={400: {"model": ErrorResponse}},
)
def transfer_file(transfer_file_request: TransferFileRequest, request: Request):
    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)

    database_hash = transfer_file_request.hash

    storage_file_type: StorageFileType = StorageFileType.from_string(
        transfer_file_request.file_type
    )
    if file_manager.check_file_exists(
        database_hash=database_hash, file_type=storage_file_type
    ):
        return {
            "error": "Hash already exists at server, this endpoint should not have been used because transferring the file is not necessary."
        }

    file_content = transfer_file_request.file  # Fasta format
    file_manager.save_file(
        database_hash=database_hash,
        file_type=storage_file_type,
        file_content=file_content,
    )
    return {"success": True}


# Endpoint to check task status
@router.get("/task_status/{task_id}", response_model=TaskStatusResponse)
def task_status(task_id: str):
    # Check the status of the task based on task_id
    # Retrieve task status from the distributed server or backend system
    # Return the task status
    dtos = TaskManager().get_new_task_updates(task_id=task_id)
    return TaskStatusResponse(
        dtos={str(idx): dto.dict() for idx, dto in enumerate(dtos)}
    )


# Endpoint to check task status (resumed)
@router.get("/task_status_resumed/{task_id}", response_model=TaskStatusResponse)
def task_status_resumed(task_id: str):
    # Check the status of the task based on task_id
    # Retrieve task status from the distributed server or backend system
    # Return the task status
    dtos = TaskManager().get_all_task_updates_from_start(task_id=task_id)
    return TaskStatusResponse(
        dtos={str(idx): dto.dict() for idx, dto in enumerate(dtos)}
    )


# Endpoint to get some server statistics
@router.get("/stats/")
def stats():
    def _get_usable_cpu_count():
        try:
            # Try to use psutil, which works on Windows, Linux, and macOS
            return len(psutil.Process().cpu_affinity())
        except AttributeError:
            # If cpu_affinity is not available (e.g., on macOS), fall back to logical CPU count
            return psutil.cpu_count(logical=True)

    usable_cpu_count = _get_usable_cpu_count()
    disk_usage: str = FileManager(user_id="").get_disk_usage()

    number_requests_since_start = UserManager.get_total_number_of_requests_since_start()
    n_processes = TaskManager().get_current_number_of_running_tasks()

    cuda_available = torch.cuda.is_available()
    cuda_device_count = torch.cuda.device_count() if cuda_available else 0
    mps_available = torch.backends.mps.is_available()

    return {
        "usable_cpu_count": usable_cpu_count,
        "disk_usage": disk_usage,
        "number_requests_since_start": number_requests_since_start,
        "n_processes": n_processes,
        "cuda_available": cuda_available,
        "cuda_device_count": cuda_device_count,
        "mps_available": mps_available,
    }
