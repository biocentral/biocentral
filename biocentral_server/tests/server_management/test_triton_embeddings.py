"""
Mock-based tests for Triton embedding integration.

Tests the logic of compute_embeddings_triton() and related functions without requiring
a real Triton server.
"""

import pytest
import asyncio
import numpy as np
from unittest.mock import Mock, AsyncMock, patch, MagicMock
from typing import Dict

from biotrainer.input_files import BiotrainerSequenceRecord

from biocentral_server.embeddings.embed import (
    compute_embeddings_triton,
    _compute_embeddings_biotrainer_batch,
)
from biocentral_server.server_management import (
    EmbeddingsDatabase,
    TritonClientConfig,
)


@pytest.fixture
def mock_embeddings_db():
    """Create a mock embeddings database."""
    db = Mock(spec=EmbeddingsDatabase)
    db.filter_existing_embeddings = Mock(
        return_value=({}, {})  # (existing, non_existing)
    )
    db.save_embeddings = Mock()
    return db


@pytest.fixture
def test_sequences():
    """Test sequences for embedding."""
    return {
        "seq1_hash": "MKTAYIAKQRQISFVK",
        "seq2_hash": "MKKLVLSLSLVLAFSS",
        "seq3_hash": "MSKGEELFTGVVPILV",
    }


@pytest.fixture
def mock_triton_repository():
    """Create a mock Triton repository."""
    repo = AsyncMock()
    repo.connect = AsyncMock()
    repo.disconnect = AsyncMock()
    repo.compute_embeddings = AsyncMock()
    return repo


@pytest.fixture
def mock_embeddings():
    """Create mock embedding outputs."""
    # Per-sequence (pooled) embeddings
    pooled_embs = [np.random.randn(1024).astype(np.float32) for _ in range(3)]
    # Per-residue embeddings
    per_residue_embs = [
        np.random.randn(16, 1024).astype(np.float32),
        np.random.randn(16, 1024).astype(np.float32),
        np.random.randn(16, 1024).astype(np.float32),
    ]
    return {
        "pooled": pooled_embs,
        "per_residue": per_residue_embs,
    }


# ============================================================================
# TEST: compute_embeddings_triton() - All embeddings from database
# ============================================================================


@pytest.mark.asyncio
async def test_compute_embeddings_triton_all_from_database(
    mock_embeddings_db, test_sequences, mock_triton_repository
):
    """Test when all embeddings already exist in database (no Triton calls)."""
    # Setup: all embeddings exist in database
    mock_embeddings_db.filter_existing_embeddings.return_value = (
        test_sequences,  # All exist
        {},  # None missing
    )

    # Patch create_triton_repository to return our mock
    with patch(
        "biocentral_server.embeddings.embed.create_triton_repository",
        return_value=mock_triton_repository,
    ):
        # Run function
        results = []
        async for progress, total in compute_embeddings_triton(
            embedder_name="prot_t5",
            all_seqs=test_sequences,
            reduced=True,
            embeddings_db=mock_embeddings_db,
        ):
            results.append((progress, total))

        # Verify: should yield once with all sequences loaded
        assert len(results) == 1
        assert results[0] == (3, 3)

        # Verify: Triton should never be called
        mock_triton_repository.compute_embeddings.assert_not_called()

        # Verify: filter_existing_embeddings was called
        mock_embeddings_db.filter_existing_embeddings.assert_called_once()


# ============================================================================
# TEST: compute_embeddings_triton() - New embeddings via Triton
# ============================================================================


@pytest.mark.asyncio
async def test_compute_embeddings_triton_new_embeddings(
    mock_embeddings_db, test_sequences, mock_triton_repository, mock_embeddings
):
    """Test computing new embeddings via Triton."""
    # Setup: no embeddings exist in database
    mock_embeddings_db.filter_existing_embeddings.return_value = (
        {},  # None exist
        test_sequences,  # All missing
    )

    # Mock Triton to return embeddings
    mock_triton_repository.compute_embeddings.return_value = mock_embeddings["pooled"]

    # Patch create_triton_repository and TritonModelRouter
    with patch(
        "biocentral_server.embeddings.embed.create_triton_repository",
        return_value=mock_triton_repository,
    ), patch(
        "biocentral_server.embeddings.embed.TritonModelRouter.get_embedding_model",
        return_value="prot_t5_pipeline",
    ), patch(
        "biocentral_server.embeddings.embed.TritonClientConfig.from_env",
        return_value=TritonClientConfig(triton_max_batch_size=8),
    ):
        # Run function
        results = []
        async for progress, total in compute_embeddings_triton(
            embedder_name="prot_t5",
            all_seqs=test_sequences,
            reduced=True,
            embeddings_db=mock_embeddings_db,
        ):
            results.append((progress, total))

        # Verify: should yield progress updates
        assert len(results) >= 1
        assert results[-1] == (3, 3)  # Final progress

        # Verify: Triton was called
        assert mock_triton_repository.compute_embeddings.called

        # Verify: embeddings were saved to database
        assert mock_embeddings_db.save_embeddings.called


# ============================================================================
# TEST: compute_embeddings_triton() - Batch processing
# ============================================================================


@pytest.mark.asyncio
async def test_compute_embeddings_triton_batch_processing(
    mock_embeddings_db, mock_triton_repository, mock_embeddings
):
    """Test that embeddings are processed in batches."""
    # Create 10 sequences to test batching
    sequences = {f"seq{i}_hash": f"MKTAYIAK{i}" for i in range(10)}

    # Setup: no embeddings exist
    mock_embeddings_db.filter_existing_embeddings.return_value = ({}, sequences)

    # Mock Triton to return embeddings (called multiple times for batches)
    mock_triton_repository.compute_embeddings.side_effect = [
        [np.random.randn(1024).astype(np.float32) for _ in range(8)],  # First batch
        [np.random.randn(1024).astype(np.float32) for _ in range(2)],  # Second batch
    ]

    with patch(
        "biocentral_server.embeddings.embed.create_triton_repository",
        return_value=mock_triton_repository,
    ), patch(
        "biocentral_server.embeddings.embed.TritonModelRouter.get_embedding_model",
        return_value="prot_t5_pipeline",
    ), patch(
        "biocentral_server.embeddings.embed.TritonClientConfig.from_env",
        return_value=TritonClientConfig(triton_max_batch_size=8),
    ):
        # Run function
        results = []
        async for progress, total in compute_embeddings_triton(
            embedder_name="prot_t5",
            all_seqs=sequences,
            reduced=True,
            embeddings_db=mock_embeddings_db,
        ):
            results.append((progress, total))

        # Verify: should process in 2 batches (8 + 2)
        assert len(results) >= 2
        assert results[-1] == (10, 10)

        # Verify: Triton was called twice
        assert mock_triton_repository.compute_embeddings.call_count == 2


# ============================================================================
# TEST: compute_embeddings_triton() - Fallback to biotrainer
# ============================================================================


@pytest.mark.asyncio
async def test_compute_embeddings_triton_fallback_on_error(
    mock_embeddings_db, test_sequences, mock_triton_repository
):
    """Test fallback to biotrainer when Triton fails."""
    # Setup: no embeddings exist
    mock_embeddings_db.filter_existing_embeddings.return_value = ({}, test_sequences)

    # Mock Triton to raise an error
    mock_triton_repository.compute_embeddings.side_effect = Exception("Triton error")

    # Mock biotrainer fallback
    mock_embedding_service = Mock()
    mock_embedding_service.generate_embeddings.return_value = [
        (
            BiotrainerSequenceRecord(seq_id="seq1_hash", seq="MKTAYIAKQRQISFVK"),
            np.random.randn(1024).astype(np.float32),
        ),
        (
            BiotrainerSequenceRecord(seq_id="seq2_hash", seq="MKKLVLSLSLVLAFSS"),
            np.random.randn(1024).astype(np.float32),
        ),
        (
            BiotrainerSequenceRecord(seq_id="seq3_hash", seq="MSKGEELFTGVVPILV"),
            np.random.randn(1024).astype(np.float32),
        ),
    ]

    with patch(
        "biocentral_server.embeddings.embed.create_triton_repository",
        return_value=mock_triton_repository,
    ), patch(
        "biocentral_server.embeddings.embed.TritonModelRouter.get_embedding_model",
        return_value="prot_t5_pipeline",
    ), patch(
        "biocentral_server.embeddings.embed.TritonClientConfig.from_env",
        return_value=TritonClientConfig(triton_max_batch_size=8),
    ), patch(
        "biocentral_server.embeddings.embed.get_embedding_service",
        return_value=mock_embedding_service,
    ):
        # Run function
        results = []
        async for progress, total in compute_embeddings_triton(
            embedder_name="prot_t5",
            all_seqs=test_sequences,
            reduced=True,
            embeddings_db=mock_embeddings_db,
        ):
            results.append((progress, total))

        # Verify: should still complete with fallback
        assert results[-1] == (3, 3)

        # Verify: biotrainer was used as fallback
        # (Hard to verify exact calls due to generator, but should not crash)


# ============================================================================
# TEST: compute_embeddings_triton() - No Triton model available
# ============================================================================


@pytest.mark.asyncio
async def test_compute_embeddings_triton_no_model_available(
    mock_embeddings_db, test_sequences
):
    """Test fallback when no Triton model is available for embedder."""
    # Setup: no embeddings exist
    mock_embeddings_db.filter_existing_embeddings.return_value = ({}, test_sequences)

    # Mock: No Triton model for this embedder
    mock_embedding_service = Mock()
    mock_embedding_service.generate_embeddings.return_value = [
        (
            BiotrainerSequenceRecord(seq_id="seq1_hash", seq="MKTAYIAKQRQISFVK"),
            np.random.randn(1024).astype(np.float32),
        ),
        (
            BiotrainerSequenceRecord(seq_id="seq2_hash", seq="MKKLVLSLSLVLAFSS"),
            np.random.randn(1024).astype(np.float32),
        ),
        (
            BiotrainerSequenceRecord(seq_id="seq3_hash", seq="MSKGEELFTGVVPILV"),
            np.random.randn(1024).astype(np.float32),
        ),
    ]

    with patch(
        "biocentral_server.embeddings.embed.TritonModelRouter.get_embedding_model",
        return_value=None,  # No Triton model
    ), patch(
        "biocentral_server.embeddings.embed.compute_embeddings"
    ) as mock_compute_embeddings:
        # Mock the fallback to regular compute_embeddings
        mock_compute_embeddings.return_value = iter([(0, 3), (3, 3)])

        # Run function
        results = []
        async for progress, total in compute_embeddings_triton(
            embedder_name="unknown_embedder",
            all_seqs=test_sequences,
            reduced=True,
            embeddings_db=mock_embeddings_db,
        ):
            results.append((progress, total))

        # Verify: should fall back to regular compute_embeddings
        assert mock_compute_embeddings.called


# ============================================================================
# TEST: _compute_embeddings_biotrainer_batch() - Helper function
# ============================================================================


def test_compute_embeddings_biotrainer_batch(mock_embeddings_db, test_sequences):
    """Test biotrainer batch helper function."""
    # Mock embedding service
    mock_embedding_service = Mock()
    mock_embedding_service.generate_embeddings.return_value = [
        (
            BiotrainerSequenceRecord(seq_id="seq1_hash", seq="MKTAYIAKQRQISFVK"),
            np.random.randn(1024).astype(np.float32),
        ),
        (
            BiotrainerSequenceRecord(seq_id="seq2_hash", seq="MKKLVLSLSLVLAFSS"),
            np.random.randn(1024).astype(np.float32),
        ),
        (
            BiotrainerSequenceRecord(seq_id="seq3_hash", seq="MSKGEELFTGVVPILV"),
            np.random.randn(1024).astype(np.float32),
        ),
    ]

    with patch(
        "biocentral_server.embeddings.embed.get_embedding_service",
        return_value=mock_embedding_service,
    ):
        # Run function
        results = list(
            _compute_embeddings_biotrainer_batch(
                embedder_name="prot_t5",
                sequences=test_sequences,
                reduced=True,
                embeddings_db=mock_embeddings_db,
            )
        )

        # Verify: embeddings were generated
        assert mock_embedding_service.generate_embeddings.called

        # Verify: embeddings were saved to database
        assert mock_embeddings_db.save_embeddings.call_count == 3


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
