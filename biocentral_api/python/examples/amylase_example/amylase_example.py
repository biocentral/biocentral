from typing import List
from biocentral_api import (
    BiocentralAPI,
    SequenceData,
    CommonEmbedder,
    BiocentralPredictionModel,
    batched,
    BiotrainerModelResult,
)
from biotrainer_core.input_files import read_FASTA


def print_test_result(result: BiotrainerModelResult):
    embedder_name = result.config["embedder_name"]
    scc = [
        metric
        for metric in result.test_results["test"].bootstrapped_metrics or []
        if metric.name == "spearmans-corr-coeff"
    ][0]
    scc_mean = round(scc.mean, 3)
    scc_lower = round(scc.lower, 3)
    scc_upper = round(scc.upper, 3)
    print(f"SCC Result for {embedder_name}: {scc_mean} ({scc_lower} - {scc_upper})")
    return scc_mean, scc_lower, scc_upper


def main():
    # 1. Read data
    amylase_data: List[SequenceData] = read_FASTA("amylase_pet.fasta")

    # 2. Connect to biocentral API
    biocentral_api = BiocentralAPI().wait_until_healthy()

    # 3. Embed
    embedder_name = CommonEmbedder.ProtT5

    # Our number of sequences exceeds the API limit, so we need to batch it
    current_embeddings_result = None
    batch_idx = 1
    for batch in batched(amylase_data, 1000):
        sequence_data = {data_point.seq_id: data_point.seq for data_point in batch}

        embeddings = biocentral_api.embed(
            embedder_name=embedder_name, reduce=True, sequence_data=sequence_data
        ).run_with_progress()
        if current_embeddings_result is None:
            current_embeddings_result = embeddings
        else:
            current_embeddings_result = current_embeddings_result.merge(embeddings)

        print(f"Batch {batch_idx} done")
        batch_idx += 1

    embeddings = current_embeddings_result
    # Save embeddings and inspect first embedding
    embeddings.save("amylase_embeddings.h5")
    print(f"First embedding: {embeddings.to_numpy()[0]}")
    print(f"Number of embeddings: {len(embeddings.to_list())}")

    # 4. Train biotrainer model with ProtT5 embeddings (embeddings are automatically re-used)
    config = {
        "protocol": "sequence_to_value",
        "model_choice": "FNN",
        "embedder_name": embedder_name,
    }
    prott5_result = biocentral_api.train(
        config=config, training_data=amylase_data
    ).run_with_progress()
    print_test_result(prott5_result)

    # 5. Train an one_hot_encoding model as comparison
    config = {
        "protocol": "sequence_to_value",
        "model_choice": "FNN",
        "embedder_name": CommonEmbedder.ONE_HOT_ENCODING,
    }
    ohe_result = biocentral_api.train(
        config=config, training_data=amylase_data
    ).run_with_progress()
    print_test_result(ohe_result)

    # 6. Create predictions
    prediction_models = [
        BiocentralPredictionModel.TMBED,
        BiocentralPredictionModel.PROTT5SECONDARYSTRUCTURE,
    ]
    best_variant = max(amylase_data, key=lambda data_point: float(data_point.label))
    prediction_result = biocentral_api.predict(
        model_names=prediction_models,
        sequence_data={best_variant.seq_id: best_variant.seq},
    ).run_with_progress()
    print(prediction_result)


if __name__ == "__main__":
    main()
