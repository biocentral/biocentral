import os
import pytest
import unittest

from biocentral_api import CommonEmbedder


class TestEmbeddings(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from tests.integration.conftest import _make_api, _wait_or_skip

        cls.api = _wait_or_skip(_make_api())

    @pytest.mark.skipif(os.getenv("CI") is not None,
                        reason="Large test that should only be executed on demand (not in CI)")
    def test_embed_plm(self):
        sequence_data = {
            "Seq1": "MMALSLALM",
            "Seq2": "PRTEIN",
            "Seq3": "PRT",
            "Seq4": "SEQWENCE",
            "Seq5": "MMPRTEINSEQWENCE",
        }

        res1 = self.api.embed(
            embedder_name=CommonEmbedder.ProtT5,
            reduce=True,
            sequence_data=sequence_data,
            use_half_precision=False,
        ).run_with_progress()
        res1 = res1.to_dict()

        self.assertEqual(set(res1.keys()), set(sequence_data.keys()))
        for v in res1.values():
            self.assertIsNotNone(v)

        # Test half precision
        res2 = self.api.embed(
            embedder_name=CommonEmbedder.ESM2_650M,
            reduce=True,
            sequence_data=sequence_data,
            use_half_precision=True,
        ).run_with_progress()
        res2 = res2.to_dict()

        self.assertEqual(set(res2.keys()), set(sequence_data.keys()))
        for v in res2.values():
            self.assertIsNotNone(v)

    def test_embed_one_hot(self):
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

    def test_project_pca_one_hot(self):
        embedder_name = CommonEmbedder.ONE_HOT_ENCODING
        sequence_data = {
            "SeqP": "MMALSLALM",
            "Seq2": "PRTEIN",
            "Seq3": "PRT",
            "Seq4": "SEQWENCE",
            "Seq5": "MMPRTEINSEQWENCE",
        }
        projection_config = {"n_components": "2"}

        result = self.api.project(
            embedder_name=embedder_name,
            method="pca",
            sequence_data=sequence_data,
            projection_config=projection_config,
        ).run()
        self.assertIsNotNone(result)


if __name__ == "__main__":
    unittest.main()
