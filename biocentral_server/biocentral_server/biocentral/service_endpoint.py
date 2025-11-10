from typing import Optional

import torch
import psutil
from biocentral_server.biocentral.endpoint_models import TaskStatusResponse

from fastapi import APIRouter, Request, HTTPException, status

from ..server_management import (
    UserManager,
    FileManager,
    TaskManager,
    NotFoundErrorResponse,
)

router = APIRouter(
    prefix="/biocentral_service",
    tags=["biocentral"],
    responses={404: {"model": NotFoundErrorResponse}},
)


def check_task_ownership(request: Request, task_id: str) -> Optional[TaskManager]:
    """Require that the requester matches the user associated with the task"""
    current_user = UserManager.get_user_id_from_request(req=request)
    task_manager = TaskManager()
    owner = task_manager.get_task_owner(task_id=task_id)
    if owner is None or owner == "":
        # Task not found
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Task not found"
        )
    if owner != current_user:
        # Task exists but belongs to a different user
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    return task_manager


@router.get(
    "/welcome_message",
)
def welcome_message():
    return """
    Welcome to the biocentral server!
    By using this server you agree to the following terms and conditions:
    1. All usage of the server is for peaceful research purposes only.
    2. Protein sequences are only processed, but not stored.
    3. The following data is stored for an unspecified period of time:
        * Computed embeddings (by model name and sequence hash)
        * Trained models (by model hash)
        * Sequence metadata (number of sequences provided, lengths, amino acid composition)
    4. If used in your research, please cite the biocentral paper.
    """


# Endpoint to check task status
@router.get(
    "/task_status/{task_id}",
    response_model=TaskStatusResponse,
    response_model_exclude_none=True,
)
def task_status(task_id: str, request: Request):
    task_manager = check_task_ownership(request=request, task_id=task_id)

    dtos = task_manager.get_new_task_updates(task_id=task_id)
    return TaskStatusResponse(dtos=dtos)


# Endpoint to check task status (resumed)
@router.get(
    "/task_status_resumed/{task_id}",
    response_model=TaskStatusResponse,
    response_model_exclude_none=True,
)
def task_status_resumed(task_id: str, request: Request):
    task_manager = check_task_ownership(request=request, task_id=task_id)

    dtos = task_manager.get_all_task_updates_from_start(task_id=task_id)
    return TaskStatusResponse(dtos=dtos)


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
