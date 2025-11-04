from fastapi import APIRouter, HTTPException, status, Request
from biotrainer.input_files import BiotrainerSequenceRecord
from biotrainer.protocols import Protocol
from biotrainer.config import Configurator, ConfigurationException

from .endpoint_models import (
    ConfigVerificationRequest,
    ConfigVerificationResponse,
    ProtocolsResponse,
    ConfigOptionsResponse,
    StartTrainingRequest,
    ModelFilesRequest,
    ModelFilesResponse,
    StartInferenceRequest,
    ErrorResponse,
    ConfigOption,
)

from .biotrainer_task import BiotrainerTask
from .biotrainer_inference_task import BiotrainerInferenceTask
from ..server_management import (
    TaskManager,
    UserManager,
    FileManager,
    NotFoundErrorResponse,
    StartTaskResponse,
)

# Create APIRouter
router = APIRouter(
    prefix="/custom_models_service",
    tags=["custom_models"],
    responses={404: {"model": NotFoundErrorResponse}},
)


@router.get(
    "/config_options/{protocol}",
    response_model=ConfigOptionsResponse,
    responses={400: {"model": ErrorResponse}},
    summary="Get configuration options for a protocol",
    description="Retrieve available configuration options for a specific biotrainer protocol",
)
def config_options(protocol: str):
    """Get configuration options by protocol from biotrainer"""
    try:
        protocol_obj = Protocol.from_string(protocol)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid protocol: {protocol}",
        )

    options = Configurator.get_option_dicts_by_protocol(
        protocol=protocol_obj, sub_configs_to_include=[]
    )
    presets = BiotrainerTask.get_config_presets()

    filtered_options = []
    for option_dict in options:
        for k, v in option_dict:
            if k not in presets:
                filtered_options.append(ConfigOption(key=k, value=v))

    return ConfigOptionsResponse(options=filtered_options)


@router.post(
    "/verify_config/",
    response_model=ConfigVerificationResponse,
    summary="Verify configuration",
    description="Validate a biotrainer configuration dict",
)
def verify_config(request_data: ConfigVerificationRequest):
    """Verify configuration options"""
    try:
        config_dict = request_data.config_dict
        configurator = Configurator.from_config_dict(config_dict)
        configurator.verify_config(ignore_file_checks=True)
        return ConfigVerificationResponse(error="")
    except ConfigurationException as config_exception:
        return ConfigVerificationResponse(error=str(config_exception))


@router.get(
    "/protocols",
    response_model=ProtocolsResponse,
    summary="Get available protocols",
    description="Retrieve list of all available biotrainer protocols",
)
def protocols():
    """Get available protocols from biotrainer"""
    all_protocols = list(map(str, Protocol.all()))
    return ProtocolsResponse(protocols=all_protocols)


@router.post(
    "/start_training",
    response_model=StartTaskResponse,
    responses={400: {"model": ErrorResponse}, 404: {"model": ErrorResponse}},
    summary="Start model training",
    description="Submit a new model training job with specified configuration and training data",
)
def start_training(request_data: StartTrainingRequest, request: Request):
    """Start model training for biotrainer"""
    # Parse and validate configuration
    try:
        config_dict = request_data.config_dict
        configurator = Configurator.from_config_dict(config_dict)
        configurator.verify_config(ignore_file_checks=True)
    except ConfigurationException as config_exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(config_exception)
        )

    # Get user and file manager
    user_id = UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)

    # Create and submit training task
    task_manager = TaskManager()
    task_id = task_manager.get_unique_task_id(task=BiotrainerTask)
    model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)

    biotrainer_process = BiotrainerTask(
        model_path=model_path,
        config_dict=config_dict,
        training_data=request_data.training_data,
    )
    task_id = task_manager.add_task(task=biotrainer_process, task_id=task_id)

    return StartTaskResponse(task_id=task_id)


@router.post(
    "/model_files",
    response_model=ModelFilesResponse,
    responses={400: {"model": ErrorResponse}, 404: {"model": ErrorResponse}},
    summary="Retrieve model files",
    description="Get trained model files after training completion",
)
def model_files(request_data: ModelFilesRequest, request: Request):
    """Retrieve model files after training is finished"""
    user_id = UserManager.get_user_id_from_request(request)
    file_manager = FileManager(user_id=user_id)

    model_file_dict = file_manager.get_biotrainer_result_files(
        model_hash=request_data.model_hash
    )

    if not model_file_dict or len(model_file_dict) == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Model files not found. Training may not be complete or model hash is invalid.",
        )

    return ModelFilesResponse(**model_file_dict)


@router.post(
    "/start_inference",
    response_model=StartTaskResponse,
    responses={400: {"model": ErrorResponse}, 404: {"model": ErrorResponse}},
    summary="Start model inference",
    description="Submit sequences for prediction using a trained model",
)
def start_inference(request_data: StartInferenceRequest, request: Request):
    """Do inference from trained models"""

    # Convert sequence_data to BiotrainerSequenceRecord objects
    seq_records = [
        BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
        for seq_id, seq in request_data.sequence_data.items()
    ]

    # Get model path
    user_id = UserManager.get_user_id_from_request(request)
    file_manager = FileManager(user_id=user_id)
    model_out_path = file_manager.get_biotrainer_model_path(
        model_hash=request_data.model_hash
    )

    if model_out_path is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Model not found. Invalid model hash or model training not completed.",
        )

    # Create and submit inference task
    inference_task = BiotrainerInferenceTask(
        model_out_path=model_out_path, seq_records=seq_records
    )
    task_manager = TaskManager()
    task_id = task_manager.add_task(task=inference_task)

    return StartTaskResponse(task_id=task_id)
