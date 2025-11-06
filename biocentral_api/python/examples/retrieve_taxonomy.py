from biocentral_server_api import BiocentralAPI

biocentral_api = BiocentralAPI()

result = biocentral_api.taxonomy(taxonomy_ids=[9606, 11292])

print(result)
print(f"{result[1].taxonomy_id} ({result[1].name}) belongs to family {result[1].family}")