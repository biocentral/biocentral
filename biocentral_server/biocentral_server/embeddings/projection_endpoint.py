from biotrainer.input_files import BiotrainerSequenceRecord
from fastapi_limiter.depends import RateLimiter
from fastapi import APIRouter, HTTPException, status, Request, Depends

from protspace.utils import (
    DimensionReductionConfig as ProtSpaceDimensionReductionConfig,
    REDUCERS,
)

from .endpoint_models import GetProjectionConfigResponse, ProjectionRequest
from .protspace_task import ProtSpaceTask

from ..server_management import (
    TaskManager,
    UserManager,
    StartTaskResponse,
    ErrorResponse,
)
from ..utils import convert_config

router = APIRouter(
    prefix="/projection_service",
    tags=["projections"],
    responses={404: {"description": "Not found"}},
)


# Endpoint for ProtSpace dimensionality reduction methods for sequences
@router.get(
    "/projection_config",
    response_model=GetProjectionConfigResponse,
    responses={404: {"model": ErrorResponse}},
    summary="Get Protspace config options",
    description="Get Protspace project configs by projection method",
    dependencies=[Depends(RateLimiter(times=2, seconds=20))],
)
def projection_config():
    methods = list(REDUCERS.keys())

    protspace_default_config = ProtSpaceDimensionReductionConfig()
    projection_config_by_method = {
        method: protspace_default_config.parameters_by_method(method)
        for method in methods
    }
    return GetProjectionConfigResponse(projection_config=projection_config_by_method)


# Endpoint for ProtSpace dimensionality reduction methods for sequences
@router.post(
    "/project",
    response_model=StartTaskResponse,
    responses={404: {"model": ErrorResponse}},
    summary="Calculate projections",
    description="Calculate projections for embeddings using Protspace",
    dependencies=[Depends(RateLimiter(times=1, seconds=120))],
)
async def project(request_data: ProjectionRequest, request: Request):
    method = request_data.method
    sequence_data = request_data.sequence_data
    config_dict = request_data.config
    config = convert_config(config_dict)
    embedder_name = request_data.embedder_name

    if method not in REDUCERS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=f"Unknown method: {method}"
        )

    protspace_task = ProtSpaceTask(
        embedder_name=embedder_name,
        sequences=[
            BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
            for seq_id, seq in sequence_data.items()
        ],
        method=method,
        config=config,
    )

    user_id = await UserManager.get_user_id_from_request(request)
    task_manager = TaskManager()
    task_id = task_manager.add_task(task=protspace_task, user_id=user_id)
    print(task_id)

    return StartTaskResponse(task_id=task_id)
