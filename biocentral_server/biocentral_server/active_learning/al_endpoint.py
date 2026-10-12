from fastapi import APIRouter, Request, Depends
from fastapi_limiter.depends import RateLimiter

from .endpoint_models import (
    ActiveLearningScreeningIterationRequest,
    ActiveLearningEngineeringIterationRequest,
    ActiveLearningScreeningSimulationRequest,
)

from .al_simulation_task import ActiveLearningScreeningSimulationTask
from .al_iteration_tasks import (
    ActiveLearningScreeningIterationTask,
    ActiveLearningEngineeringIterationTask,
)

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
    "/screening_iteration",
    response_model=StartTaskResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Validation Error"},
    },
    summary="Run one active learning screening iteration",
    description="Submit an active learning screening iteration job",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def active_learning_screening_iteration(
    request_data: ActiveLearningScreeningIterationRequest, request: Request
):
    """
    Run an active learning screening iteration.

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
    task_id = task_manager.get_unique_task_id(task=ActiveLearningScreeningIterationTask)

    # Get model hash for storage
    # file_manager = FileManager(user_id=user_id)
    # model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)

    # Launch AL process
    al_process = ActiveLearningScreeningIterationTask(
        al_campaign_config=request_data.campaign_config,
        al_iteration_config=request_data.iteration_config,
    )
    task_manager.add_task(task=al_process, task_id=task_id, user_id=user_id)

    return StartTaskResponse(task_id=task_id)


@router.post(
    "/engineering_iteration",
    response_model=StartTaskResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Validation Error"},
    },
    summary="Run one active learning engineering iteration",
    description="Submit an active learning engineering iteration job",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def active_learning_engineering_iteration(
    request_data: ActiveLearningEngineeringIterationRequest, request: Request
):
    """
    Run an active learning engineering iteration.
    """
    # Get user and file manager
    user_id = await UserManager.get_user_id_from_request(req=request)

    # Create task id
    task_manager = TaskManager()
    task_id = task_manager.get_unique_task_id(
        task=ActiveLearningEngineeringIterationTask
    )

    # Get model hash for storage
    # file_manager = FileManager(user_id=user_id)
    # model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)

    # Launch AL process
    al_process = ActiveLearningEngineeringIterationTask(
        al_campaign_config=request_data.campaign_config,
        al_iteration_config=request_data.iteration_config,
    )
    task_manager.add_task(task=al_process, task_id=task_id, user_id=user_id)

    return StartTaskResponse(task_id=task_id)


@router.post(
    "/screening_simulation",
    response_model=StartTaskResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Validation Error"},
    },
    summary="Run a simulated active learning screening campaign",
    description="Submit an active learning screening simulation job",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def active_learning_screening_simulation(
    request_data: ActiveLearningScreeningSimulationRequest, request: Request
):
    """
    Run an active learning simulated screening campaign.

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
    task_id = task_manager.get_unique_task_id(
        task=ActiveLearningScreeningSimulationTask
    )

    # Get model hash for storage
    # file_manager = FileManager(user_id=user_id)
    # model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)

    # Launch AL process
    al_process = ActiveLearningScreeningSimulationTask(
        al_campaign_config=request_data.campaign_config,
        al_simulation_config=request_data.simulation_config,
    )
    task_manager.add_task(task=al_process, task_id=task_id, user_id=user_id)

    return StartTaskResponse(task_id=task_id)
