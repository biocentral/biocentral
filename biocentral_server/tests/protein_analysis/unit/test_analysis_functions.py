import random
import unittest
from typing import Dict

from biocentral_server.protein_analysis.analysis_functions import calculate_levenshtein_distances, \
    _get_all_possible_sequence_pairs


class AnalysisFunctionsTests(unittest.TestCase):

    @staticmethod
    def _get_random_nt_sequences(n: int = 20) -> Dict[str, str]:
        assert (n >= 0)
        random.seed(42)
        seqs = sorted(["".join(random.choices("ATGC", k=random.randint(12, 16))) for _ in range(n)])
        return {f"seq{i}": seq for i, seq in enumerate(seqs)}

    def test_get_sequence_pairs(self):
        seqs1 = self._get_random_nt_sequences(n=20)
        pairs1 = _get_all_possible_sequence_pairs(seqs1)
        self.assertEqual(len(pairs1), 400, "Did not get expected amount of sequence pairs!")

        seqs2 = self._get_random_nt_sequences(n=3)
        pairs2 = _get_all_possible_sequence_pairs(seqs2)
        self.assertEqual(len(pairs2), 9, "Did not get expected amount of sequence pairs!")

        seqs3 = self._get_random_nt_sequences(n=1)
        pairs3 = _get_all_possible_sequence_pairs(seqs3)
        self.assertEqual(len(pairs3), 1, "Did not get expected amount of sequence pairs!")

        seqs4 = self._get_random_nt_sequences(n=0)
        pairs4 = _get_all_possible_sequence_pairs(seqs4)
        self.assertEqual(len(pairs4), 0, "Did not get expected amount of sequence pairs!")

    def test_calculate_levenshtein_distances(self):
        seqs = self._get_random_nt_sequences(n=20)
        sequence_ratios = calculate_levenshtein_distances(sequences=seqs)

        self.assertEqual(len(sequence_ratios), 20, "Did not get expected amount of ratios!")
        outer_keys = []
        for seq_out, result_dict in sequence_ratios.items():
            outer_keys.append(seq_out)
            inner_keys = []
            for seq_in, (distance, ratio) in result_dict.items():
                inner_keys.append(seq_in)
                self.assertGreaterEqual(distance, 0, "Distance not in expected range!")
                self.assertGreaterEqual(ratio, 0, "Ratio not in expected range!")
                self.assertLessEqual(ratio, 1, "Ratio not in expected range!")
            self.assertTrue(all([seq in inner_keys for seq in seqs.keys()]),
                            "Missing sequence key (inner) in ratio dict!")

        self.assertTrue(all([seq in outer_keys for seq in seqs.keys()]), "Missing sequence key (outer) "
                                                                         "in ratio dict!")


if __name__ == '__main__':
    unittest.main()
