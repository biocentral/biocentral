import pytest

from tests.integration.endpoints.conftest import (
    assert_task_success,
    validate_error_response,
    validate_task_response,
)


@pytest.mark.order(1)
class TestCommonEmbeddersEndpoint:
    @pytest.fixture(scope="class")
    def common_embedders_response(self, client):
        response = client.get("/embeddings_service/common_embedders")
        assert response.status_code == 200
        return response.json()

    @pytest.mark.integration
    def test_common_embedders_returns_list(self, common_embedders_response):
        assert isinstance(common_embedders_response, list)
        assert len(common_embedders_response) > 0

    @pytest.mark.integration
    def test_common_embedders_includes_baseline_models(self, common_embedders_response):
        assert "one_hot_encoding" in common_embedders_response
        assert "blosum62" in common_embedders_response

    @pytest.mark.integration
    def test_common_embedders_response_is_consistent(self, client):
        response1 = client.get("/embeddings_service/common_embedders")
        response2 = client.get("/embeddings_service/common_embedders")

        assert response1.status_code == 200
        assert response2.status_code == 200
        assert response1.json() == response2.json()


@pytest.mark.order(2)
class TestEmbedEndpoint:
    @pytest.mark.integration
    def test_embed_empty_sequences_rejected(
        self,
        client,
        embedder_name,
    ):
        request_data = {
            "embedder_name": embedder_name,
            "reduce": False,
            "sequence_data": {},
            "use_half_precision": True,
        }

        response = client.post("/embeddings_service/embed", json=request_data)

        assert response.status_code == 422
        validate_error_response(response.json())

    @pytest.mark.integration
    def test_embed_missing_embedder_name_rejected(
        self,
        client,
        short_test_sequences,
    ):
        request_data = {
            "reduce": False,
            "sequence_data": short_test_sequences,
            "use_half_precision": True,
        }

        response = client.post("/embeddings_service/embed", json=request_data)

        assert response.status_code == 422
        error_response = response.json()
        validate_error_response(error_response)


@pytest.mark.order(2)
class TestEndToEndEmbedFlow:
    @pytest.mark.integration
    def test_embed_and_wait_for_completion(
        self,
        client,
        poll_task,
        embedder_name,
        shared_embedding_sequences,
        verify_embedding_cache,
    ):
        print("\n[BEFORE EMBEDDING] Checking cache status...")
        verify_embedding_cache(expect_cached=False)

        request_data = {
            "embedder_name": embedder_name,
            "reduce": True,
            "sequence_data": shared_embedding_sequences,
            "use_half_precision": False,
        }

        response = client.post("/embeddings_service/embed", json=request_data)
        assert response.status_code == 200, (
            f"Failed to submit embedding task: {response.text}"
        )

        task_id = validate_task_response(response.json())
        print(f"[EMBEDDING] Submitted task {task_id}, waiting for completion...")

        result = poll_task(
            task_id,
            timeout=480,
            max_consecutive_errors=15,
            require_success=True,
        )
        assert_task_success(result, context="embed task")
        assert result.get("error") in (None, "", []), (
            "Successful embed task should not contain error payload"
        )

        task_status = result["status"].upper()
        assert task_status in ("FINISHED", "COMPLETED", "DONE"), (
            f"Embedding task failed with status '{task_status}': {result.get('error', 'unknown error')}"
        )

        print("\n[AFTER EMBEDDING] Checking cache status...")
        after = verify_embedding_cache(expect_cached=True)
        print(
            f"[CACHE POPULATED] {after['cached']}/{after['total']} embeddings now cached"
        )

    @pytest.mark.integration
    def test_embed_with_different_embedders(
        self,
        client,
        poll_task,
        single_test_sequence,
    ):
        embedders = ["one_hot_encoding", "blosum62"]

        for embedder in embedders:
            request_data = {
                "embedder_name": embedder,
                "reduce": True,
                "sequence_data": single_test_sequence,
                "use_half_precision": False,
            }

            response = client.post("/embeddings_service/embed", json=request_data)
            assert response.status_code == 200, f"Failed for embedder: {embedder}"
            task_id = validate_task_response(response.json())
            result = poll_task(
                task_id, timeout=240, max_consecutive_errors=12, require_success=True
            )
            assert_task_success(result, context=f"embed task ({embedder})")
