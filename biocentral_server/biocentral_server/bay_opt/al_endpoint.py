from fastapi import APIRouter, Request, Depends
from fastapi_limiter.depends import RateLimiter

from .endpoint_models import (
    ActiveLearningIterationRequest,
    ActiveLearningSimulationRequest,
)

from .al_iteration_task import ActiveLearningIterationTask
from .al_simulation_task import ActiveLearningSimulationTask

from ..utils import get_logger
from ..server_management import (
    TaskManager,
    UserManager,
    StartTaskResponse,
    ErrorResponse,
    NotFoundErrorResponse,
)

logger = get_logger(__name__)

# Create APIRouter
router = APIRouter(
    prefix="/active_learning_service",
    tags=["active_learning"],
    responses={404: {"model": NotFoundErrorResponse}},
)


@router.post(
    "/iteration",
    response_model=StartTaskResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Validation Error"},
    },
    summary="Run one active learning iteration",
    description="Submit an active learning iteration job",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def active_learning_iteration(
    request_data: ActiveLearningIterationRequest, request: Request
):
    """
    Run an active learning iteration.

    This endpoint:
    1. Takes the active learning campaign configuration and iteration configuration from the request body
    2. Embeds the sequences
    3. Launches BO model training process that obtains a ranking based on score
    4. Returns task ID for tracking progress
    """
    # Get user and file manager
    user_id = await UserManager.get_user_id_from_request(req=request)

    # Create task id
    task_manager = TaskManager()
    task_id = task_manager.get_unique_task_id(task=ActiveLearningIterationTask)

    # Get model hash for storage
    # file_manager = FileManager(user_id=user_id)
    # model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)

    # Launch AL process
    al_process = ActiveLearningIterationTask(
        al_campaign_config=request_data.campaign_config,
        al_iteration_config=request_data.iteration_config,
    )
    task_manager.add_task(task=al_process, task_id=task_id, user_id=user_id)

    return StartTaskResponse(task_id=task_id)


@router.post(
    "/simulation",
    response_model=StartTaskResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Validation Error"},
    },
    summary="Run a simulated active learning campaign",
    description="Submit an active learning simulation job",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def active_learning_simulation(
    request_data: ActiveLearningSimulationRequest, request: Request
):
    """
    Run an active learning simulated campaign.

    This endpoint:
    1. Takes uploaded dataset from the file manager
    2. Embeds the sequences
    3. Launches BO model training process that obtains a ranking based on score
    4. Returns task ID for tracking progress
    """
    # Get user and file manager
    user_id = await UserManager.get_user_id_from_request(req=request)

    # Create task id
    task_manager = TaskManager()
    task_id = task_manager.get_unique_task_id(task=ActiveLearningSimulationTask)

    # Get model hash for storage
    # file_manager = FileManager(user_id=user_id)
    # model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)

    # Launch AL process
    al_process = ActiveLearningSimulationTask(
        al_campaign_config=request_data.campaign_config,
        al_simulation_config=request_data.simulation_config,
    )
    task_manager.add_task(task=al_process, task_id=task_id, user_id=user_id)

    return StartTaskResponse(task_id=task_id)
