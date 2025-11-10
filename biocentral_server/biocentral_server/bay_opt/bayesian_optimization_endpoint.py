import json
import hashlib

from fastapi import APIRouter, HTTPException, status, Request, Depends
from fastapi_limiter.depends import RateLimiter

from .endpoint_models import (
    BayesianOptimizationRequest,
)

from .bayesian_optimization_task import BayesTask
from ..utils import get_logger
from ..server_management import (
    TaskManager,
    UserManager,
    FileManager,
    StartTaskResponse,
    ErrorResponse,
    NotFoundErrorResponse,
)

logger = get_logger(__name__)

# Create APIRouter
router = APIRouter(
    prefix="/bayesian_optimization_service",
    tags=["bayesian_optimization"],
    responses={404: {"model": NotFoundErrorResponse}},
)


@router.post(
    "/training",
    response_model=StartTaskResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Validation Error"},
        404: {"model": ErrorResponse, "description": "Database Not Found"},
    },
    summary="Start Bayesian optimization training",
    description="Submit a Bayesian optimization job with specified configuration and training data",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
def train_and_inference(request_data: BayesianOptimizationRequest, request: Request):
    """
    Launch Bayesian optimization training and inference.

    This endpoint:
    1. Takes uploaded dataset from the file manager
    2. Embeds the sequences
    3. Launches BO model training process and obtains ranking based on score
    4. Returns task ID for tracking progress
    """
    logger.info(f"Request train_and_inference: {request_data.model_dump()}")

    # Convert Pydantic model to dict for BayesTask
    config_dict = request_data.model_dump()

    # Get user and file manager
    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)
    task_manager = TaskManager()

    # Generate unique task ID based on config
    task_hash = hashlib.md5(
        json.dumps(config_dict, sort_keys=True).encode("utf-8")
    ).hexdigest()
    task_id = f"biocentral-bayesian_optimization-{task_hash}"

    # Get output path
    output_dir = file_manager.get_biotrainer_model_path(model_hash=task_id)
    logger.info(f"Output_path: {output_dir}")

    # Add paths to config
    config_dict["output_dir"] = str(output_dir.absolute())

    # Get input file
    try:
        input_file = file_manager.get_file_path_for_training(
            database_hash=request_data.database_hash
        )
        config_dict["input_file"] = input_file
    except FileNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))

    # Launch BO process
    bo_process = BayesTask(config_dict)
    task_manager.add_task(task=bo_process, task_id=task_id)

    return StartTaskResponse(task_id=task_id)
