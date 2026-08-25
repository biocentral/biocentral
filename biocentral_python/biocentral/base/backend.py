from __future__ import annotations

from typing import Protocol, Dict, Any, List, runtime_checkable

from biocentral_api import (
    BiotrainerModelResult,
    BiotrainerInferenceResult,
    Prediction,
    SequenceData,
    ProjectionResult,
)
from biocentral_api.clients import EmbeddingsResult


@runtime_checkable
class BiocentralBackend(Protocol):
    """Protocol defining the unified interface for biocentral backends.

    Both APIBackend and LocalBackend implement this interface.
    Methods that are not available in a given mode raise NotAvailableError.
    """

    def embed(
        self,
        embedder_name: str,
        sequence_data: Dict[str, str],
        reduce: bool = True,
        use_half_precision: bool = False,
    ) -> EmbeddingsResult:
        """Compute embeddings for the given sequences."""
        ...

    def train(
        self, config: Dict[str, Any], training_data: List[SequenceData]
    ) -> BiotrainerModelResult:
        """Train a model using biotrainer."""
        ...

    def inference(
        self, model_hash: str, inference_data: Dict[str, str]
    ) -> BiotrainerInferenceResult:
        """Run inference using a model trained via biotrainer (identified by hash)."""
        ...

    def project(
        self,
        embedder_name: str,
        method: str,
        sequence_data: Dict[str, str],
        projection_config: Dict[str, str],
    ) -> ProjectionResult:
        """Run projection for the embeddings of the given sequences (e.g. UMAP, PCA)"""
        ...

    def predict(
        self, model_names: List[str], sequence_data: Dict[str, str]
    ) -> Dict[str, List[Prediction]]:
        """Predict using pre-trained server-hosted models (server only)."""
        ...
