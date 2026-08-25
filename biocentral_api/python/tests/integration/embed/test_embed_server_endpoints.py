"""Direct server endpoint tests for embedding-related endpoints.

These tests use the generated API client directly to test validation behavior
and internal endpoints that are not exposed through the high-level BiocentralAPI.
"""

import unittest

from biocentral_api._generated import (
    ApiClient,
    Configuration,
    EmbeddingsApi,
    EmbedRequest,
)


class _ServerEndpointTestCase(unittest.TestCase):
    """Base class that creates a generated API client pointing at the server."""

    @classmethod
    def setUpClass(cls):
        from tests.integration.conftest import _make_api, _wait_or_skip

        api = _wait_or_skip(_make_api())
        base_url = api._get_base_url()
        cls._configuration = Configuration(host=base_url)

    def _make_client(self):
        return ApiClient(self._configuration)


class TestCommonEmbeddersEndpoint(_ServerEndpointTestCase):
    def test_common_embedders_returns_list(self):
        with self._make_client() as client:
            embeddings_api = EmbeddingsApi(client)
            result = embeddings_api.common_embedders_api_v1_embeddings_service_common_embedders_get()
        self.assertIsInstance(result, list)
        self.assertGreater(len(result), 0)

    def test_common_embedders_includes_baseline_models(self):
        with self._make_client() as client:
            embeddings_api = EmbeddingsApi(client)
            result = embeddings_api.common_embedders_api_v1_embeddings_service_common_embedders_get()
        self.assertIn("one_hot_encoding", result)
        self.assertIn("blosum62", result)

    def test_common_embedders_response_is_consistent(self):
        with self._make_client() as client:
            embeddings_api = EmbeddingsApi(client)
            result1 = embeddings_api.common_embedders_api_v1_embeddings_service_common_embedders_get()
            result2 = embeddings_api.common_embedders_api_v1_embeddings_service_common_embedders_get()
        self.assertEqual(result1, result2)


class TestEmbedValidation(_ServerEndpointTestCase):
    def test_embed_empty_sequences_rejected(self):
        with self._make_client() as client:
            embeddings_api = EmbeddingsApi(client)
            request = EmbedRequest(
                embedder_name="one_hot_encoding",
                reduce=False,
                sequence_data={},
                use_half_precision=True,
            )
            with self.assertRaises(Exception):
                embeddings_api.embed_api_v1_embeddings_service_embed_post(request)

    def test_embed_missing_embedder_name_rejected(self):
        with self._make_client() as client:
            embeddings_api = EmbeddingsApi(client)
            # Passing empty string as embedder name should be rejected
            request = EmbedRequest(
                embedder_name="",
                reduce=False,
                sequence_data={"Seq1": "MMALSLALM"},
                use_half_precision=True,
            )
            with self.assertRaises(Exception):
                embeddings_api.embed_api_v1_embeddings_service_embed_post(request)


if __name__ == "__main__":
    unittest.main()
