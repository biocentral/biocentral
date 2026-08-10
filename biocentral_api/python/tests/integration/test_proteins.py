import unittest

from biocentral_api import BiocentralAPI


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


if __name__ == '__main__':
    unittest.main()
