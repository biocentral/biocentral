# Unit tests for projection endpoint.

import pytest
from unittest.mock import MagicMock, AsyncMock, patch
from fastapi import FastAPI
from fastapi.testclient import TestClient

from biocentral_server.embeddings import projection_router


@pytest.fixture
def projection_app():
    """Create a FastAPI app with projection router for testing."""
    app = FastAPI()
    app.include_router(projection_router)
    return app


@pytest.fixture
def projection_client(projection_app):
    """Create test client for projection endpoints."""
    return TestClient(projection_app)


class TestProjectionConfigEndpoint:
    """Tests for GET /projection_service/projection_config"""

    @patch("biocentral_server.embeddings.projection_endpoint.REDUCERS")
    @patch(
        "biocentral_server.embeddings.projection_endpoint.ProtSpaceDimensionReductionConfig"
    )
    @patch("biocentral_server.embeddings.projection_endpoint.RateLimiter")
    def test_projection_config_returns_methods(
        self, mock_rate_limiter, mock_config, mock_reducers, projection_client
    ):
        """Test projection config returns available dimensionality reduction methods."""
        mock_rate_limiter.return_value = lambda: None
        mock_reducers.keys.return_value = ["umap", "tsne", "pca"]

        mock_config_instance = MagicMock()

        mock_config_instance.parameters_by_method.return_value = [
            {"name": "n_neighbors", "default": 15},
            {"name": "min_dist", "default": 0.1},
        ]
        mock_config.return_value = mock_config_instance

        response = projection_client.get("/projection_service/projection_config")

        assert response.status_code == 200
        data = response.json()
        assert "projection_config" in data
        assert isinstance(data["projection_config"], dict)

    @patch("biocentral_server.embeddings.projection_endpoint.REDUCERS")
    @patch(
        "biocentral_server.embeddings.projection_endpoint.ProtSpaceDimensionReductionConfig"
    )
    @patch("biocentral_server.embeddings.projection_endpoint.RateLimiter")
    def test_projection_config_includes_all_methods(
        self, mock_rate_limiter, mock_config, mock_reducers, projection_client
    ):
        """Test projection config includes parameters for each method."""
        mock_rate_limiter.return_value = lambda: None
        methods = ["umap", "tsne", "pca"]
        mock_reducers.keys.return_value = methods

        mock_config_instance = MagicMock()

        mock_config_instance.parameters_by_method.side_effect = lambda m: [
            {"name": "method", "default": m},
            {"name": "n_components", "default": 2},
        ]
        mock_config.return_value = mock_config_instance

        response = projection_client.get("/projection_service/projection_config")

        assert response.status_code == 200
        _ = response.json()  # we don't care about the actual response

        assert mock_config_instance.parameters_by_method.call_count == len(methods)


class TestProjectEndpoint:
    """Tests for POST /projection_service/project"""

    @patch("biocentral_server.embeddings.projection_endpoint.TaskManager")
    @patch("biocentral_server.embeddings.projection_endpoint.UserManager")
    @patch("biocentral_server.embeddings.projection_endpoint.REDUCERS")
    @patch("biocentral_server.embeddings.projection_endpoint.convert_config")
    @patch("biocentral_server.embeddings.projection_endpoint.RateLimiter")
    def test_project_valid_request(
        self,
        mock_rate_limiter,
        mock_convert_config,
        mock_reducers,
        mock_user_manager,
        mock_task_manager,
        projection_client,
    ):
        """Test projection with valid request data."""
        mock_rate_limiter.return_value = lambda: None
        mock_reducers.__contains__ = lambda self, x: x in ["umap", "tsne", "pca"]
        mock_convert_config.return_value = {}
        mock_user_manager.get_user_id_from_request = AsyncMock(return_value="user-1")
        mock_task_manager.return_value.add_task.return_value = "project-task-123"

        request_data = {
            "method": "umap",
            "sequence_data": {
                "seq1": "MVLSPADKTNVKAAWGKVGAHAGE",
                "seq2": "MGHFTEEDKATITSLWGKVNVE",
            },
            "embedder_name": "prot_t5_xl_uniref50",
            "config": {"n_neighbors": 15, "min_dist": 0.1},
        }

        response = projection_client.post(
            "/projection_service/project", json=request_data
        )

        assert response.status_code == 200
        assert "task_id" in response.json()

    @patch("biocentral_server.embeddings.projection_endpoint.REDUCERS")
    @patch("biocentral_server.embeddings.projection_endpoint.RateLimiter")
    def test_project_unknown_method(
        self, mock_rate_limiter, mock_reducers, projection_client
    ):
        """Test projection with unknown method returns 400."""
        mock_rate_limiter.return_value = lambda: None

        mock_reducers.__contains__ = lambda self, x: False

        request_data = {
            "method": "unknown_method",
            "sequence_data": {"seq1": "MVLSPADKTNVKAAWGKVGAHAGE"},
            "embedder_name": "prot_t5_xl_uniref50",
            "config": {},
        }

        response = projection_client.post(
            "/projection_service/project", json=request_data
        )

        assert response.status_code == 400
        assert "Unknown method" in response.json()["detail"]

    @patch("biocentral_server.embeddings.projection_endpoint.RateLimiter")
    def test_project_missing_required_fields(
        self, mock_rate_limiter, projection_client
    ):
        """Test projection with missing required fields fails validation."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "method": "umap",
            "embedder_name": "prot_t5_xl_uniref50",
            "config": {},
        }

        response = projection_client.post(
            "/projection_service/project", json=request_data
        )

        assert response.status_code == 422

    @patch("biocentral_server.embeddings.projection_endpoint.TaskManager")
    @patch("biocentral_server.embeddings.projection_endpoint.UserManager")
    @patch("biocentral_server.embeddings.projection_endpoint.REDUCERS")
    @patch("biocentral_server.embeddings.projection_endpoint.convert_config")
    @patch("biocentral_server.embeddings.projection_endpoint.RateLimiter")
    def test_project_with_custom_config(
        self,
        mock_rate_limiter,
        mock_convert_config,
        mock_reducers,
        mock_user_manager,
        mock_task_manager,
        projection_client,
    ):
        """Test projection with custom configuration parameters."""
        mock_rate_limiter.return_value = lambda: None
        mock_reducers.__contains__ = lambda self, x: x in ["umap", "tsne", "pca"]

        captured_config = {}

        def capture_config(config_dict):
            captured_config.update(config_dict)
            return config_dict

        mock_convert_config.side_effect = capture_config

        mock_user_manager.get_user_id_from_request = AsyncMock(return_value="user-1")
        mock_task_manager.return_value.add_task.return_value = "task-456"

        custom_config = {
            "n_neighbors": 30,
            "min_dist": 0.5,
            "metric": "cosine",
        }

        request_data = {
            "method": "umap",
            "sequence_data": {"seq1": "MVLSPADKTNVKAAWGKVGAHAGE"},
            "embedder_name": "prot_t5_xl_uniref50",
            "config": custom_config,
        }

        response = projection_client.post(
            "/projection_service/project", json=request_data
        )

        assert response.status_code == 200
        assert captured_config == custom_config
