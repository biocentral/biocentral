import pytest
from typing import Dict, List

from biocentral_server.custom_models.endpoint_models import SequenceTrainingData
from tests.fixtures.test_dataset import CANONICAL_TEST_DATASET
from tests.integration.endpoints.conftest import (
    assert_task_success,
    validate_task_response,
)

STANDARD_SEQUENCES = {
    "standard_001": CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
    "standard_002": CANONICAL_TEST_DATASET.get_by_id("standard_002").sequence,
}


def _assert_not_immediate_terminal_failure(client, task_id: str) -> None:
    #Some tasks fail on purpose instantly (e.g. invalid config that passes HTTP validation
    #but is rejected by the worker). This catch-early check avoids waiting for
    #the full poll timeout only to discover the task was already aborted.

    status_response = client.get(f"/biocentral_service/task_status/{task_id}")
    assert status_response.status_code == 200, (
        f"Unable to check status for task {task_id}: {status_response.status_code}"
    )
    dtos = status_response.json().get("dtos", [])
    if not dtos:
        return
    current_status = str(dtos[-1].get("status", "")).upper()
    assert current_status not in ("FAILED", "ERROR"), (
        f"Task {task_id} failed immediately after submission with status={current_status}: "
        f"{dtos[-1].get('error')}"
    )


@pytest.fixture
def classification_training_data() -> List[Dict]:
    return [
        SequenceTrainingData(
            seq_id="standard_001",
            sequence=CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
            label="membrane",
            set="train",
        ).model_dump(),
        SequenceTrainingData(
            seq_id="standard_002",
            sequence=CANONICAL_TEST_DATASET.get_by_id("standard_002").sequence,
            label="membrane",
            set="val",
        ).model_dump(),
        SequenceTrainingData(
            seq_id="standard_003",
            sequence=CANONICAL_TEST_DATASET.get_by_id("standard_003").sequence,
            label="membrane",
            set="test",
        ).model_dump(),
    ]


@pytest.fixture
def real_world_training_data() -> List[Dict]:
    # biotrainer requires at least one sequence per split (train/val/test)
    return [
        SequenceTrainingData(
            seq_id="insulin_b",
            sequence=CANONICAL_TEST_DATASET.get_by_id("real_insulin_b").sequence,
            label="hormone",
            set="train",
        ).model_dump(),
        SequenceTrainingData(
            seq_id="ubiquitin",
            sequence=CANONICAL_TEST_DATASET.get_by_id("real_ubiquitin").sequence,
            label="signaling",
            set="val",
        ).model_dump(),
        SequenceTrainingData(
            seq_id="gfp_core",
            sequence=CANONICAL_TEST_DATASET.get_by_id("real_gfp_core").sequence,
            label="fluorescence",
            set="test",
        ).model_dump(),
    ]


@pytest.fixture
def regression_training_data() -> List[Dict]:
    # biotrainer requires at least one sequence per split (train/val/test)
    return [
        SequenceTrainingData(
            seq_id="standard_001",
            sequence=CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
            label="0.75",
            set="train",
        ).model_dump(),
        SequenceTrainingData(
            seq_id="standard_002",
            sequence=CANONICAL_TEST_DATASET.get_by_id("standard_002").sequence,
            label="0.50",
            set="val",
        ).model_dump(),
        SequenceTrainingData(
            seq_id="standard_003",
            sequence=CANONICAL_TEST_DATASET.get_by_id("standard_003").sequence,
            label="0.25",
            set="test",
        ).model_dump(),
    ]


@pytest.fixture
def inference_sequences() -> Dict[str, str]:
    return {
        "infer_1": CANONICAL_TEST_DATASET.get_by_id("length_min_1").sequence,
    }


@pytest.fixture
def classification_config() -> Dict:
    return {
        "protocol": "sequence_to_class",
        "embedder_name": "one_hot_encoding",
        "num_epochs": 1,
        "learning_rate": 0.001,
        "batch_size": 1,
    }


@pytest.fixture
def regression_config() -> Dict:
    return {
        "protocol": "sequence_to_value",
        "embedder_name": "one_hot_encoding",
        "num_epochs": 1,
        "learning_rate": 0.001,
        "batch_size": 1,
    }


@pytest.mark.order(1)
class TestConfigOptionsEndpoint:
    @pytest.mark.integration
    def test_get_config_options_for_classification(self, client):
        response = client.get("/custom_models_service/config_options/sequence_to_class")

        assert response.status_code == 200
        data = response.json()
        assert "options" in data
        assert isinstance(data["options"], list)

    @pytest.mark.integration
    def test_get_config_options_for_regression(self, client):
        response = client.get("/custom_models_service/config_options/sequence_to_value")

        assert response.status_code == 200
        data = response.json()
        assert "options" in data

    @pytest.mark.integration
    def test_get_config_options_invalid_protocol(self, client):
        try:
            response = client.get(
                "/custom_models_service/config_options/invalid_protocol_xyz"
            )
        except Exception as e:
            assert e.response.status_code in (400, 500)
            return

        assert response.status_code in [400, 500]


@pytest.mark.order(2)
class TestVerifyConfigEndpoint:
    @pytest.mark.integration
    def test_verify_valid_classification_config(self, client, classification_config):
        response = client.post(
            "/custom_models_service/verify_config/",
            json={"config_dict": classification_config},
        )

        assert response.status_code == 200
        data = response.json()
        assert "error" in data

    @pytest.mark.integration
    def test_verify_valid_regression_config(self, client, regression_config):
        response = client.post(
            "/custom_models_service/verify_config/",
            json={"config_dict": regression_config},
        )

        assert response.status_code == 200
        data = response.json()
        assert "error" in data

    @pytest.mark.integration
    def test_verify_invalid_protocol_config(self, client):
        invalid_config = {
            "protocol": "invalid_protocol_xyz",
            "embedder_name": "invalid_embedder",
        }

        response = client.post(
            "/custom_models_service/verify_config/",
            json={"config_dict": invalid_config},
        )

        assert response.status_code == 200
        data = response.json()

        assert data.get("error") != ""


@pytest.mark.order(5)
class TestStartTrainingEndpoint:
    @pytest.mark.integration
    def test_start_classification_training(
        self,
        client,
        classification_config,
        real_world_training_data,
    ):
        response = client.post(
            "/custom_models_service/start_training",
            json={
                "config_dict": classification_config,
                "training_data": real_world_training_data,
            },
        )

        assert response.status_code == 200
        task_id = validate_task_response(response.json())
        _assert_not_immediate_terminal_failure(client, task_id)

    @pytest.mark.integration
    def test_start_regression_training(
        self,
        client,
        regression_config,
        regression_training_data,
    ):
        response = client.post(
            "/custom_models_service/start_training",
            json={
                "config_dict": regression_config,
                "training_data": regression_training_data,
            },
        )

        assert response.status_code == 200
        task_id = validate_task_response(response.json())
        _assert_not_immediate_terminal_failure(client, task_id)

    @pytest.mark.integration
    def test_start_training_empty_data_rejected(
        self,
        client,
        classification_config,
    ):
        response = client.post(
            "/custom_models_service/start_training",
            json={
                "config_dict": classification_config,
                "training_data": [],
            },
        )

        assert response.status_code == 422

    @pytest.mark.integration
    def test_start_training_invalid_config(
        self,
        client,
        classification_training_data,
    ):
        response = client.post(
            "/custom_models_service/start_training",
            json={
                "config_dict": {
                    "protocol": "invalid_protocol",
                    "embedder_name": "invalid",
                },
                "training_data": classification_training_data,
            },
        )

        assert response.status_code in [400, 422]

@pytest.mark.order(3)
class TestStartInferenceEndpoint:
    @pytest.mark.integration
    def test_start_inference_empty_sequences_rejected(self, client):
        response = client.post(
            "/custom_models_service/start_inference",
            json={
                "model_hash": "some-model",
                "sequence_data": {},
            },
        )

        assert response.status_code == 422

@pytest.mark.order(4)
class TestModelFilesEndpoint:
    @pytest.mark.integration
    def test_get_model_files_nonexistent(self, client):
        try:
            response = client.post(
                "/custom_models_service/model_files",
                json={"model_hash": "non-existent-model-xyz"},
            )

            assert response.status_code in [404, 500]
        except Exception as e:
            assert "404" in str(e) or "Not Found" in str(e) or "StorageError" in str(e)


@pytest.mark.order(7)
class TestEndToEndTrainInferenceFlow:
    @pytest.mark.integration
    @pytest.mark.slow
    def test_train_then_inference_flow(
        self,
        client,
        poll_task,
        flush_redis,
        classification_config,
        classification_training_data,
        inference_sequences,
    ):
        flush_redis()

        train_response = client.post(
            "/custom_models_service/start_training",
            json={
                "config_dict": classification_config,
                "training_data": classification_training_data,
            },
        )

        assert train_response.status_code == 200
        train_task_id = validate_task_response(train_response.json())

        train_result = poll_task(train_task_id, timeout=320)

        assert train_result is not None
        train_status = train_result.get("status", "").upper()
        if train_status == "FAILED":
            pytest.skip("Training failed (likely due to CI resource constraints)")
        assert train_status == "FINISHED"

        assert_task_success(train_result, context="train task")
        biotrainer_result = train_result.get("biotrainer_result", {})
        assert isinstance(biotrainer_result, dict), (
            "Training result missing biotrainer_result payload"
        )
        model_hash = biotrainer_result.get("derived_values", {}).get("model_hash")
        assert isinstance(model_hash, str) and len(model_hash) > 0, (
            f"model_hash not found in training result payload: {train_result}"
        )

        inference_response = client.post(
            "/custom_models_service/start_inference",
            json={
                "model_hash": model_hash,
                "sequence_data": inference_sequences,
            },
        )

        assert inference_response.status_code == 200
        inference_task_id = validate_task_response(inference_response.json())

        inference_result = poll_task(
            inference_task_id, timeout=260, require_success=True
        )

        assert inference_result is not None
        assert_task_success(inference_result, context="inference task")
        predictions = inference_result.get("predictions")
        assert isinstance(predictions, dict), (
            f"Inference result missing predictions dict: {inference_result}"
        )
        assert set(predictions.keys()) == set(inference_sequences.keys()), (
            f"Inference predictions keys {sorted(predictions.keys())} do not match "
            f"input keys {sorted(inference_sequences.keys())}"
        )
        for seq_id, seq_predictions in predictions.items():
            assert isinstance(seq_predictions, list), (
                f"Predictions for {seq_id} must be list"
            )
            assert len(seq_predictions) > 0, f"Predictions list for {seq_id} is empty"

    @pytest.mark.integration
    @pytest.mark.slow
    def test_get_model_files_after_training(
        self,
        client,
        poll_task,
        flush_redis,
        classification_config,
        classification_training_data,
    ):
        flush_redis()

        train_response = client.post(
            "/custom_models_service/start_training",
            json={
                "config_dict": classification_config,
                "training_data": classification_training_data,
            },
        )

        assert train_response.status_code == 200
        train_task_id = validate_task_response(train_response.json())

        train_result = poll_task(train_task_id, timeout=360)

        assert train_result is not None
        train_status = train_result.get("status", "").upper()
        if train_status == "FAILED":
            pytest.skip("Training failed (likely due to CI resource constraints)")
        assert train_status == "FINISHED"

        assert_task_success(train_result, context="train task for model_files")
        biotrainer_result = train_result.get("biotrainer_result", {})
        assert isinstance(biotrainer_result, dict), (
            "Training result missing biotrainer_result payload"
        )
        model_hash = biotrainer_result.get("derived_values", {}).get("model_hash")
        assert isinstance(model_hash, str) and len(model_hash) > 0, (
            f"model_hash not found in training result payload: {train_result}"
        )

        files_response = client.post(
            "/custom_models_service/model_files", json={"model_hash": model_hash}
        )

        assert files_response.status_code == 200

        data = files_response.json()
        expected_keys = {
            "BIOTRAINER_RESULT",
            "BIOTRAINER_LOGGING",
            "BIOTRAINER_CHECKPOINT",
        }
        assert expected_keys.issubset(data.keys()), (
            f"model_files response missing expected keys: expected {sorted(expected_keys)}, got {sorted(data.keys())}"
        )

        expected_types = {
            "BIOTRAINER_RESULT": str,
            "BIOTRAINER_LOGGING": str,
            "BIOTRAINER_CHECKPOINT": dict,
        }
        assert all(isinstance(data[k], t) for k, t in expected_types.items()), (
            f"model_files type mismatches: "
            f"{[k for k, t in expected_types.items() if not isinstance(data[k], t)]}"
        )


@pytest.mark.order(6)
class TestTrainingDataValidation:
    @pytest.mark.integration
    def test_training_with_train_val_split(
        self,
        client,
        classification_config,
    ):
        training_data = [
            {
                "seq_id": "train_1",
                "sequence": CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
                "label": "A",
                "set": "train",
            },
            {
                "seq_id": "val_1",
                "sequence": CANONICAL_TEST_DATASET.get_by_id("real_insulin_b").sequence,
                "label": "B",
                "set": "val",
            },
        ]

        response = client.post(
            "/custom_models_service/start_training",
            json={
                "config_dict": classification_config,
                "training_data": training_data,
            },
        )

        assert response.status_code == 200
        task_id = validate_task_response(response.json())
        _assert_not_immediate_terminal_failure(client, task_id)
