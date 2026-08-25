"""Direct server endpoint tests for prediction-related endpoints.

These tests use the generated API client directly to test validation behavior
and internal endpoints that are not exposed through the high-level BiocentralAPI.
"""

import unittest

from biocentral_api._generated import (
    ApiClient,
    Configuration,
    PredictionApi,
    PredictionRequest,
    BiocentralPredictionModel,
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


class TestModelMetadataEndpoint(_ServerEndpointTestCase):
    def test_get_model_metadata(self):
        with self._make_client() as client:
            prediction_api = PredictionApi(client)
            result = prediction_api.model_metadata_api_v1_prediction_service_model_metadata_get()
        self.assertIsNotNone(result)
        metadata = result.metadata
        self.assertIsInstance(metadata, list)

    def test_model_metadata_structure(self):
        with self._make_client() as client:
            prediction_api = PredictionApi(client)
            result = prediction_api.model_metadata_api_v1_prediction_service_model_metadata_get()
        for model_meta in result.metadata:
            self.assertTrue(hasattr(model_meta, "name"))

    def test_model_metadata_consistent(self):
        with self._make_client() as client:
            prediction_api = PredictionApi(client)
            result1 = prediction_api.model_metadata_api_v1_prediction_service_model_metadata_get()
            result2 = prediction_api.model_metadata_api_v1_prediction_service_model_metadata_get()
        self.assertEqual(result1, result2)


class TestPredictValidation(_ServerEndpointTestCase):
    def test_predict_empty_sequences_rejected(self):
        with self._make_client() as client:
            prediction_api = PredictionApi(client)
            request = PredictionRequest(
                model_names=[BiocentralPredictionModel.BINDEMBED],
                sequence_input={},
            )
            with self.assertRaises(Exception):
                prediction_api.predict_api_v1_prediction_service_predict_post(request)

    def test_predict_empty_model_names_rejected(self):
        # Empty model_names list should be rejected by pydantic validation (min_length=1)
        with self.assertRaises(Exception):
            PredictionRequest(
                model_names=[],
                sequence_input={"Seq1": "MMALSLALM"},
            )

    def test_predict_short_sequence_rejected(self):
        with self._make_client() as client:
            prediction_api = PredictionApi(client)
            request = PredictionRequest(
                model_names=[BiocentralPredictionModel.BINDEMBED],
                sequence_input={"short": "MMALS"},
            )
            with self.assertRaises(Exception):
                prediction_api.predict_api_v1_prediction_service_predict_post(request)


if __name__ == "__main__":
    unittest.main()
