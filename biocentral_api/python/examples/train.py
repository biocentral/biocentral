from biocentral_api import BiocentralAPI, SequenceTrainingData, CommonEmbedder

biocentral_api = BiocentralAPI().wait_until_healthy(max_wait_seconds=30)

# OHE
config = {"embedder_name": CommonEmbedder.ProtT5,
          "model_choice": "FNN",
          "protocol": "sequence_to_class"
          }

training_data = [
    SequenceTrainingData(seq_id="Seq1", sequence="MMALSLALM", label="Membrane", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq2", sequence="PRTEIN", label="Membrane", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq3", sequence="PRT", label="Soluble", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq4", sequence="SEQWENCE", label="Membrane", set="val", mask=None),
    SequenceTrainingData(seq_id="Seq5", sequence="PRTE", label="Soluble", set="val", mask=None),
    SequenceTrainingData(seq_id="Seq6", sequence="MMALSM", label="Membrane", set="test", mask=None),
    SequenceTrainingData(seq_id="Seq7", sequence="PRSEQ", label="Soluble", set="test", mask=None),
]

training_result = biocentral_api.train(config=config, training_data=training_data).run_with_progress()
print(f"Training result dict: {training_result}")

model_hash = training_result['derived_values']['model_hash']

inference_data = {
    "Seq8": "PRTPRT",
    "Seq9": "SEQPRT",
}

inference_result = biocentral_api.inference(model_hash=model_hash, inference_data=inference_data).run_with_progress()
print(f"Inference result dict: {inference_result}")
