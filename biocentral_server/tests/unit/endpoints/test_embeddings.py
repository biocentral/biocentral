# Unit tests for embeddings endpoint.

import json
import base64
import io
import h5py
import pytest
from unittest.mock import MagicMock, AsyncMock, patch
from fastapi import FastAPI
from fastapi.testclient import TestClient

from biocentral_server.embeddings import embeddings_router
from biocentral_server.embeddings.endpoint_models import CommonEmbedder


@pytest.fixture
def embeddings_app():
    """Create a FastAPI app with embeddings router for testing."""
    app = FastAPI()
    app.include_router(embeddings_router)
    return app


@pytest.fixture
def embeddings_client(embeddings_app):
    """Create test client with mocked dependencies."""
    return TestClient(embeddings_app)


class TestCommonEmbeddersEndpoint:
    """Tests for GET /embeddings_service/common_embedders"""

    def test_common_embedders_returns_list(self, embeddings_client):
        """Test that common_embedders endpoint returns a list of embedders."""
        response = embeddings_client.get("/embeddings_service/common_embedders")

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_common_embedders_contains_expected_models(self, embeddings_client):
        """Test that common_embedders returns expected embedder names."""
        response = embeddings_client.get("/embeddings_service/common_embedders")

        assert response.status_code == 200
        embedders = response.json()

        expected_embedders = [e.value for e in CommonEmbedder]
        assert embedders == expected_embedders

    def test_common_embedders_includes_prot_t5(self, embeddings_client):
        """Test that ProtT5 embedder is available."""
        response = embeddings_client.get("/embeddings_service/common_embedders")

        assert response.status_code == 200
        embedders = response.json()
        assert "Rostlab/prot_t5_xl_uniref50" in embedders

    def test_common_embedders_includes_esm2(self, embeddings_client):
        """Test that ESM2 embedders are available."""
        response = embeddings_client.get("/embeddings_service/common_embedders")

        assert response.status_code == 200
        embedders = response.json()

        esm2_models = [e for e in embedders if "esm2" in e.lower()]
        assert len(esm2_models) >= 1

    def test_common_embedders_includes_baseline_models(self, embeddings_client):
        """Test that baseline embedders are available."""
        response = embeddings_client.get("/embeddings_service/common_embedders")

        assert response.status_code == 200
        embedders = response.json()

        assert "one_hot_encoding" in embedders
        assert "blosum62" in embedders


class TestEmbedEndpoint:
    """Tests for POST /embeddings_service/embed"""

    @patch("biocentral_server.embeddings.embeddings_endpoint.TaskManager")
    @patch("biocentral_server.embeddings.embeddings_endpoint.UserManager")
    @patch("biocentral_server.embeddings.embeddings_endpoint.MetricsCollector")
    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_embed_valid_request(
        self,
        mock_rate_limiter,
        mock_metrics,
        mock_user_manager,
        mock_task_manager,
        embeddings_client,
    ):
        """Test embedding request with valid sequence data."""

        mock_rate_limiter.return_value = lambda: None
        mock_task_manager.return_value.add_task.return_value = "task-123"
        mock_user_manager.get_user_id_from_request = AsyncMock(return_value="user-1")

        request_data = {
            "embedder_name": "prot_t5_xl_uniref50",
            "reduce": False,
            "sequence_data": {
                "seq1": "MVLSPADKTNVKAAWGKVGAHAGE",
                "seq2": "MGHFTEEDKATITSLWGKVNVE",
            },
            "use_half_precision": False,
        }

        response = embeddings_client.post(
            "/embeddings_service/embed", json=request_data
        )

        assert response.status_code == 200
        assert "task_id" in response.json()

    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_embed_empty_sequences(self, mock_rate_limiter, embeddings_client):
        """Test embedding request with empty sequence data fails validation."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "embedder_name": "prot_t5_xl_uniref50",
            "reduce": False,
            "sequence_data": {},
            "use_half_precision": False,
        }

        response = embeddings_client.post(
            "/embeddings_service/embed", json=request_data
        )

        assert response.status_code == 422

    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_embed_missing_embedder_name(self, mock_rate_limiter, embeddings_client):
        """Test embedding request without embedder name fails."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "reduce": False,
            "sequence_data": {"seq1": "MVLSPADKTNVKAAWGKVGAHAGE"},
            "use_half_precision": False,
        }

        response = embeddings_client.post(
            "/embeddings_service/embed", json=request_data
        )

        assert response.status_code == 422


class TestGetMissingEmbeddingsEndpoint:
    """Tests for POST /embeddings_service/get_missing_embeddings"""

    @patch("biocentral_server.embeddings.embeddings_endpoint.EmbeddingDatabaseFactory")
    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_get_missing_embeddings_valid(
        self, mock_rate_limiter, mock_db_factory, embeddings_client
    ):
        """Test checking missing embeddings with valid request."""
        mock_rate_limiter.return_value = lambda: None

        mock_db = MagicMock()

        mock_db.filter_existing_embeddings.return_value = (
            {"seq1": "MVLSPAD"},
            {"seq2": "MGHFTEE"},
        )
        mock_db_factory.return_value.get_embeddings_db.return_value = mock_db

        request_data = {
            "sequences": json.dumps({"seq1": "MVLSPAD", "seq2": "MGHFTEE"}),
            "embedder_name": "prot_t5_xl_uniref50",
            "reduced": True,
        }

        response = embeddings_client.post(
            "/embeddings_service/get_missing_embeddings", json=request_data
        )

        assert response.status_code == 200
        assert "missing" in response.json()

    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_get_missing_embeddings_invalid_json(
        self, mock_rate_limiter, embeddings_client
    ):
        """Test with invalid JSON in sequences field."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "sequences": "not valid json {",
            "embedder_name": "prot_t5_xl_uniref50",
            "reduced": True,
        }

        response = embeddings_client.post(
            "/embeddings_service/get_missing_embeddings", json=request_data
        )

        assert response.status_code == 422

    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_get_missing_embeddings_sequences_not_dict(
        self, mock_rate_limiter, embeddings_client
    ):
        """Test with sequences that parse to non-dict JSON."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "sequences": json.dumps(["seq1", "seq2"]),
            "embedder_name": "prot_t5_xl_uniref50",
            "reduced": True,
        }

        response = embeddings_client.post(
            "/embeddings_service/get_missing_embeddings", json=request_data
        )

        assert response.status_code == 422


class TestAddEmbeddingsEndpoint:
    """Tests for POST /embeddings_service/add_embeddings"""

    @staticmethod
    def _create_h5_bytes(embeddings_dict: dict) -> str:
        """Helper to create base64-encoded HDF5 file."""
        buffer = io.BytesIO()
        with h5py.File(buffer, "w") as f:
            for key, value in embeddings_dict.items():
                f.create_dataset(key, data=value)
        buffer.seek(0)
        return base64.b64encode(buffer.read()).decode("utf-8")

    @patch("biocentral_server.embeddings.embeddings_endpoint.EmbeddingDatabaseFactory")
    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_add_embeddings_valid(
        self, mock_rate_limiter, mock_db_factory, embeddings_client
    ):
        """Test adding embeddings with valid HDF5 data."""
        mock_rate_limiter.return_value = lambda: None
        mock_db = MagicMock()
        mock_db_factory.return_value.get_embeddings_db.return_value = mock_db

        import numpy as np

        buffer = io.BytesIO()
        with h5py.File(buffer, "w") as f:
            ds1 = f.create_dataset("0", data=np.random.rand(1024).astype(np.float32))
            ds1.attrs["original_id"] = "seq1"
            ds2 = f.create_dataset("1", data=np.random.rand(1024).astype(np.float32))
            ds2.attrs["original_id"] = "seq2"
        buffer.seek(0)
        h5_bytes = base64.b64encode(buffer.read()).decode("utf-8")

        sequences = json.dumps({"seq1": "MVLSPAD", "seq2": "MGHFTEE"})

        request_data = {
            "h5_bytes": h5_bytes,
            "sequences": sequences,
            "embedder_name": "prot_t5_xl_uniref50",
            "reduced": True,
        }

        response = embeddings_client.post(
            "/embeddings_service/add_embeddings", json=request_data
        )

        assert response.status_code in [200, 201]

    @patch("biocentral_server.embeddings.embeddings_endpoint.RateLimiter")
    def test_add_embeddings_invalid_base64(self, mock_rate_limiter, embeddings_client):
        """Test adding embeddings with invalid base64 data."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "h5_bytes": "not-valid-base64!!!",
            "embedder_name": "prot_t5_xl_uniref50",
            "reduced": True,
        }

        response = embeddings_client.post(
            "/embeddings_service/add_embeddings", json=request_data
        )

        assert response.status_code in [400, 422, 500]
