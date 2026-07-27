"""Unit tests for FixedEmbedder."""

import pytest
import numpy as np

from tests.fixtures.fixed_embedder import (
    FixedEmbedder,
    FixedEmbedderRegistry,
    get_fixed_embedder,
    generate_test_embeddings,
    generate_test_embeddings_dict,
)


class TestFixedEmbedderDeterminism:
    """Test that FixedEmbedder produces deterministic results."""

    def test_same_sequence_same_embedding(self):
        """Same sequence should always produce the same embedding."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequence = "MKTAYIAKQRQISFVK"

        embedding1 = embedder.embed(sequence)
        embedding2 = embedder.embed(sequence)

        np.testing.assert_array_equal(embedding1, embedding2)

    def test_same_sequence_different_instances(self):
        """Different embedder instances with same config should give same results."""
        embedder1 = FixedEmbedder(model_name="prot_t5", seed_base=42)
        embedder2 = FixedEmbedder(model_name="prot_t5", seed_base=42)

        sequence = "MKTAYIAKQRQISFVK"

        embedding1 = embedder1.embed(sequence)
        embedding2 = embedder2.embed(sequence)

        np.testing.assert_array_equal(embedding1, embedding2)

    def test_different_sequences_different_embeddings(self):
        """Different sequences should produce different embeddings."""
        embedder = FixedEmbedder(model_name="prot_t5")

        seq1 = "MKTAYIAK"
        seq2 = "ACDEFGHI"

        emb1 = embedder.embed(seq1)
        emb2 = embedder.embed(seq2)

        assert not np.allclose(emb1, emb2)

    def test_different_seeds_different_embeddings(self):
        """Different seed bases should produce different embeddings."""
        embedder1 = FixedEmbedder(model_name="prot_t5", seed_base=42)
        embedder2 = FixedEmbedder(model_name="prot_t5", seed_base=123)

        sequence = "MKTAYIAK"

        emb1 = embedder1.embed(sequence)
        emb2 = embedder2.embed(sequence)

        assert not np.allclose(emb1, emb2)

    def test_pooled_embedding_determinism(self):
        """Pooled embeddings should also be deterministic."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequence = "MKTAYIAKQRQISFVK"

        pooled1 = embedder.embed_pooled(sequence)
        pooled2 = embedder.embed_pooled(sequence)

        np.testing.assert_array_equal(pooled1, pooled2)

    def test_determinism_across_batch_methods(self):
        """embed_batch should give same results as individual embed calls."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequences = ["MKTAYIAK", "ACDEFGHI", "QRSTVWY"]

        batch_embeddings = embedder.embed_batch(sequences, pooled=False)

        individual_embeddings = [embedder.embed(seq) for seq in sequences]

        for batch_emb, ind_emb in zip(batch_embeddings, individual_embeddings):
            np.testing.assert_array_equal(batch_emb, ind_emb)


class TestFixedEmbedderDimensions:
    """Test embedding dimension handling."""

    @pytest.mark.parametrize(
        "model_name,expected_dim",
        [
            ("prot_t5", 1024),
            ("esm2_t33", 1280),
            ("esm2_t36", 2560),
        ],
    )
    def test_model_dimensions(self, model_name: str, expected_dim: int):
        """Each model should produce embeddings with correct dimensions."""
        embedder = FixedEmbedder(model_name=model_name)
        sequence = "MKTAYIAK"

        embedding = embedder.embed(sequence)

        assert embedding.shape == (len(sequence), expected_dim)

    def test_custom_dimension(self):
        """Custom embedding dimension should override default."""
        custom_dim = 512
        embedder = FixedEmbedder(model_name="prot_t5", embedding_dim=custom_dim)
        sequence = "MKTAYIAK"

        embedding = embedder.embed(sequence)

        assert embedding.shape == (len(sequence), custom_dim)

    def test_pooled_dimension(self):
        """Pooled embeddings should have shape (embedding_dim,)."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequence = "MKTAYIAK"

        pooled = embedder.embed_pooled(sequence)

        assert pooled.shape == (1024,)

    def test_get_embedding_dimension(self):
        """get_embedding_dimension should return correct value."""
        embedder = FixedEmbedder(model_name="esm2_t33")
        assert embedder.get_embedding_dimension() == 1280


class TestFixedEmbedderEdgeCases:
    """Test edge cases and boundary conditions."""

    def test_empty_sequence(self):
        """Empty sequence should return empty embedding."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("")

        assert embedding.shape == (0, 1024)

    def test_single_residue(self):
        """Single residue sequence should work."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("M")

        assert embedding.shape == (1, 1024)
        assert not np.any(np.isnan(embedding))

    def test_very_long_sequence(self):
        """Very long sequences should work without issues."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequence = "M" + "AKTGV" * 400

        embedding = embedder.embed(sequence)

        assert embedding.shape == (len(sequence), 1024)
        assert not np.any(np.isnan(embedding))

    def test_unknown_amino_acid(self):
        """Unknown amino acids (X) should be handled."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("MXKXAX")

        assert embedding.shape == (6, 1024)
        assert not np.any(np.isnan(embedding))

    def test_all_amino_acids(self):
        """All 20 standard amino acids should work."""
        embedder = FixedEmbedder(model_name="prot_t5")
        all_aa = "ACDEFGHIKLMNPQRSTVWY"

        embedding = embedder.embed(all_aa)

        assert embedding.shape == (20, 1024)
        assert not np.any(np.isnan(embedding))

    def test_homopolymer(self):
        """Homopolymer sequences should produce valid embeddings."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("A" * 50)

        assert embedding.shape == (50, 1024)

        assert not np.allclose(embedding[0], embedding[1])

    def test_lowercase_handling(self):
        """Lowercase amino acids should be handled correctly."""
        embedder = FixedEmbedder(model_name="prot_t5")

        upper_emb = embedder.embed("MKTAYIAK")
        lower_emb = embedder.embed("mktayiak")

        np.testing.assert_array_equal(upper_emb, lower_emb)


class TestFixedEmbedderBatchOperations:
    """Test batch embedding operations."""

    def test_batch_embedding(self):
        """Batch embedding should work correctly."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequences = ["MKTAYIAK", "ACDEFGHI", "QRSTVWY"]

        embeddings = embedder.embed_batch(sequences, pooled=False)

        assert len(embeddings) == 3
        for i, (emb, seq) in enumerate(zip(embeddings, sequences)):
            assert emb.shape == (len(seq), 1024), f"Sequence {i} has wrong shape"

    def test_batch_pooled(self):
        """Batch pooled embedding should work correctly."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequences = ["MKTAYIAK", "ACDEFGHI", "QRSTVWY"]

        embeddings = embedder.embed_batch(sequences, pooled=True)

        assert len(embeddings) == 3
        for emb in embeddings:
            assert emb.shape == (1024,)

    def test_dict_embedding(self):
        """Dictionary-based embedding should work correctly."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequences = {
            "seq0": "MKTAYIAK",
            "seq1": "ACDEFGHI",
            "seq2": "QRSTVWY",
        }

        embeddings = embedder.embed_dict(sequences, pooled=False)

        assert len(embeddings) == 3
        assert set(embeddings.keys()) == set(sequences.keys())
        for seq_id, emb in embeddings.items():
            assert emb.shape == (len(sequences[seq_id]), 1024)

    def test_empty_batch(self):
        """Empty batch should return empty list."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embeddings = embedder.embed_batch([], pooled=False)

        assert embeddings == []

    def test_empty_dict(self):
        """Empty dict should return empty dict."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embeddings = embedder.embed_dict({}, pooled=False)

        assert embeddings == {}


class TestFixedEmbedderRegistry:
    """Test the embedder registry functionality."""

    def setup_method(self):
        """Clear registry before each test."""
        FixedEmbedderRegistry.clear()

    def teardown_method(self):
        """Clear registry after each test."""
        FixedEmbedderRegistry.clear()

    def test_get_embedder_creates_instance(self):
        """get_embedder should create new instance if not exists."""
        embedder = FixedEmbedderRegistry.get_embedder("prot_t5")

        assert embedder is not None
        assert embedder.model_name == "prot_t5"

    def test_get_embedder_reuses_instance(self):
        """get_embedder should return same instance for same config."""
        embedder1 = FixedEmbedderRegistry.get_embedder("prot_t5", seed_base=42)
        embedder2 = FixedEmbedderRegistry.get_embedder("prot_t5", seed_base=42)

        assert embedder1 is embedder2

    def test_get_embedder_different_models(self):
        """Different models should have different instances."""
        embedder1 = FixedEmbedderRegistry.get_embedder("prot_t5")
        embedder2 = FixedEmbedderRegistry.get_embedder("esm2_t33")

        assert embedder1 is not embedder2

    def test_clear_registry(self):
        """clear should remove all cached instances."""
        embedder1 = FixedEmbedderRegistry.get_embedder("prot_t5")
        FixedEmbedderRegistry.clear()
        embedder2 = FixedEmbedderRegistry.get_embedder("prot_t5")

        assert embedder1 is not embedder2


class TestConvenienceFunctions:
    """Test convenience functions."""

    def test_get_fixed_embedder(self):
        """get_fixed_embedder should return working embedder."""
        embedder = get_fixed_embedder("prot_t5")

        assert embedder is not None
        embedding = embedder.embed("MKTAYIAK")
        assert embedding.shape == (8, 1024)

    def test_generate_test_embeddings(self):
        """generate_test_embeddings should work for lists."""
        sequences = ["MKTAYIAK", "ACDEFGHI"]

        embeddings = generate_test_embeddings(sequences, model_name="prot_t5")

        assert len(embeddings) == 2
        assert embeddings[0].shape == (8, 1024)
        assert embeddings[1].shape == (8, 1024)

    def test_generate_test_embeddings_pooled(self):
        """generate_test_embeddings should work with pooled=True."""
        sequences = ["MKTAYIAK", "ACDEFGHI"]

        embeddings = generate_test_embeddings(
            sequences, model_name="prot_t5", pooled=True
        )

        assert len(embeddings) == 2
        for emb in embeddings:
            assert emb.shape == (1024,)

    def test_generate_test_embeddings_dict(self):
        """generate_test_embeddings_dict should work."""
        sequences = {"protein_a": "MKTAYIAK", "protein_b": "ACDEFGHI"}

        embeddings = generate_test_embeddings_dict(sequences, model_name="prot_t5")

        assert len(embeddings) == 2
        assert "protein_a" in embeddings
        assert "protein_b" in embeddings
        assert embeddings["protein_a"].shape == (8, 1024)


class TestEmbeddingQuality:
    """Test that embeddings have reasonable statistical properties."""

    def test_embedding_not_all_zeros(self):
        """Embeddings should not be all zeros."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("MKTAYIAK")

        assert not np.allclose(embedding, 0)

    def test_embedding_no_nan(self):
        """Embeddings should not contain NaN values."""
        embedder = FixedEmbedder(model_name="prot_t5")

        for seq in ["M", "MKTAYIAK", "X" * 10, "A" * 100]:
            embedding = embedder.embed(seq)
            assert not np.any(np.isnan(embedding)), f"NaN found for sequence: {seq}"

    def test_embedding_no_inf(self):
        """Embeddings should not contain infinite values."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("MKTAYIAK")

        assert not np.any(np.isinf(embedding))

    def test_embedding_reasonable_magnitude(self):
        """Embeddings should have reasonable magnitudes."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("MKTAYIAK")

        assert np.abs(embedding).max() < 100

    def test_embedding_dtype(self):
        """Embeddings should be float32."""
        embedder = FixedEmbedder(model_name="prot_t5")

        embedding = embedder.embed("MKTAYIAK")

        assert embedding.dtype == np.float32

    def test_different_positions_have_different_embeddings(self):
        """Different positions in a sequence should have different embeddings."""
        embedder = FixedEmbedder(model_name="prot_t5")
        sequence = "MKTAYIAK"

        embedding = embedder.embed(sequence)

        for i in range(len(sequence) - 1):
            assert not np.allclose(embedding[i], embedding[i + 1]), (
                f"Positions {i} and {i + 1} should differ"
            )


class TestFixedEmbedderRepr:
    """Test string representation."""

    def test_repr(self):
        """__repr__ should return informative string."""
        embedder = FixedEmbedder(model_name="prot_t5", seed_base=42)

        repr_str = repr(embedder)

        assert "FixedEmbedder" in repr_str
        assert "prot_t5" in repr_str
        assert "1024" in repr_str
        assert "42" in repr_str
