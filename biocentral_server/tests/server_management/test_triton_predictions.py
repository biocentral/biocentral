"""
Mock-based tests for Triton prediction integration.

Tests the logic of TritonPredictor, PredictionModelFactory, and related functions
without requiring a real Triton server.
"""

import pytest
import asyncio
import numpy as np
import torch
from unittest.mock import Mock, AsyncMock, patch, MagicMock
from typing import Dict

from biocentral_server.predict.triton_predictor import TritonPredictor, create_triton_predictor
from biocentral_server.predict.model_factory import PredictionModelFactory
from biocentral_server.server_management import (
    TritonClientConfig,
    TritonModelRouter,
)
from biocentral_server.predict.models import ModelMetadata


@pytest.fixture
def mock_triton_repository():
    """Create a mock Triton repository."""
    repo = AsyncMock()
    repo.connect = AsyncMock()
    repo.disconnect = AsyncMock()
    repo.predict_per_residue = AsyncMock()
    repo.predict_sequence_level = AsyncMock()
    repo.predict_seth = AsyncMock()
    return repo


@pytest.fixture
def test_sequences():
    """Test sequences for prediction."""
    return {
        "seq1": "MKTAYIAKQRQISFVK",
        "seq2": "MKKLVLSLSLVLAFSS",
    }


@pytest.fixture
def test_embeddings():
    """Test embeddings (ProtT5 format)."""
    return {
        "seq1": torch.randn(16, 1024),
        "seq2": torch.randn(16, 1024),
    }


@pytest.fixture
def mock_per_residue_predictions():
    """Mock per-residue prediction outputs."""
    return [
        np.random.randn(16, 3).astype(np.float32),  # seq1: 3 classes
        np.random.randn(16, 3).astype(np.float32),  # seq2: 3 classes
    ]


@pytest.fixture
def mock_sequence_level_predictions():
    """Mock sequence-level prediction outputs."""
    return [
        np.random.randn(10).astype(np.float32),  # seq1: 10 classes
        np.random.randn(10).astype(np.float32),  # seq2: 10 classes
    ]


# ============================================================================
# TEST: TritonPredictor - Per-residue predictions
# ============================================================================


@pytest.mark.asyncio
async def test_triton_predictor_per_residue(
    test_sequences, test_embeddings, mock_triton_repository, mock_per_residue_predictions
):
    """Test TritonPredictor for per-residue predictions."""
    # Setup mock
    mock_triton_repository.predict_per_residue.return_value = mock_per_residue_predictions

    # Create metadata
    metadata = ModelMetadata(
        model_name="secondary_structure",
        model_type="per_residue",
        num_classes=3,
        class_labels=["H", "E", "C"],
    )

    # Create predictor
    with patch(
        "biocentral_server.predict.triton_predictor.create_triton_repository",
        return_value=mock_triton_repository,
    ), patch(
        "biocentral_server.predict.triton_predictor.TritonClientConfig.from_env",
        return_value=TritonClientConfig(),
    ):
        predictor = TritonPredictor(
            batch_size=2,
            triton_model_name="prott5_sec",
            metadata=metadata,
        )

        # Run prediction
        results = predictor.predict(sequences=test_sequences, embeddings=test_embeddings)

        # Verify: predictions returned
        assert results is not None
        assert len(results) == 2

        # Verify: Triton was called with correct embeddings
        assert mock_triton_repository.predict_per_residue.called
        call_args = mock_triton_repository.predict_per_residue.call_args
        assert call_args[1]["model_name"] == "prott5_sec"


# ============================================================================
# TEST: TritonPredictor - Sequence-level predictions
# ============================================================================


@pytest.mark.asyncio
async def test_triton_predictor_sequence_level(
    test_sequences, test_embeddings, mock_triton_repository, mock_sequence_level_predictions
):
    """Test TritonPredictor for sequence-level predictions."""
    # Setup mock
    mock_triton_repository.predict_sequence_level.return_value = mock_sequence_level_predictions

    # Create metadata
    metadata = ModelMetadata(
        model_name="subcellular_localization",
        model_type="sequence_level",
        num_classes=10,
        class_labels=["Nucleus", "Cytoplasm", "Mitochondrion", "ER", "Golgi", "Lysosome", "Peroxisome", "Plasma membrane", "Extracellular", "Other"],
    )

    # Create predictor
    with patch(
        "biocentral_server.predict.triton_predictor.create_triton_repository",
        return_value=mock_triton_repository,
    ), patch(
        "biocentral_server.predict.triton_predictor.TritonClientConfig.from_env",
        return_value=TritonClientConfig(),
    ):
        predictor = TritonPredictor(
            batch_size=2,
            triton_model_name="light_attention_subcell",
            metadata=metadata,
        )

        # Run prediction
        results = predictor.predict(sequences=test_sequences, embeddings=test_embeddings)

        # Verify: predictions returned
        assert results is not None
        assert len(results) == 2

        # Verify: Triton was called
        assert mock_triton_repository.predict_sequence_level.called
        call_args = mock_triton_repository.predict_sequence_level.call_args
        assert call_args[1]["model_name"] == "light_attention_subcell"


# ============================================================================
# TEST: TritonPredictor - SETH disorder prediction
# ============================================================================


@pytest.mark.asyncio
async def test_triton_predictor_seth(
    test_sequences, test_embeddings, mock_triton_repository
):
    """Test TritonPredictor for SETH disorder prediction."""
    # Setup mock
    mock_triton_repository.predict_seth.return_value = [
        np.random.randn(16).astype(np.float32),
        np.random.randn(16).astype(np.float32),
    ]

    # Create metadata
    metadata = ModelMetadata(
        model_name="disorder",
        model_type="per_residue_single",
        num_classes=1,
        class_labels=["disorder"],
    )

    # Create predictor
    with patch(
        "biocentral_server.predict.triton_predictor.create_triton_repository",
        return_value=mock_triton_repository,
    ), patch(
        "biocentral_server.predict.triton_predictor.TritonClientConfig.from_env",
        return_value=TritonClientConfig(),
    ):
        predictor = TritonPredictor(
            batch_size=2,
            triton_model_name="seth_pipeline",
            metadata=metadata,
        )

        # Run prediction (SETH doesn't use embeddings, uses sequences directly)
        results = predictor.predict(sequences=test_sequences, embeddings=None)

        # Verify: predictions returned
        assert results is not None
        assert len(results) == 2

        # Verify: Triton was called
        assert mock_triton_repository.predict_seth.called


# ============================================================================
# TEST: PredictionModelFactory - Triton backend
# ============================================================================


def test_prediction_model_factory_triton_enabled():
    """Test factory creates Triton predictor when USE_TRITON is enabled."""
    with patch(
        "biocentral_server.predict.model_factory.TritonClientConfig.from_env",
        return_value=TritonClientConfig(use_triton=True),
    ), patch(
        "biocentral_server.predict.model_factory.TritonModelRouter.is_triton_prediction_available",
        return_value=True,
    ), patch(
        "biocentral_server.predict.model_factory.create_triton_predictor"
    ) as mock_create_triton:
        # Mock return value
        mock_create_triton.return_value = Mock()

        # Create model via factory
        model = PredictionModelFactory.create_model(
            model_name="secondary_structure",
            batch_size=16,
        )

        # Verify: Triton predictor was created
        assert mock_create_triton.called
        assert mock_create_triton.call_args[1]["model_name"] == "secondary_structure"


def test_prediction_model_factory_triton_disabled():
    """Test factory creates local model when USE_TRITON is disabled."""
    with patch(
        "biocentral_server.predict.model_factory.TritonClientConfig.from_env",
        return_value=TritonClientConfig(use_triton=False),
    ), patch(
        "biocentral_server.predict.model_factory.PredictionModelFactory._create_local_model"
    ) as mock_create_local:
        # Mock return value
        mock_create_local.return_value = Mock()

        # Create model via factory
        model = PredictionModelFactory.create_model(
            model_name="secondary_structure",
            batch_size=16,
        )

        # Verify: Local model was created
        assert mock_create_local.called
        assert mock_create_local.call_args[0][0] == "secondary_structure"


def test_prediction_model_factory_no_triton_model():
    """Test factory falls back to local when Triton model not available."""
    with patch(
        "biocentral_server.predict.model_factory.TritonClientConfig.from_env",
        return_value=TritonClientConfig(use_triton=True),
    ), patch(
        "biocentral_server.predict.model_factory.TritonModelRouter.is_triton_prediction_available",
        return_value=False,  # No Triton model
    ), patch(
        "biocentral_server.predict.model_factory.PredictionModelFactory._create_local_model"
    ) as mock_create_local:
        # Mock return value
        mock_create_local.return_value = Mock()

        # Create model via factory
        model = PredictionModelFactory.create_model(
            model_name="unknown_model",
            batch_size=16,
        )

        # Verify: Local model was created as fallback
        assert mock_create_local.called


def test_prediction_model_factory_explicit_triton_flag():
    """Test factory respects explicit use_triton parameter."""
    with patch(
        "biocentral_server.predict.model_factory.TritonModelRouter.is_triton_prediction_available",
        return_value=True,
    ), patch(
        "biocentral_server.predict.model_factory.create_triton_predictor"
    ) as mock_create_triton:
        # Mock return value
        mock_create_triton.return_value = Mock()

        # Create model with explicit Triton flag
        model = PredictionModelFactory.create_model(
            model_name="secondary_structure",
            batch_size=16,
            use_triton=True,  # Explicit override
        )

        # Verify: Triton predictor was created
        assert mock_create_triton.called


# ============================================================================
# TEST: TritonModelRouter - Model name mapping
# ============================================================================


def test_triton_model_router_embedding_mapping():
    """Test embedding model name mapping."""
    # Test known embedders
    assert TritonModelRouter.get_embedding_model("prot_t5") == "prot_t5_pipeline"
    assert TritonModelRouter.get_embedding_model("esm2_t33") == "esm2_t33_pipeline"
    assert TritonModelRouter.get_embedding_model("Rostlab/prot_t5_xl_uniref50") == "prot_t5_pipeline"

    # Test unknown embedder
    assert TritonModelRouter.get_embedding_model("unknown") is None


def test_triton_model_router_prediction_mapping():
    """Test prediction model name mapping."""
    # Test known models
    assert TritonModelRouter.get_prediction_model("secondary_structure") == "prott5_sec"
    assert TritonModelRouter.get_prediction_model("conservation") == "prott5_cons"
    assert TritonModelRouter.get_prediction_model("binding_sites") == "bind_embed"
    assert TritonModelRouter.get_prediction_model("disorder") == "seth_pipeline"
    assert TritonModelRouter.get_prediction_model("membrane_localization") == "tmbed"

    # Test unknown model
    assert TritonModelRouter.get_prediction_model("unknown") is None


def test_triton_model_router_availability_check():
    """Test model availability checks."""
    # Embedding availability
    assert TritonModelRouter.is_triton_embedding_available("prot_t5") is True
    assert TritonModelRouter.is_triton_embedding_available("unknown") is False

    # Prediction availability
    assert TritonModelRouter.is_triton_prediction_available("secondary_structure") is True
    assert TritonModelRouter.is_triton_prediction_available("unknown") is False


def test_triton_model_router_embedding_dimensions():
    """Test embedding dimension lookup."""
    # Test known models
    assert TritonModelRouter.get_embedding_dimension("prot_t5") == 1024
    assert TritonModelRouter.get_embedding_dimension("esm2_t33") == 1280
    assert TritonModelRouter.get_embedding_dimension("esm2_t36") == 2560

    # Test unknown model
    assert TritonModelRouter.get_embedding_dimension("unknown") is None


def test_triton_model_router_embedder_compatibility():
    """Test prediction model embedder compatibility."""
    # All prediction models should support ProtT5
    assert TritonModelRouter.supports_prediction_embedder(
        "secondary_structure", "prot_t5"
    ) is True

    # Unknown model should return False
    assert TritonModelRouter.supports_prediction_embedder(
        "unknown", "prot_t5"
    ) is False


# ============================================================================
# TEST: create_triton_predictor() - Factory function
# ============================================================================


def test_create_triton_predictor_secondary_structure():
    """Test creating Triton predictor for secondary structure."""
    with patch(
        "biocentral_server.predict.triton_predictor.TritonModelRouter.get_prediction_model",
        return_value="prott5_sec",
    ), patch(
        "biocentral_server.predict.triton_predictor.TritonClientConfig.from_env",
        return_value=TritonClientConfig(),
    ):
        predictor = create_triton_predictor(
            model_name="secondary_structure",
            batch_size=16,
        )

        # Verify predictor created
        assert predictor is not None
        assert isinstance(predictor, TritonPredictor)
        assert predictor.triton_model_name == "prott5_sec"


def test_create_triton_predictor_unknown_model():
    """Test creating Triton predictor for unknown model raises error."""
    with patch(
        "biocentral_server.predict.triton_predictor.TritonModelRouter.get_prediction_model",
        return_value=None,
    ):
        with pytest.raises(ValueError, match="No Triton model found"):
            create_triton_predictor(
                model_name="unknown_model",
                batch_size=16,
            )


# ============================================================================
# TEST: Integration - Multi-prediction task with factory
# ============================================================================


def test_multi_prediction_task_uses_factory():
    """Test that multi_prediction_task uses the factory for model creation."""
    from biocentral_server.predict.multi_prediction_task import MultiPredictionTask

    # Mock models dict
    models = {
        "ProtT5SecondaryStructure": Mock,
        "ProtT5Conservation": Mock,
    }

    # Create task
    with patch(
        "biocentral_server.predict.multi_prediction_task.PredictionModelFactory.create_model"
    ) as mock_factory:
        # Mock factory to return a mock model
        mock_model = Mock()
        mock_model.predict.return_value = {"seq1": [0.1, 0.2, 0.7]}
        mock_factory.return_value = mock_model

        task = MultiPredictionTask(
            models=models,
            sequence_input={"seq1": "MKTAYIAKQRQISFVK"},
            batch_size=16,
            use_triton=True,
        )

        # Verify: task created with use_triton flag
        assert task.use_triton is True


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
