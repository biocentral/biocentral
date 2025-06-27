from flask import request, Blueprint, jsonify

from biotrainer.input_files import read_FASTA
from biocentral_server.server_management import UserManager, FileManager, StorageFileType

from .analysis_functions import calculate_levenshtein_distances

protein_analysis_route = Blueprint("protein_analysis", __name__)


# Endpoint for umap calculation of embeddings
@protein_analysis_route.route('/protein_analysis/mmseqs_sequence_similarity', methods=['POST'])
def mmseqs_sequence_similarity():

    return jsonify({"umap": ""})


@protein_analysis_route.route('/protein_analysis/levenshtein_distance', methods=['POST'])
def levenshtein_distance():
    sequence_data = request.get_json()

    user_id = UserManager.get_user_id_from_request(req=request)
    database_hash: str = sequence_data.get('database_hash')

    try:
        file_manager = FileManager(user_id=user_id)
        input_file_path = file_manager.get_file_path(database_hash=database_hash,
                                                        file_type=StorageFileType.INPUT)
    except FileNotFoundError as e:
        return jsonify({"error": str(e)})

    seq_records = read_FASTA(str(input_file_path))
    seq_dict = {seq_record.seq_id: seq_record.seq for seq_record in seq_records}

    levenshtein_distances = calculate_levenshtein_distances(sequences=seq_dict)

    return jsonify(levenshtein_distances)
