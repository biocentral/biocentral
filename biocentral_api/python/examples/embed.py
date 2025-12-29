from biocentral_api import BiocentralAPI, CommonEmbedder

biocentral_api = BiocentralAPI()

# Optional: Ensure service availability
biocentral_api = biocentral_api.wait_until_healthy(max_wait_seconds=30)

# OHE
embedder_name = CommonEmbedder.ONE_HOT_ENCODING
reduce = True
sequence_data = {"Seq1": "MMALSLALM",
                 "Seq2": "PRTEIN",
                 "Seq3": "PRT",
                 "Seq4": "SEQWENCE",
                 "Seq5": "MMPRTEINSEQWENCE",
                 }
result = biocentral_api.embed(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                            use_half_precision=False).run()
print(result)

# ProtT5
embedder_name = CommonEmbedder.ProtT5
result = biocentral_api.embed(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                            use_half_precision=False).run_with_progress()

print(result)
