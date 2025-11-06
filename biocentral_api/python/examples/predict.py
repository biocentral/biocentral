from biocentral_api import BiocentralAPI

biocentral_api = BiocentralAPI()

model_names = ["TMbed"]
sequence_data = {"Seq1": "MMALSLALMM",
                 "Seq2": "PRTEINMMALM",
                 "Seq3": "PRTSSSLAMAM",
                 "Seq4": "SEQWENCEAWMMWW",
                 }
result = biocentral_api.predict(model_names=model_names, sequence_data=sequence_data).run()
print(result)
