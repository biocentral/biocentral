import flask
from flask import request, Blueprint, jsonify

from biotrainer.utilities import read_FASTA
from biocentral_server.server_management import UserManager, FileManager, StorageFileType

from .analysis_functions import calculate_levenshtein_distances

data_analysis_route = Blueprint("data_analysis", __name__)


# Endpoint for umap calculation of embeddings
@data_analysis_route.route('/data_analysis/mmseqs_sequence_similarity', methods=['POST'])
def mmseqs_sequence_similarity():

    return jsonify({"umap": ""})


@data_analysis_route.route('/data_analysis/levenshtein_distance', methods=['POST'])
def levenshtein_distance():
    sequence_data = request.get_json()

    user_id = UserManager.get_user_id_from_request(req=request)
    database_hash: str = sequence_data.get('database_hash')

    try:
        file_manager = FileManager(user_id=user_id)
        sequence_file_path = file_manager.get_file_path(database_hash=database_hash,
                                                        file_type=StorageFileType.SEQUENCES)
    except FileNotFoundError as e:
        return jsonify({"error": str(e)})

    seq_records = read_FASTA(str(sequence_file_path))
    seq_dict = {seq.id: seq.seq for seq in seq_records}

    levenshtein_distances = calculate_levenshtein_distances(sequences=seq_dict)

    return jsonify(levenshtein_distances)
