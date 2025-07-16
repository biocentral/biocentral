import io
import h5py
import json
import base64
import numpy as np

from biotrainer.utilities import get_device
from flask import request, Blueprint, jsonify
from biotrainer.input_files import BiotrainerSequenceRecord

from .embedding_task import ExportEmbeddingsTask

from ..utils import str2bool, get_logger
from ..server_management import (
    FileManager,
    UserManager,
    StorageFileType,
    TaskManager,
    EmbeddingDatabaseFactory,
    EmbeddingsDatabase,
)

logger = get_logger(__name__)

embeddings_service_route = Blueprint("embeddings_service", __name__)


# Endpoint for embeddings calculation of biotrainer
@embeddings_service_route.route("/embeddings_service/embed", methods=["POST"])
def embed():
    embedding_data = request.get_json()

    user_id = UserManager.get_user_id_from_request(req=request)

    embedder_name: str = embedding_data.get("embedder_name")
    reduced: bool = str2bool(
        embedding_data.get("reduce")
    )  # TODO Change to reduced in API
    database_hash: str = embedding_data.get("database_hash")
    use_half_precision: bool = str2bool(embedding_data.get("use_half_precision"))

    device = get_device()

    try:
        file_manager = FileManager(user_id=user_id)
        input_file_path = file_manager.get_file_path(
            database_hash=database_hash, file_type=StorageFileType.INPUT
        )
        embeddings_out_path = file_manager.get_embeddings_path(
            database_hash=database_hash
        )
    except FileNotFoundError as e:
        return jsonify({"error": str(e)})

    embedding_task = ExportEmbeddingsTask(
        embedder_name=embedder_name,
        sequence_input=input_file_path,
        embeddings_out_path=embeddings_out_path,
        reduced=reduced,
        use_half_precision=use_half_precision,
        device=device,
    )

    task_id = TaskManager().add_task(embedding_task)

    return jsonify({"task_id": task_id})


# Endpoint to check with sequences miss embeddings
@embeddings_service_route.route(
    "/embeddings_service/get_missing_embeddings", methods=["POST"]
)
def get_missing_embeddings():
    missing_embeddings_data = request.get_json()

    sequences = json.loads(missing_embeddings_data.get("sequences"))
    embedder_name = missing_embeddings_data.get("embedder_name")
    reduced = missing_embeddings_data.get("reduced")

    embeddings_database: EmbeddingsDatabase = (
        EmbeddingDatabaseFactory().get_embeddings_db()
    )

    exist, non_exist = embeddings_database.filter_existing_embeddings(
        sequences=sequences, embedder_name=embedder_name, reduced=reduced
    )
    return jsonify({"missing": list(non_exist.keys())})


# Endpoint to check with sequences miss embeddings
@embeddings_service_route.route("/embeddings_service/add_embeddings", methods=["POST"])
def add_embeddings():
    embeddings_data = request.get_json()

    h5_byte_string = embeddings_data.get("h5_bytes")
    sequences = json.loads(embeddings_data.get("sequences"))
    embedder_name = embeddings_data.get("embedder_name")
    reduced = embeddings_data.get("reduced")

    h5_bytes = base64.b64decode(h5_byte_string)

    h5_io = io.BytesIO(h5_bytes)
    embeddings_file = h5py.File(h5_io, "r")

    # "original_id" from embeddings file -> Embedding
    embd_records = [
        BiotrainerSequenceRecord(
            seq_id=embeddings_file[idx].attrs["original_id"],
            seq=sequences[embeddings_file[idx].attrs["original_id"]],
            embedding=np.array(embedding),
        )
        for (idx, embedding) in embeddings_file.items()
    ]

    embeddings_database: EmbeddingsDatabase = (
        EmbeddingDatabaseFactory().get_embeddings_db()
    )
    embeddings_database.save_embeddings(
        embd_records=embd_records, embedder_name=embedder_name, reduced=reduced
    )
    return jsonify({"status": 200})
