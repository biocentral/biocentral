"""Contract tests for protein engineering mutation identifiers."""

import unittest

from biocentral_server.active_learning.pipelines.protein_engineering.steps.embedding_step import (
    mutation_descriptor,
)


class TestMutationDescriptor(unittest.TestCase):
    def test_first_and_last_positions_are_one_based(self):
        self.assertEqual(mutation_descriptor("ACDE", "VCDE"), "A1V")
        self.assertEqual(mutation_descriptor("ACDE", "ACDA"), "E4A")

    def test_multiple_substitutions_are_colon_separated(self):
        self.assertEqual(mutation_descriptor("ACDE", "VCDA"), "A1V:E4A")

    def test_descriptor_reconstructs_variant_from_round_parent(self):
        # The parent may itself already differ from the campaign wildtype.
        parent = "VCDE"
        variant = "VFDA"
        descriptor = mutation_descriptor(parent, variant)
        reconstructed = list(parent)
        for substitution in descriptor.split(":"):
            index = int(substitution[1:-1]) - 1
            self.assertEqual(reconstructed[index], substitution[0])
            reconstructed[index] = substitution[-1]
        self.assertEqual("".join(reconstructed), variant)
        self.assertEqual(descriptor, "C2F:E4A")

    def test_ids_do_not_depend_on_candidate_order(self):
        variants = ["VCDE", "ACDA"]
        forward = {v: mutation_descriptor("ACDE", v) for v in variants}
        backward = {v: mutation_descriptor("ACDE", v) for v in reversed(variants)}
        self.assertEqual(forward, backward)

    def test_invalid_variants_are_rejected(self):
        for parent, variant in [("ACDE", "ACDE"), ("ACDE", "ACD"), ("", "")]:
            with self.subTest(parent=parent, variant=variant):
                with self.assertRaises(ValueError):
                    mutation_descriptor(parent, variant)


if __name__ == "__main__":
    unittest.main()
