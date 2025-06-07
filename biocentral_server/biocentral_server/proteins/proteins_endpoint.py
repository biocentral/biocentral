import json

from flask import request, jsonify, Blueprint

from .taxonomy import Taxonomy

from ..utils import get_logger

logger = get_logger(__name__)

protein_service_route = Blueprint("protein_service", __name__)


# Endpoint to get taxonomy data (taxon name and family name from taxonomy id)
@protein_service_route.route('/protein_service/taxonomy', methods=['POST'])
def taxonomy():
    taxonomy_data = request.get_json()
    taxonomy_ids: list = json.loads(taxonomy_data.get('taxonomy'))

    taxonomy_map = {}
    taxonomy_object = Taxonomy()
    for taxonomy_id in taxonomy_ids:
        name = ""
        family = ""
        try:
            name = taxonomy_object.get_name_from_id(int(taxonomy_id))
            family = taxonomy_object.get_family_from_id(int(taxonomy_id))
        except Exception:
            import ncbi_refseq_accession_db
            import ncbi_refseq_accession_lengths
            import ncbi_refseq_accession_offsets
            from taxoniq import Taxon
            print(ncbi_refseq_accession_db.db)
            print(ncbi_refseq_accession_lengths.db)
            print(ncbi_refseq_accession_offsets.db)
            print(Taxon)
            logger.warning(f"Unknown taxonomy id: {taxonomy_id}")
        taxonomy_map[taxonomy_id] = {"name": name, "family": family}

    return jsonify({"taxonomy": taxonomy_map})
