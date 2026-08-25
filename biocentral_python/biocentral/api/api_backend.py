from __future__ import annotations

from typing import Dict, Any, List, Optional

from biocentral_api import (
    BiocentralAPI,
    BiotrainerModelResult,
    BiotrainerInferenceResult,
    Prediction,
    BiocentralPredictionModel,
    SequenceData,
    ProjectionResult,
)
from biocentral_api.clients import EmbeddingsResult


class APIBackend:
    """Backend that delegates all operations to a remote biocentral server via BiocentralAPI."""

    def __init__(self, custom_api: Optional[BiocentralAPI] = None):
        self._api = custom_api if custom_api else BiocentralAPI()
        self._api.wait_until_healthy(max_wait_seconds=30)

    def embed(
        self,
        embedder_name: str,
        sequence_data: Dict[str, str],
        reduce: bool = True,
        use_half_precision: bool = False,
    ) -> EmbeddingsResult:
        task = self._api.embed(
            embedder_name,
            sequence_data,
            reduce=reduce,
            use_half_precision=use_half_precision,
        )
        return task.run()

    def train(
        self, config: Dict[str, Any], training_data: List[SequenceData]
    ) -> BiotrainerModelResult:
        task = self._api.train(config, training_data)
        return task.run()

    def inference(
        self, model_hash: str, inference_data: Dict[str, str]
    ) -> BiotrainerInferenceResult:
        task = self._api.inference(model_hash, inference_data)
        return task.run()

    def project(
        self,
        embedder_name: str,
        method: str,
        sequence_data: Dict[str, str],
        projection_config: Dict[str, str],
    ) -> ProjectionResult:
        task = self._api.project(
            embedder_name, method, sequence_data, projection_config
        )
        return task.run()

    def predict(
        self, model_names: List[str], sequence_data: Dict[str, str]
    ) -> Dict[str, List[Prediction]]:
        prediction_models = [BiocentralPredictionModel(name) for name in model_names]
        task = self._api.predict(prediction_models, sequence_data)
        return task.run()
