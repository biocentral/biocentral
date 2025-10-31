from typing import List, Optional

from .._generated import ApiClient, TaxonomyRequest, ProteinsApi, TaxonomyItem, TaxonomyResponse


class ProteinsClient:
    def taxonomy(self, api_client: ApiClient, taxonomy_ids: List[int]) -> Optional[List[TaxonomyItem]]:
        api_instance = ProteinsApi(api_client)
        taxonomy_request = TaxonomyRequest(taxonomy_ids=taxonomy_ids)

        try:
            # Retrieve taxonomy data
            taxonomy_response = api_instance.taxonomy_api_v1_protein_service_taxonomy_post(taxonomy_request)
            return taxonomy_response.taxonomy
        except Exception as e:
            print("Exception when calling ProteinsApi->taxonomy_api_v1_protein_service_taxonomy_post: %s\n" % e)
            return None
