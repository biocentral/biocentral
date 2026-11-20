from biocentral import Biocentral, BiocentralPredictionModel

bc = Biocentral(mode="api")

model_names = [BiocentralPredictionModel.TMBED]
sequence_data = {
    "Seq1": "MMALSLALMM",
    "Seq2": "PRTEINMMALM",
    "Seq3": "PRTSSSLAMAM",
    "Seq4": "SEQWENCEAWMMWW",
}
result = bc.predict(
    model_names=model_names, sequence_data=sequence_data
)
print(result)
