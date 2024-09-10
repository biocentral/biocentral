from .proteins_endpoint import protein_service_route
from .taxoniq_patch import patch_taxoniq_if_bundled

patch_taxoniq_if_bundled()

__all__ = [
    'protein_service_route'
]