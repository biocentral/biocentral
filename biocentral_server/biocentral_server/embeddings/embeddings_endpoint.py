import io
import h5py
import json
import base64
import numpy as np

from biotrainer.utilities import get_device
from fastapi_limiter.depends import RateLimiter
from biotrainer.input_files import BiotrainerSequenceRecord
from fastapi import APIRouter, HTTPException, status, Request, Depends

from .endpoint_models import (
    EmbedRequest,
    GetMissingEmbeddingsRequest,
    GetMissingEmbeddingsResponse,
    AddEmbeddingsRequest,
    AddEmbeddingsResponse,
)

from .embedding_task import ExportEmbeddingsTask
from ..utils import str2bool, get_logger
from ..server_management import (
    TaskManager,
    UserManager,
    EmbeddingDatabaseFactory,
    EmbeddingsDatabase,
    StartTaskResponse,
    ErrorResponse,
)

logger = get_logger(__name__)

# Create APIRouter
router = APIRouter(
    prefix="/embeddings_service",
    tags=["embeddings"],
    responses={404: {"description": "Not found"}},
)


@router.post(
    "/embed",
    response_model=StartTaskResponse,
    responses={404: {"model": ErrorResponse}},
    summary="Calculate embeddings",
    description="Submit sequences for embedding calculation using specified embedder model",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
async def embed(request_data: EmbedRequest, request: Request):
    """Endpoint for embeddings calculation"""
    # Convert string booleans to actual booleans
    reduced = str2bool(str(request_data.reduce))
    use_half_precision = str2bool(str(request_data.use_half_precision))
    device = get_device()
    sequence_data = [
        BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
        for seq_id, seq in request_data.sequence_data.items()
    ]

    embedding_task = ExportEmbeddingsTask(
        embedder_name=request_data.embedder_name,
        sequence_input=sequence_data,
        reduced=reduced,
        use_half_precision=use_half_precision,
        device=device,
    )
    user_id = await UserManager.get_user_id_from_request(req=request)

    user_id = UserManager.get_user_id_from_request(req=request)
    task_id = TaskManager().add_task(embedding_task, user_id=user_id)

    return StartTaskResponse(task_id=task_id)


@router.post(
    "/get_missing_embeddings",
    response_model=GetMissingEmbeddingsResponse,
    responses={400: {"model": ErrorResponse}},
    summary="Check missing embeddings",
    description="Check which sequences are missing embeddings for a given embedder and reduction setting",
    dependencies=[Depends(RateLimiter(times=2, seconds=60))],
)
def get_missing_embeddings(request_data: GetMissingEmbeddingsRequest):
    """Endpoint to check which sequences miss embeddings"""
    # Parse sequences (validation already done by Pydantic)
    try:
        sequences = json.loads(request_data.sequences)
    except json.JSONDecodeError:
        # This shouldn't happen due to Pydantic validation, but just in case
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid JSON in sequences"
        )

    embeddings_database: EmbeddingsDatabase = (
        EmbeddingDatabaseFactory().get_embeddings_db()
    )

    exist, non_exist = embeddings_database.filter_existing_embeddings(
        sequences=sequences,
        embedder_name=request_data.embedder_name,
        reduced=request_data.reduced,
    )

    return GetMissingEmbeddingsResponse(missing=list(non_exist.keys()))


@router.post(
    "/add_embeddings",
    response_model=AddEmbeddingsResponse,
    responses={400: {"model": ErrorResponse}},
    summary="Add embeddings",
    description="Add pre-computed embeddings from HDF5 file to the embeddings database",
    dependencies=[Depends(RateLimiter(times=1, seconds=60))],
)
def add_embeddings(request_data: AddEmbeddingsRequest):
    # TODO This endpoint should use async, embeddings db should be converted to async
    """Endpoint to add embeddings from H5 file data"""
    # Parse sequences
    try:
        sequences = json.loads(request_data.sequences)
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid JSON in sequences"
        )

    # Decode base64 data
    try:
        h5_bytes = base64.b64decode(request_data.h5_bytes)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to decode base64 data: {str(e)}",
        )

    # Process H5 file
    try:
        h5_io = io.BytesIO(h5_bytes)
        embeddings_file = h5py.File(h5_io, "r")

        # Create embedding records from H5 data
        embd_records = [
            BiotrainerSequenceRecord(
                seq_id=embeddings_file[idx].attrs["original_id"],
                seq=sequences[embeddings_file[idx].attrs["original_id"]],
                embedding=np.array(embedding),
            )
            for (idx, embedding) in embeddings_file.items()
        ]

        # Save embeddings to database
        embeddings_database: EmbeddingsDatabase = (
            EmbeddingDatabaseFactory().get_embeddings_db()
        )
        embeddings_database.save_embeddings(
            embd_records=embd_records,
            embedder_name=request_data.embedder_name,
            reduced=request_data.reduced,
        )

        embeddings_file.close()

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to process H5 embeddings data: {str(e)}",
        )

    return AddEmbeddingsResponse(success=True)
