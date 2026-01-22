import unittest

from biocentral_api import (
    BiocentralAPI,
    BiocentralPredictionModel,
    CommonEmbedder,
    SequenceTrainingData,
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningOptimizationMode,
    ActiveLearningModelType,
    ActiveLearningSimulationConfig,
    ActiveLearningConvergenceConfig,
    Protocol,
)


def _make_api(local_only_default: bool = True) -> BiocentralAPI:
    """Create API client for local (dev) or production based on env."""
    local_only = False # local_only_default
    fixed_server_url = None
    return BiocentralAPI(fixed_server_url=fixed_server_url, local_only=local_only)


def _wait_or_skip(api: BiocentralAPI, timeout: int = 60) -> BiocentralAPI:
    try:
        return api.wait_until_healthy(max_wait_seconds=timeout)
    except Exception as e:
        raise unittest.SkipTest(f"Biocentral service not available for integration tests: {e}")


class TestEmbeddings(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = _wait_or_skip(_make_api(local_only_default=True))

    def test_embed_one_hot_and_prott5(self):
        sequence_data = {
            "Seq1": "MMALSLALM",
            "Seq2": "PRTEIN",
            "Seq3": "PRT",
            "Seq4": "SEQWENCE",
            "Seq5": "MMPRTEINSEQWENCE",
        }

        res1 = self.api.embed(
            embedder_name=CommonEmbedder.ONE_HOT_ENCODING,
            reduce=True,
            sequence_data=sequence_data,
            use_half_precision=False,
        ).run()

        self.assertEqual(set(res1.keys()), set(sequence_data.keys()))
        for v in res1.values():
            self.assertIsNotNone(v)

        res2 = self.api.embed(
            embedder_name=CommonEmbedder.ProtT5,
            reduce=True,
            sequence_data=sequence_data,
            use_half_precision=False,
        ).run_with_progress()

        self.assertEqual(set(res2.keys()), set(sequence_data.keys()))
        for v in res2.values():
            self.assertIsNotNone(v)


class TestPredict(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = _wait_or_skip(_make_api(local_only_default=True))

    def test_predict_tmbed(self):
        model_names = [BiocentralPredictionModel.TMBED]
        sequence_data = {
            "Seq1": "MMALSLALMM",
            "Seq2": "PRTEINMMALM",
            "Seq3": "PRTSSSLAMAM",
            "Seq4": "SEQWENCEAWMMWW",
        }

        result = self.api.predict(model_names=model_names, sequence_data=sequence_data).run()

        self.assertEqual(set(result.keys()), set(sequence_data.keys()))
        for pred in result.values():
            self.assertIsInstance(pred, list)
            self.assertGreaterEqual(len(pred), 1)


class TestTrainAndInference(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = _wait_or_skip(_make_api(local_only_default=True))

    def test_train_then_infer(self):
        config = {
            "embedder_name": CommonEmbedder.ProtT5,
            "model_choice": "FNN",
            "protocol": Protocol.SEQUENCE_TO_CLASS,
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

        training_result = self.api.train(config=config, training_data=training_data).run_with_progress()
        self.assertIsInstance(training_result, dict)
        model_hash = training_result.get("derived_values", {}).get("model_hash")
        self.assertTrue(model_hash, "Training did not return a model hash")

        inference_data = {
            "Seq8": "PRTPRT",
            "Seq9": "SEQPRT",
        }

        inference_result = self.api.inference(model_hash=model_hash, inference_data=inference_data).run_with_progress()
        self.assertEqual(set(inference_result.keys()), set(inference_data.keys()))
        for v in inference_result.values():
            self.assertIsInstance(v, list)
            self.assertGreaterEqual(len(v), 1)


class TestTaxonomy(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Active learning currently requires local dev features in many setups
        cls.api = _wait_or_skip(_make_api(local_only_default=True))

    def test_retrieve_taxonomy(self):
        result = self.api.taxonomy(taxonomy_ids=[9606, 11292])
        self.assertIsNotNone(result)
        self.assertGreaterEqual(len(result), 2)
        self.assertTrue(hasattr(result[1], "taxonomy_id"))
        self.assertTrue(hasattr(result[1], "name"))
        self.assertTrue(hasattr(result[1], "family"))


class TestActiveLearning(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Active learning currently requires local dev features in many setups
        cls.api = _wait_or_skip(_make_api(local_only_default=True))

    def test_active_learning_iteration(self):
        campaign_config = ActiveLearningCampaignConfig(
            name="Example_Campaign",
            model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
            embedder_name="one_hot_encoding",
            optimization_mode=ActiveLearningOptimizationMode.VALUE,
            target_value=10.0,
        )

        iteration_data = [
            SequenceTrainingData(seq_id="Seq1", sequence="MMALSLALM", label="5.4", set="train", mask=None),
            SequenceTrainingData(seq_id="Seq2", sequence="PRTEIN", label="1.1", set="train", mask=None),
            SequenceTrainingData(seq_id="Seq3", sequence="PRT", label="2.2", set="train", mask=None),
            SequenceTrainingData(seq_id="Seq4", sequence="SEQWENCE", set="pred", mask=None),
            SequenceTrainingData(seq_id="Seq5", sequence="PRTE", set="pred", mask=None),
            SequenceTrainingData(seq_id="Seq6", sequence="MMALSM", set="pred", mask=None),
            SequenceTrainingData(seq_id="Seq7", sequence="PRSEQ", set="pred", mask=None),
        ]

        iteration_config = ActiveLearningIterationConfig(
            iteration_data=iteration_data,
            n_suggestions=1,
            coefficient=0.8,
            iteration=1,
        )

        iteration_result = self.api.al_iteration(campaign_config, iteration_config).run_with_progress()
        self.assertTrue(hasattr(iteration_result, "results"))
        self.assertTrue(hasattr(iteration_result, "suggestions"))
        self.assertIsInstance(iteration_result.suggestions, list)

    def test_active_learning_simulation(self):
        campaign_config = ActiveLearningCampaignConfig(
            name="Example_Simulation_Campaign",
            model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
            embedder_name="one_hot_encoding",
            optimization_mode=ActiveLearningOptimizationMode.VALUE,
            target_value=10.0,
        )

        simulation_data = [
            SequenceTrainingData(seq_id="Seq1", sequence="MMALSLALM", label="5.4", set="train", mask=None),
            SequenceTrainingData(seq_id="Seq2", sequence="PRTEIN", label="1.1", set="train", mask=None),
            SequenceTrainingData(seq_id="Seq3", sequence="PRT", label="2.2", set="train", mask=None),
            SequenceTrainingData(seq_id="Seq4", sequence="SEQWENCE", label="3.3", set="pred", mask=None),
            SequenceTrainingData(seq_id="Seq5", sequence="PRTE", label="9.9", set="pred", mask=None),
            SequenceTrainingData(seq_id="Seq6", sequence="MMALSM", label="4.0", set="pred", mask=None),
            SequenceTrainingData(seq_id="Seq7", sequence="PRSEQ", label="0.5", set="pred", mask=None),
        ]

        simulation_config = ActiveLearningSimulationConfig(
            simulation_data=simulation_data,
            n_start=1,
            n_suggestions_per_iteration=1,
            convergence_config=ActiveLearningConvergenceConfig(
                max_labels_budget=3,
                target_successes=2,
                max_consecutive_failures=2,
            ),
        )

        simulation_results = self.api.al_simulation(campaign_config, simulation_config).run_with_progress()
        self.assertTrue(hasattr(simulation_results, "iteration_results"))
        self.assertTrue(hasattr(simulation_results, "summary"))


if __name__ == '__main__':
    unittest.main()