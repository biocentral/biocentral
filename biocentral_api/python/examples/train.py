from biocentral_api import BiocentralAPI, SequenceData, CommonEmbedder, Protocol

biocentral_api = BiocentralAPI().wait_until_healthy(max_wait_seconds=30)

# OHE
config = {"embedder_name": CommonEmbedder.ProtT5,
          "model_choice": "FNN",
          "protocol": Protocol.SEQUENCE_TO_CLASS
          }

training_data = [
    SequenceData(seq_id="Seq1", seq="MMALSLALM", label="Membrane", set="train", mask=None),
    SequenceData(seq_id="Seq2", seq="PRTEIN", label="Membrane", set="train", mask=None),
    SequenceData(seq_id="Seq3", seq="PRT", label="Soluble", set="train", mask=None),
    SequenceData(seq_id="Seq4", seq="SEQWENCE", label="Membrane", set="val", mask=None),
    SequenceData(seq_id="Seq5", seq="PRTE", label="Soluble", set="val", mask=None),
    SequenceData(seq_id="Seq6", seq="MMALSM", label="Membrane", set="test", mask=None),
    SequenceData(seq_id="Seq7", seq="PRSEQ", label="Soluble", set="test", mask=None),
]

training_result = biocentral_api.train(config=config, training_data=training_data).run_with_progress()
print(f"Training result dict: {training_result}")

model_hash = training_result.derived_values.model_hash

inference_data = {
    "Seq8": "PRTPRT",
    "Seq9": "SEQPRT",
}

inference_result = biocentral_api.inference(model_hash=model_hash, inference_data=inference_data).run_with_progress()
print(f"Inference result dict: {inference_result}")
