import os
import tarfile
import tempfile
import unittest
import numpy as np
import pytest

from biocentral_api import BiocentralPredictionModel


class TestPredict(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from tests.integration.conftest import _make_api, _wait_or_skip

        cls.api = _wait_or_skip(_make_api())

    @pytest.mark.skipif(os.getenv("CI") is not None,
                        reason="Large test that should only be executed on demand (not in CI)")
    def test_predict_all(self):
        # Predict for all but VespaG (requires ESM-2 3B Model)
        model_names = [
            m
            for m in BiocentralPredictionModel
            if m != BiocentralPredictionModel.VESPAG
        ]
        sequence_data = {
            "Seq1": "MMAPLSLALMM",
            "Seq2": "PRTPEINMMALM",
            "Seq3": "PRTPSSSLAMAM",
            "Seq4": "SEQPWENCEAWMMWW",
        }

        result = self.api.predict(
            model_names=model_names, sequence_data=sequence_data
        ).run()

        print(result)

        self.assertEqual(set(result.keys()), set(sequence_data.keys()))
        for pred in result.values():
            self.assertIsInstance(pred, list)
            self.assertGreaterEqual(len(pred), 1)
    
    @pytest.mark.skip(reason="Large test that should only be executed on demand")
    def test_udonpred_correctness(self):
        model_names = [BiocentralPredictionModel.UDONPRED]

        sequence_data = {}
        with open(
            "tests/integration/predict/udonpred_trizod/phot_trizod.fasta", "r"
        ) as phot_trizod_file:
            for line in phot_trizod_file.readlines():
                if line.startswith(">"):
                    seq_id = line.strip().replace(">", "")
                    sequence_data[seq_id] = ""
                else:
                    sequence_data[seq_id] += line.strip()

        print(f"Read {len(sequence_data)} sequences from phot_trizod.fasta")

        result = self.api.predict(
            model_names=model_names, sequence_data=sequence_data
        ).run()

        self.assertEqual(set(result.keys()), set(sequence_data.keys()))
        for pred in result.values():
            self.assertIsInstance(pred, list)
            self.assertGreaterEqual(len(pred), 1)

        # Extract tar.gz to temporary directory and process all .caid files
        with tempfile.TemporaryDirectory() as temp_dir:
            # Extract archive
            archive_path = (
                "tests/integration/predict/udonpred_trizod/phot_trizod.tar.gz"
            )
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
                    self.assertIn(
                        idx,
                        sequence_data,
                        f"ID '{idx}' from .caid file not found in sequence_data",
                    )

                    # Check that this ID exists in prediction results
                    self.assertIn(
                        idx, result, f"ID '{idx}' not found in prediction results"
                    )

                    expected_result = []
                    seq = ""
                    for line in lines[1:]:
                        vals = line.split("\t")
                        aa = vals[1]
                        aa_res = vals[2]
                        seq += aa
                        expected_result.append(float(aa_res))

                    # Verify exact sequence match
                    self.assertEqual(
                        sequence_data[idx],
                        seq,
                        f"Sequence mismatch for ID '{idx}': sequence_data and .caid file don't match",
                    )

                    # Compare predictions with expected results
                    predicted_values = list(
                        map(float, result[idx][0].value.replace("'", "").split(","))
                    )
                    predicted_values = list(
                        map(lambda v: round(v, 3), predicted_values)
                    )
                    expected_result = list(map(lambda v: round(v, 3), expected_result))
                    self.assertTrue(len(predicted_values) == len(expected_result))
                    self.assertTrue(
                        np.allclose(predicted_values, expected_result, atol=1e-3),
                        f"Prediction mismatch for ID '{idx}':\n"
                        f"{predicted_values}\n"
                        f"{expected_result}",
                    )


if __name__ == "__main__":
    unittest.main()
