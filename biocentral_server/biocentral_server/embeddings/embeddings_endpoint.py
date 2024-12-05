import json
import logging
import numpy as np
import pandas as pd

from biotrainer.protocols import Protocol
from biotrainer.utilities import get_device, read_FASTA
from flask import request, Blueprint, jsonify, current_app

from .umap_analysis import calculate_umap
from .embedding_task import EmbeddingTask

from ..utils import str2bool
from ..server_management import FileManager, UserManager, StorageFileType, TaskManager

logger = logging.getLogger(__name__)

embeddings_service_route = Blueprint("embeddings_service", __name__)


# Endpoint for embeddings calculation of biotrainer
@embeddings_service_route.route('/embeddings_service/embed', methods=['POST'])
def embed():
    embedding_data = request.get_json()

    user_id = UserManager.get_user_id_from_request(req=request)

    embedder_name: str = embedding_data.get('embedder_name')
    reduce: bool = str2bool(embedding_data.get('reduce'))
    database_hash: str = embedding_data.get('database_hash')
    use_half_precision: bool = str2bool(embedding_data.get('use_half_precision'))

    device = get_device()
    reduce_by_protocol = Protocol.sequence_to_class if reduce else Protocol.residue_to_class

    try:
        file_manager = FileManager(user_id=user_id)
        sequence_file_path = file_manager.get_file_path(database_hash=database_hash,
                                                        file_type=StorageFileType.SEQUENCES)
        embeddings_out_path = file_manager.get_embeddings_files_path(database_hash=database_hash)
    except FileNotFoundError as e:
        return jsonify({"error": str(e)})

    embeddings_database = current_app.config["EMBEDDINGS_DATABASE"]
    embedding_task = EmbeddingTask(embedder_name=embedder_name,
                                   sequence_file_path=sequence_file_path,
                                   embeddings_out_path=embeddings_out_path,
                                   protocol=reduce_by_protocol,
                                   use_half_precision=use_half_precision,
                                   device=device,
                                   embeddings_database=embeddings_database)

    task_id = TaskManager().add_task(embedding_task)

    return jsonify({"task_id": task_id})


# Endpoint for umap calculation of embeddings
@embeddings_service_route.route('/embeddings_service/umap', methods=['POST'])
def umap_for_embeddings():
    embedding_data = request.get_json()

    embeddings_per_sequence = json.loads(embedding_data.get("embeddings_per_sequence"))

    print(f"Calculating UMAP for {len(embeddings_per_sequence)} embeddings..")
    umap_df: pd.DataFrame = calculate_umap(embeddings=np.array(embeddings_per_sequence))

    # [[x0,y0], [x1,y1], ..]
    result_list = []
    for _, row in umap_df.iterrows():
        result_list.append([round(float(row["x"]), 4), round(float(row["y"]), 4)])

    return jsonify({"umap_data": {"umap": result_list}})
