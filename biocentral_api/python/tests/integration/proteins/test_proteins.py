import unittest

from utils import create_random_sequence


class TestProteins(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from tests.integration.conftest import _make_api, _wait_or_skip

        cls.api = _wait_or_skip(_make_api())

    def test_retrieve_taxonomy(self):
        result = self.api.taxonomy(taxonomy_ids=[9606, 11292])
        self.assertIsNotNone(result)
        self.assertGreaterEqual(len(result), 2)
        self.assertTrue(hasattr(result[1], "taxonomy_id"))
        self.assertTrue(hasattr(result[1], "name"))
        self.assertTrue(hasattr(result[1], "family"))

    def test_clustering(self):
        sequence_data = {
            "Seq1": "MMALSLALMP",
            "Seq2": "MMALSLALMA",
            "Seq3": "MMALSLALMX",
        }
        result = self.api.cluster(sequence_data, sequence_identity_threshold=0.5).run()
        self.assertIsNotNone(result)
        all_ids = set(result.keys())
        for cl_ids in result.values():
            all_ids.update(set(cl_ids))
        self.assertEqual(len(sequence_data), len(all_ids))

    def test_perplexity(self):
        sequence_data = {
            "Seq1": "MMALSLALMP",
            "Seq2": "MMALSLALMA",
            "Seq3": create_random_sequence(length=10)
        }
        result = self.api.perplexity(sequence_data, plm_name="facebook/esm2_t6_8M_UR50D").run()
        self.assertIsNotNone(result)
        self.assertIsNotNone(result.method)
        self.assertIn("Seq1", result.seq2perplexity)
        self.assertIn("Seq2", result.seq2perplexity)
        self.assertIsInstance(result.seq2perplexity["Seq1"], (float, int))
        self.assertIsInstance(result.seq2perplexity["Seq2"], (float, int))

    def test_perplexity_empty_sequences_rejected(self):
        with self.assertRaises(Exception):
            self.api.perplexity({}, plm_name="facebook/esm2_t6_8M_UR50D")

    def test_perplexity_duplicate_sequences_rejected(self):
        sequence_data = {
            "Seq1": "MMALSLALMP",
            "Seq2": "MMALSLALMP",
        }
        with self.assertRaises(Exception):
            self.api.perplexity(sequence_data, plm_name="facebook/esm2_t6_8M_UR50D")

    def test_perplexity_invalid_plm_name_rejected(self):
        sequence_data = {
            "Seq1": "MMALSLALMP",
            "Seq2": "MMALSLALMA",
        }
        with self.assertRaises(Exception):
            self.api.perplexity(sequence_data, plm_name="xysdw").run()

    def test_perplexity_empty_plm_name_rejected(self):
        sequence_data = {
            "Seq1": "MMALSLALMP",
            "Seq2": "MMALSLALMA",
        }
        with self.assertRaises(Exception):
            self.api.perplexity(sequence_data, plm_name="").run()


if __name__ == "__main__":
    unittest.main()
