from biocentral_api import BiocentralAPI, BiocentralPredictionModel

biocentral_api = BiocentralAPI()
biocentral_api.wait_until_healthy(max_wait_seconds=10)

model_names = [BiocentralPredictionModel.TMBED]
sequence_data = {"Seq1": "MMALSLALMM",
                 "Seq2": "PRTEINMMALM",
                 "Seq3": "PRTSSSLAMAM",
                 "Seq4": "SEQWENCEAWMMWW",
                 }
result = biocentral_api.predict(model_names=model_names, sequence_data=sequence_data).run()
print(result)
