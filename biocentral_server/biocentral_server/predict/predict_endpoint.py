from fastapi import APIRouter, Depends, Request

from biotrainer.input_files import BiotrainerSequenceRecord
from fastapi_limiter.depends import RateLimiter

from .multi_prediction_task import MultiPredictionTask
from .models import get_metadata_for_all_models, filter_models
from .endpoint_models import PredictionRequest, ModelMetadataResponse

from ..server_management import (
    TaskManager,
    UserManager,
    ErrorResponse,
    NotFoundErrorResponse,
    StartTaskResponse,
)

router = APIRouter(
    prefix="/prediction_service",
    tags=["prediction"],
    responses={404: {"description": "Not found"}},
)


# Endpoint to get all available model metadata
@router.get(
    "/model_metadata",
    response_model=ModelMetadataResponse,
    responses={},
    summary="Get predict model metadata",
    description="Get metadata for available prediction models",
    dependencies=[Depends(RateLimiter(times=10, seconds=60))],
)
def model_metadata():
    return ModelMetadataResponse(
        metadata={
            name: mdata.to_dict()
            for name, mdata in get_metadata_for_all_models().items()
        }
    )


@router.post(
    "/predict",
    response_model=StartTaskResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Bad Request"},
        404: {"model": NotFoundErrorResponse, "description": "Model not found"},
    },
    summary="Submit protein sequence prediction job",
    description="Submit sequences for prediction using specified models and receive a task ID for tracking",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def predict(request_data: PredictionRequest, request: Request):
    """
    Endpoint for protein sequence prediction using a single or multiple models
    """
    model_names = request_data.model_names
    model_metadata = get_metadata_for_all_models()

    # Check if all requested models exist
    missing_models = [name for name in model_names if name not in model_metadata.keys()]
    if missing_models:
        return NotFoundErrorResponse(
            error=f"The following models were not found: {', '.join(missing_models)}",
            error_code=404,
        )

    # Convert sequence input to BiotrainerSequenceRecord objects
    sequence_input = [
        BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
        for seq_id, seq in request_data.sequence_input.items()
    ]

    # Get filtered models and create prediction task
    models = filter_models(model_names=model_names)
    prediction_task = MultiPredictionTask(
        models=models,
        sequence_input=sequence_input,
        batch_size=1,  # TODO batch_size
    )

    # Add task to task manager
    user_id = await UserManager.get_user_id_from_request(req=request)
    task_id = TaskManager().add_task(prediction_task, user_id=user_id)

    return StartTaskResponse(task_id=task_id)
