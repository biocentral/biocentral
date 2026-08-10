import unittest

from biocentral_api import BiocentralAPI, CommonEmbedder, SequenceData, Protocol


class TestTrainAndInference(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from tests.integration.conftest import _make_api, _wait_or_skip
        cls.api = _wait_or_skip(_make_api())

    def test_train_then_infer(self):
        config = {
            "embedder_name": CommonEmbedder.ProtT5,
            "model_choice": "FNN",
            "protocol": Protocol.SEQUENCE_TO_CLASS,
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

        training_result = self.api.train(config=config, training_data=training_data).run_with_progress()
        model_hash = training_result.derived_values.model_hash
        self.assertTrue(len(model_hash) > 0, "Training did not return a model hash")

        inference_data = {
            "Seq8": "PRTPRT",
            "Seq9": "SEQPRT",
        }

        inference_result = self.api.inference(model_hash=model_hash, inference_data=inference_data).run_with_progress()
        prediction_keys = [pred.seq_id for pred in inference_result.predictions]
        self.assertEqual(set(prediction_keys), set(inference_data.keys()))
        for pred in inference_result.predictions:
            self.assertTrue(len(pred.seq_id) > 0)
            self.assertTrue(pred.prediction is not None)


if __name__ == '__main__':
    unittest.main()
