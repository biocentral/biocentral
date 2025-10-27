"""Factory for creating prediction models with optional Triton backend.

The factory uses the MODEL_REGISTRY which maps model metadata names.
"""

from typing import Optional

from ..utils import get_logger
from ..server_management import TritonClientConfig, TritonModelRouter
from .models.base_model import BaseModel
from .models import MODEL_REGISTRY

logger = get_logger(__name__)


class PredictionModelFactory:
    """Factory for creating prediction models with backend selection.

    Uses MODEL_REGISTRY to dynamically discover and instantiate models
    based on their metadata names, supporting both ONNX and Triton backends.
    """

    @staticmethod
    def create_model(
        model_name: str,
        batch_size: int = 16,
        use_triton: Optional[bool] = None,
    ) -> BaseModel:
        """Create a prediction model with automatic backend selection.

        Args:
            model_name: Model metadata name (e.g., "BindEmbed", "TMbed", "ProtT5SecondaryStructure")
            batch_size: Batch size for predictions
            use_triton: Whether to use Triton backend. If None, uses USE_TRITON env var

        Returns:
            Prediction model instance (either Triton-backed or local ONNX)

        Raises:
            ValueError: If model_name is unknown
        """
        # Determine backend
        if use_triton is None:
            config = TritonClientConfig.from_env()
            use_triton = config.is_enabled()

        # Determine backend string
        backend = "triton" if (use_triton and TritonModelRouter.is_triton_prediction_available(model_name)) else "onnx"

        logger.info(f"Creating {backend} model for {model_name}")

        # Create model with backend parameter
        return PredictionModelFactory._create_model_with_backend(
            model_name, batch_size, backend
        )

    @staticmethod
    def _create_model_with_backend(
        model_name: str, batch_size: int, backend: str
    ) -> BaseModel:
        """Create a prediction model with specified backend.

        Args:
            model_name: Model metadata name (e.g., "BindEmbed", "TMbed")
            batch_size: Batch size for predictions
            backend: Backend to use ("onnx" or "triton")

        Returns:
            Prediction model instance

        Raises:
            ValueError: If model_name is unknown
        """
        # Look up model class in registry
        model_class = MODEL_REGISTRY.get(model_name)
        if not model_class:
            raise ValueError(
                f"Unknown model: {model_name}. Available models: {list(MODEL_REGISTRY.keys())}"
            )

        return model_class(batch_size=batch_size, backend=backend)

    @staticmethod
    def is_triton_available(model_name: str) -> bool:
        """Check if Triton backend is available for a model.

        Args:
            model_name: Model identifier

        Returns:
            True if Triton model is available and enabled
        """
        config = TritonClientConfig.from_env()
        return (
            config.is_enabled()
            and TritonModelRouter.is_triton_prediction_available(model_name)
        )

    @staticmethod
    def get_available_models() -> dict:
        """Get list of available models and their backend support.

        Returns:
            Dictionary mapping model names to backend availability
        """
        config = TritonClientConfig.from_env()
        triton_enabled = config.is_enabled()

        return {
            model_name: {
                "local_onnx": True,
                "triton": triton_enabled
                and TritonModelRouter.is_triton_prediction_available(model_name),
            }
            for model_name in MODEL_REGISTRY.keys()
        }


# Convenience function for backward compatibility
def create_prediction_model(
    model_name: str,
    batch_size: int = 16,
    use_triton: Optional[bool] = None,
) -> BaseModel:
    """Create a prediction model with automatic backend selection.

    This is a convenience wrapper around PredictionModelFactory.create_model().

    Args:
        model_name: Model identifier
        batch_size: Batch size for predictions
        use_triton: Whether to use Triton backend

    Returns:
        Prediction model instance
    """
    return PredictionModelFactory.create_model(
        model_name=model_name,
        batch_size=batch_size,
        use_triton=use_triton,
    )
