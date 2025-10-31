from biocentral_server_api import BiocentralServerClient

client = BiocentralServerClient()

result = client.taxonomy(taxonomy_ids=[9606, 11292])

print(result)
print(f"{result[1].taxonomy_id} ({result[1].name}) belongs to family {result[1].family}")