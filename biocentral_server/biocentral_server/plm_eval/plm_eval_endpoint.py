import base64
import requests

from pathlib import Path
from typing import Optional
from functools import lru_cache
from fastapi import APIRouter, Request
from biotrainer.embedders import get_predefined_embedder_names
from biotrainer.autoeval.pbc.pbc_datasets import PBC_DATASETS

from .autoeval_task import AutoEvalTask
from .endpoint_models import (
    PLMEvalInformationResponse,
    PLMEvalInformation,
    PLMEvalTaskInformation,
    PLMEvalValidateRequest,
    PLMEvalValidateResponse,
    PLMEvalAutoevalRequest,
)

from ..utils import get_logger
from ..server_management import (
    UserManager,
    TaskManager,
    FileManager,
    StorageFileType,
    ErrorResponse,
    NotFoundErrorResponse,
    StartTaskResponse,
)

logger = get_logger(__name__)

router = APIRouter(
    prefix="/plm_eval_service",
    tags=["plm_eval"],
    responses={404: {"model": NotFoundErrorResponse}},
)


# TODO Improve caching such that results that are older than one hour are omitted for new huggingface models
@lru_cache(maxsize=12)
def _validate_model_id(model_id: str):
    if model_id in get_predefined_embedder_names():
        return ""

    url = f"https://huggingface.co/api/models/{model_id}"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            # Model exists
            return ""
        elif response.status_code == 401:
            # Model not found
            return "Model not found on huggingface!"
        else:
            # Handle other status codes
            return f"Unexpected huggingface status code: {response.status_code}"
    except requests.RequestException as e:
        return f"Error checking model availability on huggingface: {e}"


@router.get(
    "/plm_eval_information",
    response_model=PLMEvalInformationResponse,
    responses={},
    summary="Get PLM eval information",
    description="Get information about PLM eval datasets and process",
)
def plm_eval_information():
    framework_datasets = PBC_DATASETS

    # TODO Convert automatically or move to biotrainer.autoeval
    return PLMEvalInformationResponse(
        info=PLMEvalInformation(
            n_tasks=len(framework_datasets),
            tasks=[
                PLMEvalTaskInformation(
                    name="subcellular_location",
                    description="Subcellular location prediction",
                ),
                PLMEvalTaskInformation(
                    name="secondary_structure",
                    description="Secondary structure prediction",
                ),
            ],
        )
    )


@router.post(
    "/validate_model_id",
    response_model=PLMEvalValidateResponse,
    responses={400: {"model": ErrorResponse}},
    summary="Validate model ID",
    description="Validate if the given model id exists on huggingface and can be used for plm_eval",
)
def validate(request_data: PLMEvalValidateRequest, request: Request):
    error = _validate_model_id(request_data.model_id)
    return PLMEvalValidateResponse(
        valid=error != "", error=error if error != "" else None
    )


@router.post(
    "/autoeval",
    response_model=StartTaskResponse,
    responses={404: {"model": ErrorResponse}},
    summary="Automated Protein Language Model Evaluation",
    description="Automated protein language model evaluation on pre-defined, curated datasets and tasks",
)
def autoeval(request_data: PLMEvalAutoevalRequest, request: Request):
    model_id = request_data.model_id

    # ONNX
    onnx_file = request_data.onnx_file
    tokenizer_config = request_data.tokenizer_config

    user_id = UserManager.get_user_id_from_request(req=request)

    onnx_path: Optional[Path] = None
    tokenizer_config_path: Optional[Path] = None
    if onnx_file and tokenizer_config:
        onnx_bytes = base64.b64decode(onnx_file)
        file_manager = FileManager(user_id=user_id)
        onnx_path = file_manager.save_file(
            file_type=StorageFileType.ONNX_MODEL,
            file_content=onnx_bytes,
            embedder_name=model_id,
        )
        tokenizer_config_path = file_manager.save_file(
            file_type=StorageFileType.TOKENIZER_CONFIG,
            file_content=tokenizer_config,
            embedder_name=model_id,
        )
    else:
        error = _validate_model_id(model_id)
        if error != "":
            return NotFoundErrorResponse(error=error)

    task = AutoEvalTask(
        embedder_name=model_id,
        user_id=user_id,
        onnx_path=str(onnx_path) if onnx_path else None,
        tokenizer_config_path=str(tokenizer_config_path)
        if tokenizer_config_path
        else None,
    )

    task_id = TaskManager().add_task(task=task)

    return StartTaskResponse(task_id=task_id)
