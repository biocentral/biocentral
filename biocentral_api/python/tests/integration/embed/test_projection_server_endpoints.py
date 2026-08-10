"""Direct server endpoint tests for projection-related endpoints.

These tests use the generated API client directly to test validation behavior
and internal endpoints that are not exposed through the high-level BiocentralAPI.
"""
import unittest

from biocentral_api._generated import (
    ApiClient,
    Configuration,
    ProjectionsApi,
    ProjectionRequest,
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


class TestProjectionConfigEndpoint(_ServerEndpointTestCase):
    def test_get_projection_config(self):
        with self._make_client() as client:
            projections_api = ProjectionsApi(client)
            result = projections_api.projection_config_api_v1_projection_service_projection_config_get()
        self.assertIsNotNone(result)
        config = result.projection_config
        self.assertIsInstance(config, dict)
        self.assertGreater(len(config), 0)

    def test_projection_config_consistent(self):
        with self._make_client() as client:
            projections_api = ProjectionsApi(client)
            result1 = projections_api.projection_config_api_v1_projection_service_projection_config_get()
            result2 = projections_api.projection_config_api_v1_projection_service_projection_config_get()
        self.assertEqual(result1, result2)


class TestProjectionValidation(_ServerEndpointTestCase):
    def test_project_invalid_method_rejected(self):
        with self._make_client() as client:
            projections_api = ProjectionsApi(client)
            request = ProjectionRequest(
                embedder_name="one_hot_encoding",
                method="invalid_method_xyz",
                sequence_data={"Seq1": "MMALSLALM"},
                config={},
            )
            with self.assertRaises(Exception):
                projections_api.project_api_v1_projection_service_project_post(request)

    def test_project_empty_sequences_rejected(self):
        with self._make_client() as client:
            projections_api = ProjectionsApi(client)
            request = ProjectionRequest(
                embedder_name="one_hot_encoding",
                method="pca",
                sequence_data={},
                config={},
            )
            with self.assertRaises(Exception):
                projections_api.project_api_v1_projection_service_project_post(request)


if __name__ == '__main__':
    unittest.main()
