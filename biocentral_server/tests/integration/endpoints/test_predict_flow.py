# Integration tests for prediction endpoints.

import pytest
from typing import Dict

from tests.fixtures.test_dataset import CANONICAL_TEST_DATASET
from tests.integration.endpoints.conftest import (
    validate_error_response,
)


@pytest.fixture
def prediction_sequences(shared_embedding_sequences) -> Dict[str, str]:
    return shared_embedding_sequences


@pytest.fixture
def boundary_length_sequences() -> Dict[str, str]:
    return {
        "short_5": CANONICAL_TEST_DATASET.get_by_id("length_short_5").sequence,
        "short_10": CANONICAL_TEST_DATASET.get_by_id("length_short_10").sequence,
    }


@pytest.mark.order(1)
class TestModelMetadataEndpoint:
    @pytest.mark.integration
    def test_get_model_metadata(self, client):
        response = client.get("/prediction_service/model_metadata")

        assert response.status_code == 200
        response_json = response.json()
        assert "metadata" in response_json
        metadata = response_json["metadata"]
        assert isinstance(metadata, list)

    @pytest.mark.integration
    def test_model_metadata_structure(self, client):
        response = client.get("/prediction_service/model_metadata")
        metadata = response.json()["metadata"]

        for model_meta in metadata:
            assert isinstance(model_meta, dict)
            assert "name" in model_meta

    @pytest.mark.integration
    def test_model_metadata_consistent(self, client):
        response1 = client.get("/prediction_service/model_metadata")
        response2 = client.get("/prediction_service/model_metadata")

        assert response1.status_code == 200
        assert response2.status_code == 200
        assert response1.json() == response2.json()


@pytest.mark.order(2)
class TestPredictEndpoint:
    @pytest.mark.integration
    def test_predict_invalid_model_rejected(
        self,
        client,
        prediction_sequences,
    ):
        request_data = {
            "model_names": ["invalid_model_xyz_123"],
            "sequence_input": prediction_sequences,
        }

        response = client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422

    @pytest.mark.integration
    def test_predict_empty_sequences_rejected(self, client):
        request_data = {
            "model_names": ["BindEmbed"],
            "sequence_input": {},
        }

        response = client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422
        validate_error_response(response.json())

    @pytest.mark.integration
    def test_predict_short_sequence_rejected(
        self,
        client,
        boundary_length_sequences,
    ):
        short_seq = boundary_length_sequences["short_5"]
        request_data = {
            "model_names": ["BindEmbed"],
            "sequence_input": {"short": short_seq},
        }

        response = client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422
        validate_error_response(response.json())

    @pytest.mark.integration
    def test_predict_empty_model_names_rejected(
        self,
        client,
        prediction_sequences,
    ):
        request_data = {
            "model_names": [],
            "sequence_input": prediction_sequences,
        }

        response = client.post("/prediction_service/predict", json=request_data)

        assert response.status_code == 422
        validate_error_response(response.json())

    @pytest.mark.integration
    def test_predict_task_completes(
        self,
        client,
        poll_task,
        prediction_sequences,
        precache_prott5_embeddings,
        load_bindembed_onnx,
    ):
        request_data = {
            "model_names": ["BindEmbed"],
            "sequence_input": prediction_sequences,
        }

        response = client.post("/prediction_service/predict", json=request_data)
        assert response.status_code == 200

        task_id = response.json()["task_id"]
        print(f"[PREDICT] Submitted task {task_id}, waiting for completion...")
        result = poll_task(task_id, timeout=280, max_consecutive_errors=15)
        assert result["status"].upper() == "FINISHED", (
            f"Prediction failed: {result.get('error', 'unknown')}"
        )
        print(f"[PREDICT] Task {task_id} completed successfully")
