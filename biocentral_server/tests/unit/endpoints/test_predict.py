# Unit tests for predict endpoint.

import pytest
from unittest.mock import MagicMock, AsyncMock, patch
from fastapi import FastAPI
from fastapi.testclient import TestClient

from biocentral_server.predict import router as predict_router


@pytest.fixture
def predict_app():
    """Create a FastAPI app with predict router for testing."""
    app = FastAPI()
    app.include_router(predict_router)
    return app


@pytest.fixture
def predict_client(predict_app):
    """Create test client for predict endpoints."""
    return TestClient(predict_app)


class TestModelMetadataEndpoint:
    """Tests for GET /prediction_service/model_metadata"""

    @patch("biocentral_server.predict.predict_endpoint.get_metadata_for_all_models")
    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_model_metadata_returns_available_models(
        self, mock_rate_limiter, mock_get_metadata, predict_client
    ):
        """Test that model metadata endpoint returns available models."""
        mock_rate_limiter.return_value = lambda: None

        from biocentral_server.predict.models.base_model.model_metadata import (
            ModelMetadata,
            ModelOutput,
            OutputType,
        )
        from biocentral_server.predict.models import BiocentralPredictionModel
        from biotrainer.protocols import Protocol

        mock_metadata = ModelMetadata(
            name=BiocentralPredictionModel.BindEmbed,
            protocol=Protocol.residue_to_class,
            description="Binding site prediction",
            authors="Test Author",
            model_link="https://example.com",
            citation="Test Citation",
            licence="MIT",
            outputs=[
                ModelOutput(
                    name="binding",
                    description="Binding site",
                    output_type=OutputType.PER_RESIDUE,
                    value_type="class",
                )
            ],
            model_size="10MB",
            embedder="prot_t5_xl_uniref50",
        )
        mock_get_metadata.return_value = [mock_metadata]

        response = predict_client.get("/prediction_service/model_metadata")

        assert response.status_code == 200
        data = response.json()
        assert "metadata" in data
        assert len(data["metadata"]) == 1

    @patch("biocentral_server.predict.predict_endpoint.get_metadata_for_all_models")
    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_model_metadata_empty_when_no_models(
        self, mock_rate_limiter, mock_get_metadata, predict_client
    ):
        # Test metadata endpoint raises error when no models available.
        import pydantic_core

        mock_rate_limiter.return_value = lambda: None
        mock_get_metadata.return_value = []

        with pytest.raises(pydantic_core.ValidationError) as exc_info:
            predict_client.get("/prediction_service/model_metadata")

        assert "too_short" in str(exc_info.value)


class TestPredictEndpoint:
    """Tests for POST /prediction_service/predict"""

    @patch("biocentral_server.predict.predict_endpoint.TaskManager")
    @patch("biocentral_server.predict.predict_endpoint.UserManager")
    @patch("biocentral_server.predict.predict_endpoint.filter_models")
    @patch("biocentral_server.predict.predict_endpoint.get_metadata_for_all_models")
    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_predict_valid_request(
        self,
        mock_rate_limiter,
        mock_get_metadata,
        mock_filter_models,
        mock_user_manager,
        mock_task_manager,
        predict_client,
    ):
        """Test prediction with valid model and sequence data."""
        from biocentral_server.predict.models import BiocentralPredictionModel

        mock_rate_limiter.return_value = lambda: None

        mock_metadata = MagicMock()
        mock_metadata.name = BiocentralPredictionModel.BindEmbed
        mock_get_metadata.return_value = [mock_metadata]
        mock_filter_models.return_value = [MagicMock()]
        mock_user_manager.get_user_id_from_request = AsyncMock(return_value="user-1")
        mock_task_manager.return_value.add_task.return_value = "predict-task-123"

        request_data = {
            "model_names": ["BindEmbed"],
            "sequence_input": {
                "protein1": "MVLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH",
            },
        }

        response = predict_client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 200
        assert "task_id" in response.json()

    @patch("biocentral_server.predict.predict_endpoint.get_metadata_for_all_models")
    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_predict_unknown_model(
        self, mock_rate_limiter, mock_get_metadata, predict_client
    ):
        # Test prediction with invalid model name fails validation.
        mock_rate_limiter.return_value = lambda: None
        mock_get_metadata.return_value = []

        request_data = {
            "model_names": ["NonExistentModel"],
            "sequence_input": {
                "protein1": "MVLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH",
            },
        }

        response = predict_client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422

    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_predict_empty_model_names(self, mock_rate_limiter, predict_client):
        """Test prediction with empty model names list fails validation."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "model_names": [],
            "sequence_input": {"protein1": "MVLSPADKTNVKAAWGKVGAHAGE"},
        }

        response = predict_client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422

    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_predict_empty_sequences(self, mock_rate_limiter, predict_client):
        """Test prediction with empty sequence data fails validation."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "model_names": ["BindEmbed"],
            "sequence_input": {},
        }

        response = predict_client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422

    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_predict_sequence_too_short(self, mock_rate_limiter, predict_client):
        """Test prediction with sequence shorter than minimum fails."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "model_names": ["BindEmbed"],
            "sequence_input": {"protein1": "MVL"},
        }

        response = predict_client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422

    @patch("biocentral_server.predict.predict_endpoint.RateLimiter")
    def test_predict_sequence_too_long(self, mock_rate_limiter, predict_client):
        """Test prediction with sequence longer than maximum fails."""
        mock_rate_limiter.return_value = lambda: None

        request_data = {
            "model_names": ["BindEmbed"],
            "sequence_input": {"protein1": "M" * 5001},
        }

        response = predict_client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422
