"""
Standalone integration test for all Triton models.

This test validates that all models in the Triton model repository work correctly
with hardcoded test sequences (1 sequence and 5 sequences).

Requirements:
    - Triton server must be running with all required models
    - Tests will skip gracefully if Triton is not available
    - **ESM2-T36 requires 16-24GB RAM** (see docs/triton-memory-requirements.md)

Memory Requirements:
    - ESM2-T36 (3B params): 16-24 GB Docker memory
    - ESM2-T33 (1.3B params): 8-12 GB Docker memory
    - ProtT5-XL (770M params): 4-6 GB Docker memory

    **IMPORTANT**: Increase Docker Desktop memory to 24-32 GB for ESM2-T36 tests!
    Mac: Docker icon → Preferences → Resources → Memory
    Windows: Docker Desktop → Settings → Resources

Usage:
    # Increase Docker Desktop memory FIRST (see above)

    # Option 1: Full test suite (ESM2-T36 included, needs 24GB RAM)
    docker compose -f docker-compose.triton-test.yml up -d

    # Option 2: Lightweight (no ESM2-T36, needs 12GB RAM)
    docker compose -f docker-compose.triton-test-lite.yml up -d

    # Wait for Triton to be ready (may take 30-60s for models to load)
    curl -f http://localhost:8000/v2/health/ready

    # Run tests
    TRITON_GRPC_URL=localhost:8001 pytest tests/integration/triton_standalone/test_all_models.py -v

    # Clean up
    docker compose -f docker-compose.triton-test.yml down -v

Models loaded by docker-compose.triton-test.yml:
    - Embedding: prot_t5_pipeline, esm2_t33_pipeline, esm2_t36_pipeline
    - Prediction: prott5_sec, prott5_cons, bind_embed, seth, tmbed,
                  light_attention_subcell, light_attention_membrane, vespag
"""

import os
import asyncio
import pytest
import pytest_asyncio
import numpy as np
from typing import List

# Import Triton client components
from biocentral_server.server_management.triton_client import (
    TritonClientConfig,
    create_triton_repository,
    TritonModelRouter,
)


# Test sequences
SINGLE_SEQUENCE = [
    "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQFEVVHSLAKWKRQTLGQHDFSAGEGLYTHMKALRPDEDRLSLEVGN"
]

FIVE_SEQUENCES = [
    "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQFEVVHSLAKWKRQTLGQHDFSAGEGLYTHMKALRPDEDRLSLEVGN",
    "MKKLVLSLSLVLAFSSATAAFAAIPQNIRAQYPAVVKEQRQVVRSQNGDLADNIKKISDNLKAKIYAMHYVDVFYNKSLEKIMKDIQVTNATKTVYISINDLKRRMGGWKYPNMQVLLGRKGKKGKKAKRQ",
    "MSKGEELFTGVVPILVELDGDVNGHKFSVSGEGEGDATYGKLTLKFICTTGKLPVPWPTLVTTFSYGVQCFSRYPDHMKQHDFFKSAMPEGYVQERTIFFKDDGNYKTRAEVKFEGDTLVNRIELKGIDFKEDGNILGHKLEYNYNSHNVYIMADKQKNGIKVNFKIRHNIEDGSVQLADHYQQNTPIGDGPVLLPDNHYLSTQSALSKDPNEKRDHMVLLEFVTAAGITHGMDELYK",
    "MASMTGGQQMGRGSGMMGMGGMQGGFMGQMMGGGGFMGGMMMGGFMGGGMMGFMGGMMMGGMMGFMGGGMRP",
    "MVHLTPEEKSAVTALWGKVNVDEVGGEALGRLLVVYPWTQRFFESFGDLSTPDAVMGNPKVKAHGKKVLGAFSDGLAHLDNLKGTFATLSELHCDKLHVDPENFRLLGNVLVCVLAHHFGKEFTPPVQAAYQKVVAGVANALAHKYH",
]


@pytest.fixture(scope="function")
def triton_config():
    """Create Triton client configuration from environment."""
    # Override with test-specific settings
    config = TritonClientConfig(
        triton_grpc_url=os.getenv("TRITON_GRPC_URL", "localhost:8001"),
        triton_http_url=os.getenv("TRITON_HTTP_URL", "http://localhost:8000"),
        triton_pool_size=2,
        triton_timeout=60,
        use_triton=True,
    )
    return config


@pytest_asyncio.fixture(scope="function")
async def triton_repo(triton_config):
    """Create and connect to Triton repository."""
    repo = create_triton_repository(triton_config)
    try:
        await repo.connect()
    except Exception as e:
        pytest.skip(f"Triton server not available: {e}")
    yield repo
    await repo.disconnect()


# ============================================================================
# EMBEDDING MODEL TESTS
# ============================================================================


@pytest.mark.asyncio
class TestEmbeddingModels:
    """Test all embedding models with 1 and 5 sequences."""

    @pytest.mark.parametrize(
        "model_name,sequences,batch_size",
        [
            # ProtT5: both single and batch
            ("prot_t5_pipeline", SINGLE_SEQUENCE, 1),
            ("prot_t5_pipeline", FIVE_SEQUENCES, 5),
            # ESM2-T33: both single and batch
            ("esm2_t33_pipeline", SINGLE_SEQUENCE, 1),
            ("esm2_t33_pipeline", FIVE_SEQUENCES, 5),
            # ESM2-T36: all tests skipped (3B model causes OOM even with single sequence)
            pytest.param(
                "esm2_t36_pipeline", SINGLE_SEQUENCE, 1,
                marks=pytest.mark.skip(reason="ESM2-T36 test skipped (3B model causes OOM)")
            ),
            pytest.param(
                "esm2_t36_pipeline", FIVE_SEQUENCES, 5,
                marks=pytest.mark.skip(reason="ESM2-T36 test skipped (3B model causes OOM)")
            ),
        ]
    )
    async def test_embedding_pooled(self, triton_repo, model_name, sequences, batch_size):
        """Test embedding model with pooled output (per-sequence embedding)."""
        # Compute pooled embeddings
        embeddings = await triton_repo.compute_embeddings(
            sequences=sequences,
            model_name=model_name,
            pooled=True,
        )

        # Validate output
        assert embeddings is not None, f"No embeddings returned for {model_name}"
        assert len(embeddings) == batch_size, f"Expected {batch_size} embeddings, got {len(embeddings)}"

        # Check embedding dimensions
        expected_dims = {
            "prot_t5_pipeline": 1024,
            "esm2_t33_pipeline": 1280,
            "esm2_t36_pipeline": 2560,
        }
        expected_dim = expected_dims[model_name]

        for i, emb in enumerate(embeddings):
            assert isinstance(emb, np.ndarray), f"Embedding {i} is not numpy array"
            assert emb.shape == (expected_dim,), f"Expected shape ({expected_dim},), got {emb.shape}"
            assert emb.dtype in [np.float32, np.float64], f"Unexpected dtype: {emb.dtype}"
            assert not np.any(np.isnan(emb)), f"Embedding {i} contains NaN values"
            assert not np.all(emb == 0), f"Embedding {i} is all zeros"

    @pytest.mark.parametrize(
        "model_name,sequences,batch_size",
        [
            # ProtT5: both single and batch
            ("prot_t5_pipeline", SINGLE_SEQUENCE, 1),
            ("prot_t5_pipeline", FIVE_SEQUENCES, 5),
            # ESM2-T33: both single and batch
            ("esm2_t33_pipeline", SINGLE_SEQUENCE, 1),
            ("esm2_t33_pipeline", FIVE_SEQUENCES, 5),
            # ESM2-T36: all tests skipped (3B model causes OOM even with single sequence)
            pytest.param(
                "esm2_t36_pipeline", SINGLE_SEQUENCE, 1,
                marks=pytest.mark.skip(reason="ESM2-T36 test skipped (3B model causes OOM)")
            ),
            pytest.param(
                "esm2_t36_pipeline", FIVE_SEQUENCES, 5,
                marks=pytest.mark.skip(reason="ESM2-T36 test skipped (3B model causes OOM)")
            ),
        ]
    )
    async def test_embedding_per_residue(self, triton_repo, model_name, sequences, batch_size):
        """Test embedding model with per-residue output."""
        # Compute per-residue embeddings
        embeddings = await triton_repo.compute_embeddings(
            sequences=sequences,
            model_name=model_name,
            pooled=False,
        )

        # Validate output
        assert embeddings is not None, f"No embeddings returned for {model_name}"
        assert len(embeddings) == batch_size, f"Expected {batch_size} embeddings, got {len(embeddings)}"

        # Check embedding dimensions
        expected_dims = {
            "prot_t5_pipeline": 1024,
            "esm2_t33_pipeline": 1280,
            "esm2_t36_pipeline": 2560,
        }
        expected_dim = expected_dims[model_name]

        for i, (emb, seq) in enumerate(zip(embeddings, sequences)):
            assert isinstance(emb, np.ndarray), f"Embedding {i} is not numpy array"
            seq_len = len(seq)
            assert emb.shape == (seq_len, expected_dim), \
                f"Expected shape ({seq_len}, {expected_dim}), got {emb.shape}"
            assert emb.dtype in [np.float32, np.float64], f"Unexpected dtype: {emb.dtype}"
            assert not np.any(np.isnan(emb)), f"Embedding {i} contains NaN values"
            assert not np.all(emb == 0), f"Embedding {i} is all zeros"


# ============================================================================
# PREDICTION MODEL TESTS
# ============================================================================


@pytest_asyncio.fixture(scope="function")
async def prot_t5_embeddings_single(triton_repo):
    """Generate ProtT5 embeddings for single sequence (required for predictions)."""
    embeddings = await triton_repo.compute_embeddings(
        sequences=SINGLE_SEQUENCE,
        model_name="prot_t5_pipeline",
        pooled=False,
    )
    return embeddings


@pytest_asyncio.fixture(scope="function")
async def prot_t5_embeddings_batch(triton_repo):
    """Generate ProtT5 embeddings for 5 sequences (required for predictions)."""
    embeddings = await triton_repo.compute_embeddings(
        sequences=FIVE_SEQUENCES,
        model_name="prot_t5_pipeline",
        pooled=False,
    )
    return embeddings


@pytest_asyncio.fixture(scope="function")
async def esm2_t33_embeddings_single(triton_repo):
    """Generate ESM2-T33 embeddings for single sequence (required for VespaG)."""
    embeddings = await triton_repo.compute_embeddings(
        sequences=SINGLE_SEQUENCE,
        model_name="esm2_t33_pipeline",
        pooled=False,
    )
    return embeddings


@pytest_asyncio.fixture(scope="function")
async def esm2_t33_embeddings_batch(triton_repo):
    """Generate ESM2-T33 embeddings for 5 sequences (required for VespaG)."""
    embeddings = await triton_repo.compute_embeddings(
        sequences=FIVE_SEQUENCES,
        model_name="esm2_t33_pipeline",
        pooled=False,
    )
    return embeddings


@pytest.mark.asyncio
class TestPerResiduePredictionModels:
    """Test per-residue prediction models (secondary structure, conservation, binding, disorder, transmembrane)."""

    @pytest.mark.parametrize("model_name", ["prott5_sec", "prott5_cons", "bind_embed", "tmbed"])
    async def test_per_residue_prediction_single(self, triton_repo, model_name, prot_t5_embeddings_single):
        """Test per-residue prediction with single sequence."""
        embeddings = prot_t5_embeddings_single
        sequences = SINGLE_SEQUENCE

        # Compute predictions
        predictions = await triton_repo.predict_per_residue(
            embeddings=embeddings,
            model_name=model_name,
        )

        # Validate output
        assert predictions is not None, f"No predictions returned for {model_name}"
        assert len(predictions) == 1, f"Expected 1 prediction, got {len(predictions)}"

        for i, (pred, seq) in enumerate(zip(predictions, sequences)):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            seq_len = len(seq)

            # All these models output per-residue predictions
            assert pred.ndim == 2, f"Expected 2D output, got {pred.ndim}D"
            assert pred.shape[0] == seq_len, f"Expected {seq_len} residues, got {pred.shape[0]}"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"

    @pytest.mark.parametrize("model_name", ["prott5_sec", "prott5_cons", "bind_embed", "tmbed"])
    async def test_per_residue_prediction_batch(self, triton_repo, model_name, prot_t5_embeddings_batch):
        """Test per-residue prediction with 5 sequences."""
        embeddings = prot_t5_embeddings_batch
        sequences = FIVE_SEQUENCES

        # Compute predictions
        predictions = await triton_repo.predict_per_residue(
            embeddings=embeddings,
            model_name=model_name,
        )

        # Validate output
        assert predictions is not None, f"No predictions returned for {model_name}"
        assert len(predictions) == 5, f"Expected 5 predictions, got {len(predictions)}"

        for i, (pred, seq) in enumerate(zip(predictions, sequences)):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            seq_len = len(seq)

            assert pred.ndim == 2, f"Expected 2D output, got {pred.ndim}D"
            assert pred.shape[0] == seq_len, f"Expected {seq_len} residues, got {pred.shape[0]}"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"


@pytest.mark.asyncio
class TestSethPipeline:
    """Test SETH disorder prediction (raw model returning float scores)."""

    async def test_seth_pipeline_single(self, triton_repo):
        """Test SETH model with single sequence."""
        predictions = await triton_repo.predict_seth(
            sequences=SINGLE_SEQUENCE,
            model_name="seth",
        )

        # Validate output
        assert predictions is not None, "No predictions returned for seth"
        assert len(predictions) == 1, f"Expected 1 prediction, got {len(predictions)}"

        for i, (pred, seq) in enumerate(zip(predictions, SINGLE_SEQUENCE)):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            seq_len = len(seq)
            assert pred.shape[0] == seq_len, f"Expected {seq_len} residues, got {pred.shape[0]}"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"

    async def test_seth_pipeline_batch(self, triton_repo):
        """Test SETH model with 5 sequences."""
        predictions = await triton_repo.predict_seth(
            sequences=FIVE_SEQUENCES,
            model_name="seth",
        )

        # Validate output
        assert predictions is not None, "No predictions returned for seth"
        assert len(predictions) == 5, f"Expected 5 predictions, got {len(predictions)}"

        for i, (pred, seq) in enumerate(zip(predictions, FIVE_SEQUENCES)):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            seq_len = len(seq)
            assert pred.shape[0] == seq_len, f"Expected {seq_len} residues, got {pred.shape[0]}"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"


@pytest.mark.asyncio
class TestSequenceLevelPredictionModels:
    """Test sequence-level prediction models (subcellular localization)."""

    @pytest.mark.parametrize("model_name", ["light_attention_subcell", "light_attention_membrane"])
    async def test_sequence_level_prediction_single(self, triton_repo, model_name, prot_t5_embeddings_single):
        """Test sequence-level prediction with single sequence."""
        embeddings = prot_t5_embeddings_single

        # Compute predictions
        predictions = await triton_repo.predict_sequence_level(
            embeddings=embeddings,
            model_name=model_name,
        )

        # Validate output
        assert predictions is not None, f"No predictions returned for {model_name}"
        assert len(predictions) == 1, f"Expected 1 prediction, got {len(predictions)}"

        for i, pred in enumerate(predictions):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            assert pred.ndim == 1, f"Expected 1D output for sequence-level, got {pred.ndim}D"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"

    @pytest.mark.parametrize("model_name", ["light_attention_subcell", "light_attention_membrane"])
    async def test_sequence_level_prediction_batch(self, triton_repo, model_name, prot_t5_embeddings_batch):
        """Test sequence-level prediction with 5 sequences."""
        embeddings = prot_t5_embeddings_batch

        # Compute predictions
        predictions = await triton_repo.predict_sequence_level(
            embeddings=embeddings,
            model_name=model_name,
        )

        # Validate output
        assert predictions is not None, f"No predictions returned for {model_name}"
        assert len(predictions) == 5, f"Expected 5 predictions, got {len(predictions)}"

        for i, pred in enumerate(predictions):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            assert pred.ndim == 1, f"Expected 1D output for sequence-level, got {pred.ndim}D"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"


@pytest.mark.asyncio
class TestVariantEffectPredictionModels:
    """Test variant effect prediction models (VespaG)."""

    async def test_vespag_prediction_single(self, triton_repo, esm2_t33_embeddings_single):
        """Test VespaG variant effect prediction with single sequence."""
        embeddings = esm2_t33_embeddings_single
        sequences = SINGLE_SEQUENCE

        # Compute predictions
        predictions = await triton_repo.predict_per_residue(
            embeddings=embeddings,
            model_name="vespag",
        )

        # Validate output
        assert predictions is not None, "No predictions returned for vespag"
        assert len(predictions) == 1, f"Expected 1 prediction, got {len(predictions)}"

        for i, (pred, seq) in enumerate(zip(predictions, sequences)):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            seq_len = len(seq)

            # VespaG outputs mutation effect scores: (seq_len, 20) for 20 amino acids
            assert pred.ndim == 2, f"Expected 2D output, got {pred.ndim}D"
            assert pred.shape[0] == seq_len, f"Expected {seq_len} residues, got {pred.shape[0]}"
            assert pred.shape[1] == 20, f"Expected 20 amino acid scores, got {pred.shape[1]}"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"
            
            # Check that scores are in expected range [0.0, 1.0] (normalized)
            assert np.all(pred >= 0.0), f"Prediction {i} contains negative values"
            assert np.all(pred <= 1.0), f"Prediction {i} contains values > 1.0"

    async def test_vespag_prediction_batch(self, triton_repo, esm2_t33_embeddings_batch):
        """Test VespaG variant effect prediction with 5 sequences."""
        embeddings = esm2_t33_embeddings_batch
        sequences = FIVE_SEQUENCES

        # Compute predictions
        predictions = await triton_repo.predict_per_residue(
            embeddings=embeddings,
            model_name="vespag",
        )

        # Validate output
        assert predictions is not None, "No predictions returned for vespag"
        assert len(predictions) == 5, f"Expected 5 predictions, got {len(predictions)}"

        for i, (pred, seq) in enumerate(zip(predictions, sequences)):
            assert isinstance(pred, np.ndarray), f"Prediction {i} is not numpy array"
            seq_len = len(seq)

            # VespaG outputs mutation effect scores: (seq_len, 20) for 20 amino acids
            assert pred.ndim == 2, f"Expected 2D output, got {pred.ndim}D"
            assert pred.shape[0] == seq_len, f"Expected {seq_len} residues, got {pred.shape[0]}"
            assert pred.shape[1] == 20, f"Expected 20 amino acid scores, got {pred.shape[1]}"
            assert pred.dtype in [np.float32, np.float64], f"Unexpected dtype: {pred.dtype}"
            assert not np.any(np.isnan(pred)), f"Prediction {i} contains NaN values"
            
            # Check that scores are in expected range [0.0, 1.0] (normalized)
            assert np.all(pred >= 0.0), f"Prediction {i} contains negative values"
            assert np.all(pred <= 1.0), f"Prediction {i} contains values > 1.0"


# ============================================================================
# MODEL AVAILABILITY TESTS
# ============================================================================


@pytest.mark.asyncio
class TestModelAvailability:
    """Test that all expected models are available in Triton."""

    async def test_all_embedding_models_available(self, triton_repo):
        """Verify all embedding models are loaded in Triton."""
        expected_models = ["prot_t5_pipeline", "esm2_t33_pipeline", "esm2_t36_pipeline"]

        # Get model metadata from Triton
        for model_name in expected_models:
            try:
                # Try to get model metadata (will raise if model not available)
                metadata = await triton_repo.get_model_metadata(model_name)
                # If we get here, model is available
                assert metadata is not None, f"Model {model_name} metadata is None"
            except Exception as e:
                pytest.fail(f"Model {model_name} is not available: {e}")

    async def test_all_prediction_models_available(self, triton_repo):
        """Verify all prediction models are loaded in Triton."""
        expected_models = [
            "prott5_sec",
            "prott5_cons",
            "bind_embed",
            "seth",
            "tmbed",
            "light_attention_subcell",
            "light_attention_membrane",
            "vespag",
        ]

        for model_name in expected_models:
            try:
                # Try to get model metadata (will raise if model not available)
                metadata = await triton_repo.get_model_metadata(model_name)
                assert metadata is not None, f"Model {model_name} metadata is None"
            except Exception as e:
                pytest.fail(f"Model {model_name} is not available: {e}")


if __name__ == "__main__":
    # Run with: python -m pytest tests/triton_standalone/test_all_models.py -v
    pytest.main([__file__, "-v", "-s"])
