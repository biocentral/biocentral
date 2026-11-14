from biocentral import Biocentral, CommonEmbedder

bc = Biocentral(mode="api")

# Project OHE encodings using PCA
embedder_name = CommonEmbedder.ONE_HOT_ENCODING
sequence_data = {
    "Seq1": "MMALSLALM",
    "Seq2": "PRTEIN",
    "Seq3": "PRT",
    "Seq4": "SEQWENCE",
    "Seq5": "MMPRTEINSEQWENCE",
}
projection_config = {"n_components": "2"}
result = bc.project(
    embedder_name=embedder_name,
    method="pca",
    sequence_data=sequence_data,
    projection_config=projection_config,
)
print(result)
with open("projection_result.json", "w") as projection_file:
    projection_file.write(result.model_dump_json())

# Map Seq Data to coordinates
projections_data = result.projections_data
identifier = projections_data.identifier
coord_map = {
    seq_id: (projections_data.x[idx], projections_data.y[idx], projections_data.z[idx])
    for idx, seq_id in enumerate(identifier)
}
print(coord_map)
