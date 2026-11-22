"""Factory for creating prediction models with ONNX backend.

The factory uses the MODEL_REGISTRY which maps model metadata names.
"""
from typing import Any

from .models import BaseModel, MODEL_REGISTRY, BiocentralPredictionModel, ModelMetadata

from ..utils import get_logger

logger = get_logger(__name__)


class PredictionModelFactory:
    """Factory for creating prediction models with ONNX backend.

    Uses MODEL_REGISTRY to dynamically discover and instantiate models
    based on their metadata names.
    """

    def __init__(self):
        self._model_registry = MODEL_REGISTRY

    def create_model(
        self,
        model_name: BiocentralPredictionModel,
        batch_size: int = 16,
    ) -> BaseModel:
        """Create a prediction model with ONNX backend.

        Args:
            model_name: Model metadata name (e.g., "BindEmbed", "TMbed", "ProtT5SecondaryStructure")
            batch_size: Batch size for predictions

        Returns:
            Prediction model instance with local ONNX backend

        Raises:
            ValueError: If model_name is unknown
        """
        logger.info(f"Creating prediction model {model_name}..")

        # Look up model class in registry
        model_class = self._model_registry.get(model_name)
        if not model_class:
            raise ValueError(
                f"Unknown model: {model_name}. Available models: {list(self._model_registry.keys())}"
            )

        return model_class(batch_size=batch_size)

    def get_metadata_for_all_models(self) -> list[ModelMetadata]:
        return [model.get_metadata() for model in self._model_registry.values()]

    def filter_models(
            self,
            model_names: list[BiocentralPredictionModel],
    ) -> dict[BiocentralPredictionModel, Any]:
        assert all(
            [model_name in self._model_registry for model_name in model_names]
        ), "Invalid model name, this should have been caught in the endpoint"

        return {
            model_name: self._model_registry[model_name]
            for model_name in model_names
            if model_name in self._model_registry
        }
