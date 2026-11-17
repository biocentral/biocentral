from biocentral import CommonEmbedder, SequenceData, Protocol


def test_train_and_inference_local_and_api(bc_local, bc_api):
    config = {
        "embedder_name": str(CommonEmbedder.ONE_HOT_ENCODING.value),
        "model_choice": "FNN",
        "protocol": str(Protocol.sequence_to_class.value),
        "num_epochs": 2,
    }

    training_data = [
        SequenceData(seq_id="Seq1", seq="MMALSLALM", label="Membrane", set="train"),
        SequenceData(seq_id="Seq2", seq="PRTEIN", label="Membrane", set="train"),
        SequenceData(seq_id="Seq3", seq="PRT", label="Soluble", set="train"),
        SequenceData(seq_id="Seq4", seq="SEQWENCE", label="Membrane", set="val"),
        SequenceData(seq_id="Seq5", seq="PRTE", label="Soluble", set="val"),
        SequenceData(seq_id="Seq6", seq="MMALSM", label="Membrane", set="test"),
        SequenceData(seq_id="Seq7", seq="PRSEQ", label="Soluble", set="test"),
    ]

    inference_data = {
        "Seq8": "PRTPRT",
        "Seq9": "SEQPRT",
    }

    # 1. Local train & inference
    local_train_result = bc_local.train(config=config, training_data=training_data)
    assert local_train_result.derived_values.model_hash is not None
    assert len(local_train_result.derived_values.model_hash) > 0

    local_inference_result = bc_local.inference(
        model_result=local_train_result, inference_data=inference_data
    )
    local_pred_keys = [p.seq_id for p in local_inference_result.predictions]
    assert set(local_pred_keys) == set(inference_data.keys())
    for pred in local_inference_result.predictions:
        assert pred.prediction is not None

    # 2. API train & inference
    api_train_result = bc_api.train(config=config, training_data=training_data)
    assert api_train_result.derived_values.model_hash is not None
    assert len(api_train_result.derived_values.model_hash) > 0

    api_inference_result = bc_api.inference(
        model_result=api_train_result, inference_data=inference_data
    )
    api_pred_keys = [p.seq_id for p in api_inference_result.predictions]
    assert set(api_pred_keys) == set(inference_data.keys())
    for pred in api_inference_result.predictions:
        assert pred.prediction is not None
