from biocentral_server_api import BiocentralServerClient

client = BiocentralServerClient()

model_names = ["TMbed"]
sequence_data = {"Seq1": "MMALSLALMM",
                 "Seq2": "PRTEINMMALM",
                 "Seq3": "PRTSSSLAMAM",
                 "Seq4": "SEQWENCEAWMMWW",
                 }
result = client.predict(model_names=model_names, sequence_data=sequence_data).run()
print(result)
