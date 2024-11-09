import json
import logging
import numpy as np
import pandas as pd

from biotrainer.protocols import Protocol
from biotrainer.utilities import get_device, read_FASTA
from flask import request, Blueprint, jsonify, current_app
from biotrainer.embedders import get_embedding_service, EmbeddingService

from .umap_analysis import calculate_umap
from .embed import compute_embeddings, compute_embeddings_and_save_to_db

from ..utils import str2bool
from ..server_management import FileManager, UserManager, StorageFileType, EmbeddingsDatabase

logger = logging.getLogger(__name__)

embeddings_service_route = Blueprint("embeddings_service", __name__)


def _round_embeddings(embeddings: dict, reduced: bool):
    # TODO Document rounding
    if reduced:
        return {sequence_id: [round(val, 4) for val in embedding.tolist()] for sequence_id, embedding in
                embeddings.items()}
    return {sequence_id: [[round(val, 4) for val in perResidue.tolist()] for perResidue in embedding] for
            sequence_id, embedding in
            embeddings.items()}


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

    all_seq_records = read_FASTA(str(sequence_file_path))
    all_seqs = {seq.id: str(seq.seq) for seq in all_seq_records}

    # List of embedder names that should not be saved in the database
    EXCLUDED_EMBEDDERS = ['one_hot_encoding']

    if embedder_name in EXCLUDED_EMBEDDERS:
        all_embeddings = compute_embeddings(embedder_name, all_seqs, embeddings_out_path, reduce_by_protocol,
                                            use_half_precision, device)
    else:
        all_embeddings = compute_embeddings_and_save_to_db(embedder_name, all_seqs, embeddings_out_path,
                                                           reduce_by_protocol,
                                                           use_half_precision, device)

    embeddings_double_list = _round_embeddings({triple.id: triple.embd for triple in all_embeddings}, reduced=reduce)

    # Remove huggingface / prefix
    embedder_name = embedder_name.split("/")[-1]
    if use_half_precision:
        embedder_name += "-HalfPrecision"
    return jsonify({"embeddings_file": {embedder_name: embeddings_double_list}})


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
