from biocentral import Biocentral, CommonEmbedder

bc = Biocentral(mode="local")

# OHE
embedder_name = CommonEmbedder.ONE_HOT_ENCODING
reduce = True
sequence_data = {
    "Seq1": "MMALSLALM",
    "Seq2": "PRTEIN",
    "Seq3": "PRT",
    "Seq4": "SEQWENCE",
    "Seq5": "MMPRTEINSEQWENCE",
}
result = bc.embed(
    embedder_name=embedder_name,
    reduce=reduce,
    sequence_data=sequence_data,
    use_half_precision=False,
)
print(result.to_dict())

# ProtT5
embedder_name = CommonEmbedder.ProtT5
result = bc.embed(
    embedder_name=embedder_name,
    reduce=reduce,
    sequence_data=sequence_data,
    use_half_precision=False,
)

print(result["Seq1"])
result.save("local_path.h5")
print(result.to_dict())
