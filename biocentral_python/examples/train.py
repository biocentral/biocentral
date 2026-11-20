from biocentral import Biocentral, SequenceData, CommonEmbedder, Protocol

bc = Biocentral(mode="api")

config = {
    "embedder_name": CommonEmbedder.ProtT5,
    "model_choice": "FNN",
    "protocol": Protocol.sequence_to_class,
}

training_data = [
    SequenceData(
        seq_id="Seq1", seq="MMALSLALM", label="Membrane", set="train", mask=None
    ),
    SequenceData(seq_id="Seq2", seq="PRTEIN", label="Membrane", set="train", mask=None),
    SequenceData(seq_id="Seq3", seq="PRT", label="Soluble", set="train", mask=None),
    SequenceData(seq_id="Seq4", seq="SEQWENCE", label="Membrane", set="val", mask=None),
    SequenceData(seq_id="Seq5", seq="PRTE", label="Soluble", set="val", mask=None),
    SequenceData(seq_id="Seq6", seq="MMALSM", label="Membrane", set="test", mask=None),
    SequenceData(seq_id="Seq7", seq="PRSEQ", label="Soluble", set="test", mask=None),
]

training_result = bc.train(
    config=config, training_data=training_data
)
print(f"Training result dict: {training_result}")

model_hash = training_result.derived_values.model_hash

inference_data = {
    "Seq8": "PRTPRT",
    "Seq9": "SEQPRT",
}

inference_result = bc.inference(
    model_result=training_result, inference_data=inference_data
)
print(f"Inference result dict: {inference_result}")
