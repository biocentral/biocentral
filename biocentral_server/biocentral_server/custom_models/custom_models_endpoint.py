from typing import Annotated

from fastapi_limiter.depends import RateLimiter
from biotrainer.training.config import Configurator
from biotrainer_core.data_classes import SequenceData, Protocol
from fastapi import APIRouter, HTTPException, status, Request, Depends
from typing import Optional, Any

import time
from collections import OrderedDict
from dataclasses import dataclass
from ..utils import get_logger
logger = get_logger(__name__)

from .endpoint_models import (
    ConfigVerificationRequest,
    ConfigVerificationResponse,
    ConfigOptionsResponse,
    StartTrainingRequest,
    ModelFilesRequest,
    ModelFilesResponse,
    StartInferenceRequest,
    ErrorResponse,
    ClusterHBIRequest,
    ClusterHBIResponse,
    SplitHBIRequest,
    SplitHBIResponse,
)
from biocentral_server.proteins.proteins_task import (
    run_pymmseqs_clustering,
)
from .hbi_service import (
    run_easy_search_lookup,
    compute_hbi_metrics_from_lookup,
    compute_hbi_cluster_metrics,
)
from .biotrainer_task import BiotrainerTask, get_config_presets
from .biotrainer_inference_task import BiotrainerInferenceTask
from ..server_management import (
    TaskManager,
    UserManager,
    FileManager,
    NotFoundErrorResponse,
    MetricsService,
    StartTaskResponse,
)
from ..utils import verify_biotrainer_config

# Create APIRouter
router = APIRouter(
    prefix="/custom_models_service",
    tags=["custom_models"],
    responses={404: {"model": NotFoundErrorResponse}},
)
@dataclass
class CacheEntry:
    data: Any
    last_accessed: float


class InMemoryTTLCache:
    def __init__(self, max_size: int = 10, ttl_seconds: float = 600.0):
        self.max_size = max_size
        self.ttl_seconds = ttl_seconds
        self._cache: OrderedDict[str, CacheEntry] = OrderedDict()

    def _purge_expired(self, now: float) -> None:
        """Remove expired entries"""
        expired_keys = [
            key
            for key, entry in self._cache.items()
            if (now - entry.last_accessed) > self.ttl_seconds
        ]
        for key in expired_keys:
            del self._cache[key]

    def get(self, key: str) -> Optional[Any]:
        now = time.time()
        self._purge_expired(now)

        entry = self._cache.get(key)
        if entry is None:
            return None

        # Accessing the hash renews the timestamp
        entry.last_accessed = now
        self._cache.move_to_end(key)
        return entry.data

    def set(self, key: str, value: Any) -> None:
        now = time.time()
        self._purge_expired(now)

        if key in self._cache:
            # Update existing Entry
            self._cache[key] = CacheEntry(data=value, last_accessed=now)
            self._cache.move_to_end(key)
            return

        # Remove oldest entry when limit is reached
        if len(self._cache) >= self.max_size:
            self._cache.popitem(last=False)

        self._cache[key] = CacheEntry(data=value, last_accessed=now)

    def __contains__(self, key: str):
        return self.get(key) is not None

    def __len__(self) -> int:
        self._purge_expired(time.time())
        return len(self._cache)


DATASET_CACHE = InMemoryTTLCache(max_size=10, ttl_seconds=600)

@router.get(
    "/config_options/{protocol}",
    response_model=ConfigOptionsResponse,
    responses={400: {"model": ErrorResponse}},
    summary="Get configuration options for a protocol",
    description="Retrieve available configuration options for a specific biotrainer protocol",
    dependencies=[Depends(RateLimiter(times=10, seconds=60))],
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
    presets = get_config_presets()

    filtered_options = []
    for option_dict in options:
        name = option_dict.get("name")
        if name not in presets:
            filtered_options.append(option_dict)

    return ConfigOptionsResponse(options=filtered_options)


@router.post(
    "/verify_config/",
    response_model=ConfigVerificationResponse,
    summary="Verify configuration",
    description="Validate a biotrainer configuration dict",
    dependencies=[Depends(RateLimiter(times=5, seconds=60))],
)
def verify_config(request_data: ConfigVerificationRequest):
    """Verify configuration options"""
    _, error = verify_biotrainer_config(request_data.config_dict)
    return ConfigVerificationResponse(error=error)


@router.post(
    "/start_training",
    response_model=StartTaskResponse,
    responses={400: {"model": ErrorResponse}, 404: {"model": ErrorResponse}},
    summary="Start model training",
    description="Submit a new model training job with specified configuration and training data",
    dependencies=[Depends(RateLimiter(times=200, seconds=120))],
)
async def start_training(
    request_data: StartTrainingRequest,
    request: Request,
    metrics_service: Annotated[MetricsService, Depends(MetricsService)],
):
    """Start model training for biotrainer"""
    # Parse and validate configuration
    config_dict = request_data.config_dict
    verified_config, error = verify_biotrainer_config(config_dict)
    if error != "":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=error)

    # Get user and file manager
    user_id = await UserManager.get_user_id_from_request(req=request)
    file_manager = FileManager(user_id=user_id)

    # Create and submit training task
    task_manager = TaskManager()
    task_id = task_manager.get_unique_task_id(task=BiotrainerTask)
    model_path = file_manager.get_biotrainer_model_path(model_hash=task_id)

    # Record metrics
    metrics_service.record_training_data(
        sequences={
            data_point.seq_id: data_point.seq
            for data_point in request_data.training_data
        }
    )

    biotrainer_process = BiotrainerTask(
        model_path=model_path,
        config_dict=verified_config,
        training_data=request_data.training_data,
    )
    task_id = task_manager.add_task(
        task=biotrainer_process, task_id=task_id, user_id=user_id
    )

    return StartTaskResponse(task_id=task_id)


@router.post(
    "/model_files",
    response_model=ModelFilesResponse,
    responses={400: {"model": ErrorResponse}, 404: {"model": ErrorResponse}},
    summary="Retrieve model files",
    description="Get trained model files after training completion",
    dependencies=[Depends(RateLimiter(times=1, seconds=60))],
)
async def model_files(request_data: ModelFilesRequest, request: Request):
    """Retrieve model files after training is finished"""
    user_id = await UserManager.get_user_id_from_request(request)
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
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def start_inference(
    request_data: StartInferenceRequest,
    request: Request,
    metrics_service: Annotated[MetricsService, Depends(MetricsService)],
):
    """Do inference from trained models"""

    # Convert sequence_data to SequenceData objects
    seq_records = [
        SequenceData(seq_id=seq_id, seq=seq)
        for seq_id, seq in request_data.sequence_data.items()
    ]

    # Get model path
    user_id = await UserManager.get_user_id_from_request(request)
    file_manager = FileManager(user_id=user_id)
    model_out_path = file_manager.get_biotrainer_model_path(
        model_hash=request_data.model_hash
    )

    if model_out_path is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Model not found. Invalid model hash or model training not completed.",
        )

    # Record metrics
    metrics_service.record_inference_data(sequences=request_data.sequence_data)

    # Create and submit inference task
    inference_task = BiotrainerInferenceTask(
        model_out_path=model_out_path, sequence_input=seq_records
    )
    task_manager = TaskManager()
    task_id = task_manager.add_task(task=inference_task, user_id=user_id)

    return StartTaskResponse(task_id=task_id)


@router.post(
    "/cluster-hbi/",
    response_model=ClusterHBIResponse,
    summary="Direct synchronous HBI calculation on CPU with bootstrapping and dataset cache",
    dependencies=[Depends(RateLimiter(times=60, seconds=60))],
)
def cluster_hbi(payload: ClusterHBIRequest):
    # resolve caches sequences or store new upload
    if payload.sequence_data:
        DATASET_CACHE.set(payload.dataset_hash, payload.sequence_data)
        sequences = payload.sequence_data
    else:
        sequences = DATASET_CACHE.get(payload.dataset_hash)

    if not sequences:
        raise HTTPException(
            status_code=400,
            detail="Dataset not found in cache. Please provide sequence_data on initial call."
        )
    # run MMseqs2 directly in-thread
    try:
        clusters = run_pymmseqs_clustering(
            sequence_data=sequences,
            sequence_identity_threshold=payload.sequence_identity_threshold,
        )
    except Exception as e:
        logger.error(f"Cluster HBI error: {e}")
        raise HTTPException(status_code=500, detail=f"Clustering error: {str(e)}")

    # calculate HBI score
    try:
        metrics = compute_hbi_cluster_metrics(
            clusters=clusters,
            labels=payload.target_data,
            is_numeric=payload.is_numeric,
            iterations=payload.iterations,
        )
    except Exception as e:
        logger.error(f"Cluster HBI metrics error: {e}")
        raise HTTPException(status_code=500, detail=f"Clustering error: {str(e)}")

    return ClusterHBIResponse(
        metrics=metrics,
        clusters=clusters,
    )


@router.post(
    "/split-hbi/",
    response_model=SplitHBIResponse,
    summary="Evaluate homology transfer between dataset splits via easy_search lookup",
    dependencies=[Depends(RateLimiter(times=30, seconds=60))],
)
def split_hbi(payload: SplitHBIRequest):
    try:
        # MMseqs2 easy_search Top-1 lookup
        top_hits = run_easy_search_lookup(
            train_seqs=payload.train_seqs,
            query_seqs=payload.query_seqs,
            evalue_cutoff=payload.evalue_cutoff,
            min_seq_id=payload.min_seq_id,
        )

        # Bootstrapped split metrics
        metrics = compute_hbi_metrics_from_lookup(
            train_labels=payload.train_labels,
            query_labels=payload.query_labels,
            top_hits_df=top_hits,
            is_numeric=payload.is_numeric,
            iterations=payload.iterations,
        )
    except Exception as e:
        logger.error(f"Split HBI execution error: {e}")
        raise HTTPException(status_code=500, detail=f"Split HBI execution error: {str(e)}")

    evaluated_queries = metrics[0].sample_size if metrics else 0

    return SplitHBIResponse(
        metrics=metrics,
        num_queries=len(payload.query_seqs),
        hits_found=len(top_hits),
        evaluated_queries=evaluated_queries,
    )
