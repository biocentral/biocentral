from biotrainer_core.input_files import read_FASTA
from biocentral_api import BiocentralAPI, CommonEmbedder

biocentral_api = BiocentralAPI(local_only=True).wait_until_healthy(max_wait_seconds=30)

# Project OHE encodings using PCA
embedder_name = CommonEmbedder.ONE_HOT_ENCODING
sequence_data = read_FASTA("scl_max2000.fasta")[:500]
projection_config = {"n_components": "2"}
result = biocentral_api.project(
    embedder_name=embedder_name,
    method="pca",
    sequence_data=sequence_data,
    projection_config=projection_config,
).run()
print(result)
with open("projection_result_scl.json", "w") as projection_file:
    projection_file.write(result.model_dump_json())

# Map Seq Data to coordinates
projections_data = result.projections_data
identifier = projections_data.identifier
coord_map = {
    seq_id: (projections_data.x[idx], projections_data.y[idx], projections_data.z[idx])
    for idx, seq_id in enumerate(identifier)
}
print(coord_map)
