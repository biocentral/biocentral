import os
import tarfile
import tempfile
import unittest
import numpy as np
import pytest

from biocentral_api import (
    BiocentralAPI,
    BiocentralPredictionModel,
    CommonEmbedder,
    SequenceData,
    ActiveLearningCampaignConfig,
    ActiveLearningIterationConfig,
    ActiveLearningOptimizationMode,
    ActiveLearningModelType,
    ActiveLearningSimulationConfig,
    ActiveLearningConvergenceConfig,
    Protocol,
)

LOCAL = False


def _make_api() -> BiocentralAPI:
    """Create API client for local (dev) or production based on env."""
    fixed_server_url = None
    return BiocentralAPI(fixed_server_url=fixed_server_url, local_only=LOCAL)


def _wait_or_skip(api: BiocentralAPI, timeout: int = 60) -> BiocentralAPI:
    try:
        return api.wait_until_healthy(max_wait_seconds=timeout)
    except Exception as e:
        raise unittest.SkipTest(f"Biocentral service not available for integration tests: {e}")


class TestEmbeddings(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = _wait_or_skip(_make_api())

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
        res1 = res1.to_dict()

        self.assertEqual(set(res1.keys()), set(sequence_data.keys()))
        for v in res1.values():
            self.assertIsNotNone(v)

        res2 = self.api.embed(
            embedder_name=CommonEmbedder.ProtT5,
            reduce=True,
            sequence_data=sequence_data,
            use_half_precision=False,
        ).run_with_progress()
        res2 = res2.to_dict()

        self.assertEqual(set(res2.keys()), set(sequence_data.keys()))
        for v in res2.values():
            self.assertIsNotNone(v)

        # Test half precision
        res3 = self.api.embed(
            embedder_name=CommonEmbedder.ESM2_650M,
            reduce=True,
            sequence_data=sequence_data,
            use_half_precision=True,
        ).run_with_progress()
        res3 = res3.to_dict()

        self.assertEqual(set(res3.keys()), set(sequence_data.keys()))
        for v in res3.values():
            self.assertIsNotNone(v)


class TestPredict(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = _wait_or_skip(_make_api())

    def test_predict_all(self):
        # Predict for all but VespaG (requires ESM-2 3B Model)
        model_names = [m for m in BiocentralPredictionModel if m != BiocentralPredictionModel.VESPAG]
        sequence_data = {
            "Seq1": "MMAPLSLALMM",
            "Seq2": "PRTPEINMMALM",
            "Seq3": "PRTPSSSLAMAM",
            "Seq4": "SEQPWENCEAWMMWW",
        }

        result = self.api.predict(model_names=model_names, sequence_data=sequence_data).run()

        print(result)

        self.assertEqual(set(result.keys()), set(sequence_data.keys()))
        for pred in result.values():
            self.assertIsInstance(pred, list)
            self.assertGreaterEqual(len(pred), 1)

    @pytest.mark.skip(reason="Large test that should only be executed on demand")
    def test_udonpred_correctness(self):
        model_names = [BiocentralPredictionModel.UDONPRED]

        sequence_data = {}
        with open("tests/udonpred_trizod/phot_trizod.fasta", "r") as phot_trizod_file:
            for line in phot_trizod_file.readlines():
                if line.startswith(">"):
                    seq_id = line.strip().replace(">", "")
                    sequence_data[seq_id] = ""
                else:
                    sequence_data[seq_id] += line.strip()

        print(f"Read {len(sequence_data)} sequences from phot_trizod.fasta")

        result = self.api.predict(model_names=model_names, sequence_data=sequence_data).run()

        self.assertEqual(set(result.keys()), set(sequence_data.keys()))
        for pred in result.values():
            self.assertIsInstance(pred, list)
            self.assertGreaterEqual(len(pred), 1)

        # Extract tar.gz to temporary directory and process all .caid files
        with tempfile.TemporaryDirectory() as temp_dir:
            # Extract archive
            archive_path = "tests/udonpred_trizod/phot_trizod.tar.gz"
            with tarfile.open(archive_path, "r:gz") as tar:
                tar.extractall(temp_dir)

            # Find all .caid files in extracted content
            caid_files = []
            for root, dirs, files in os.walk(temp_dir):
                for file in files:
                    if file.endswith(".caid"):
                        caid_files.append(os.path.join(root, file))

            self.assertGreater(len(caid_files), 0, "No .caid files found in archive")

            # Process each .caid file
            for caid_file_path in caid_files:
                with open(caid_file_path, "r") as caid_file:
                    lines = caid_file.readlines()
                    idx = lines[0].strip().replace(">", "")

                    # Check that this ID exists in sequence_data
                    self.assertIn(idx, sequence_data, f"ID '{idx}' from .caid file not found in sequence_data")

                    # Check that this ID exists in prediction results
                    self.assertIn(idx, result, f"ID '{idx}' not found in prediction results")

                    expected_result = []
                    seq = ""
                    for line in lines[1:]:
                        vals = line.split("\t")
                        aa = vals[1]
                        aa_res = vals[2]
                        seq += aa
                        expected_result.append(float(aa_res))

                    # Verify exact sequence match
                    self.assertEqual(sequence_data[idx], seq,
                                     f"Sequence mismatch for ID '{idx}': sequence_data and .caid file don't match")

                    # Compare predictions with expected results
                    predicted_values = list(map(float, result[idx][0].value.replace("'", "").split(",")))
                    predicted_values = list(map(lambda v: round(v, 3), predicted_values))
                    expected_result = list(map(lambda v: round(v, 3), expected_result))
                    self.assertTrue(len(predicted_values) == len(expected_result))
                    self.assertTrue(np.allclose(predicted_values, expected_result, atol=1e-3),
                                    f"Prediction mismatch for ID '{idx}':\n"
                                    f"{predicted_values}\n"
                                    f"{expected_result}")


class TestTrainAndInference(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
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


class TestTaxonomy(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Active learning currently requires local dev features in many setups
        cls.api = _wait_or_skip(_make_api())

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
        cls.api = _wait_or_skip(_make_api())

    def test_active_learning_iteration(self):
        campaign_config = ActiveLearningCampaignConfig(
            name="Example_Campaign",
            model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
            embedder_name="one_hot_encoding",
            optimization_mode=ActiveLearningOptimizationMode.VALUE,
            target_value=10.0,
        )

        iteration_data = [
            SequenceData(seq_id="Seq1", seq="MMALSLALM", label="5.4", set="train", mask=None),
            SequenceData(seq_id="Seq2", seq="PRTEIN", label="1.1", set="train", mask=None),
            SequenceData(seq_id="Seq3", seq="PRT", label="2.2", set="train", mask=None),
            SequenceData(seq_id="Seq4", seq="SEQWENCE", set="pred", mask=None),
            SequenceData(seq_id="Seq5", seq="PRTE", set="pred", mask=None),
            SequenceData(seq_id="Seq6", seq="MMALSM", set="pred", mask=None),
            SequenceData(seq_id="Seq7", seq="PRSEQ", set="pred", mask=None),
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
            SequenceData(seq_id="Seq1", seq="MMALSLALM", label="5.4", set="train", mask=None),
            SequenceData(seq_id="Seq2", seq="PRTEIN", label="1.1", set="train", mask=None),
            SequenceData(seq_id="Seq3", seq="PRT", label="2.2", set="train", mask=None),
            SequenceData(seq_id="Seq4", seq="SEQWENCE", label="3.3", set="pred", mask=None),
            SequenceData(seq_id="Seq5", seq="PRTE", label="9.9", set="pred", mask=None),
            SequenceData(seq_id="Seq6", seq="MMALSM", label="4.0", set="pred", mask=None),
            SequenceData(seq_id="Seq7", seq="PRSEQ", label="0.5", set="pred", mask=None),
        ]

        simulation_config = ActiveLearningSimulationConfig(
            simulation_data=simulation_data,
            n_start=2,
            n_suggestions_per_iteration=1,
            convergence_config=ActiveLearningConvergenceConfig(
                max_labels_budget=3,
                target_successes=2,
                max_consecutive_failures=2,
            ),
        )

        simulation_results = self.api.al_simulation(campaign_config, simulation_config).run_with_progress()
        self.assertTrue(hasattr(simulation_results, "iteration_results"))


if __name__ == '__main__':
    unittest.main()
