from biocentral_api import BiocentralAPI

biocentral_api = BiocentralAPI()

# OHE
embedder_name = "one_hot_encoding"
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
embedder_name = "Rostlab/prot_t5_xl_uniref50"
result = biocentral_api.embed(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                            use_half_precision=False).run_with_progress()

print(result)
