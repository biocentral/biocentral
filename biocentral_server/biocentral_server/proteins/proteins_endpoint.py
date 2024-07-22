import json
import logging

from flask import request, jsonify, Blueprint
from hvi_toolkit.taxonomy import Taxonomy

logger = logging.getLogger(__name__)

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
            logger.warning(f"Unknown taxonomy id: {taxonomy_id}")
        taxonomy_map[taxonomy_id] = {"name": name, "family": family}

    return jsonify({"taxonomy": taxonomy_map})
