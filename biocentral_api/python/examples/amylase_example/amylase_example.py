from typing import List
from biocentral_api import BiocentralAPI, SequenceTrainingData, CommonEmbedder, BiocentralPredictionModel


def read_fasta(path: str) -> List[SequenceTrainingData]:
    result = []
    with open(path, "r") as f:
        lines = f.readlines()
        current_record = {}
        for line in lines:
            if line.startswith(">"):
                current_record = {
                    "id": line.strip().split(" ")[0][1:],
                    "label": line.strip().split("TARGET=")[1].split(" ")[0],
                    "set": line.strip().split("SET=")[1].split(" ")[0]
                }
            else:
                sequence = line.strip()
                result.append(SequenceTrainingData(seq_id=current_record["id"],
                                                   sequence=sequence,
                                                   label=current_record["label"],
                                                   set=current_record["set"],
                                                   mask=None))
                current_record = {}
    assert len(result) == 7848 / 2
    return result


def print_test_result(result: dict):
    embedder_name = result["config"]["embedder_name"]
    scc = result["test_results"]["test"]["bootstrapping"]["results"]["spearmans-corr-coeff"]
    scc_mean = round(scc["mean"], 3)
    scc_lower = round(scc["lower"], 3)
    scc_upper = round(scc["upper"], 3)
    print(f"SCC Result for {embedder_name}: {scc_mean} ({scc_lower} - {scc_upper})")
    return scc_mean, scc_lower, scc_upper


def main():
    # 1. Read data
    amylase_data: List[SequenceTrainingData] = read_fasta("amylase_pet.fasta")
    sequence_data = {data_point.seq_id: data_point.sequence for data_point in amylase_data}

    # 2. Connect to biocentral API
    biocentral_api = BiocentralAPI().wait_until_healthy()

    # 3. Embed
    embedder_name = CommonEmbedder.ProtT5
    embeddings = biocentral_api.embed(embedder_name=embedder_name,
                                      reduce=True,
                                      sequence_data=sequence_data).run_with_progress()

    # Save embeddings and inspect first embedding
    embeddings.save("amylase_embeddings.h5")
    print(f"First embedding: {embeddings.to_numpy()[0]}")

    # 4. Train biotrainer model with ProtT5 embeddings (embeddings are automatically re-used)
    config = {"protocol": "sequence_to_value",
              "model_choice": "FNN",
              "embedder_name": embedder_name
              }
    prott5_result = biocentral_api.train(config=config, training_data=amylase_data).run_with_progress()
    print_test_result(prott5_result)

    # 5. Train an one_hot_encoding model as comparison
    config = {"protocol": "sequence_to_value",
              "model_choice": "FNN",
              "embedder_name": CommonEmbedder.ONE_HOT_ENCODING
              }
    ohe_result = biocentral_api.train(config=config, training_data=amylase_data).run_with_progress()
    print_test_result(ohe_result)

    # 6. Create predictions
    prediction_models = [
        BiocentralPredictionModel.TMBED,
        BiocentralPredictionModel.PROTT5SECONDARYSTRUCTURE
    ]
    best_variant = max(amylase_data, key=lambda data_point: float(data_point.label))
    prediction_result = biocentral_api.predict(model_names=prediction_models,
                                               sequence_data={
                                                   best_variant.seq_id: best_variant.sequence}).run_with_progress()
    print(prediction_result)


if __name__ == "__main__":
    main()
