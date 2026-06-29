from biocentral_api import BiocentralAPI, CommonEmbedder

biocentral_api = BiocentralAPI(local_only=True).wait_until_healthy(max_wait_seconds=30)

# Project OHE encodings using PCA
embedder_name = CommonEmbedder.ONE_HOT_ENCODING
sequence_data = {"SeqP": "MMALSLALM",
                 "Seq2": "PRTEIN",
                 "Seq3": "PRT",
                 "Seq4": "SEQWENCE",
                 "Seq5": "MMPRTEINSEQWENCE",
                 }
projection_config = {"n_components": "2"}
result = biocentral_api.project(embedder_name=embedder_name,
                                method="pca",
                                sequence_data=sequence_data,
                                projection_config=projection_config).run()
print(result)
