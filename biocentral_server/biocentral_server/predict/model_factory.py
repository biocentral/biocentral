"""Factory for creating prediction models with optional Triton backend."""

from typing import Optional
import os

from ..utils import get_logger
from ..server_management import TritonClientConfig, TritonModelRouter
from .models.base_model import BaseModel

logger = get_logger(__name__)


class PredictionModelFactory:
    """Factory for creating prediction models with backend selection."""

    @staticmethod
    def create_model(
        model_name: str,
        batch_size: int = 16,
        use_triton: Optional[bool] = None,
    ) -> BaseModel:
        """Create a prediction model with automatic backend selection.

        Args:
            model_name: Model identifier (e.g., "secondary_structure", "conservation")
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
            model_name: Model identifier
            batch_size: Batch size for predictions
            backend: Backend to use ("onnx" or "triton")

        Returns:
            Prediction model instance

        Raises:
            ValueError: If model_name is unknown
        """
        # Import model classes
        from .models.secondary_structure.prott5_secstruct import (
            ProtT5SecondaryStructure,
        )
        from .models.conservation.prott5_conservation import ProtT5Conservation
        from .models.binding.bind_embed import BindEmbed
        from .models.disorder.seth import Seth
        from .models.membrane.tmbed import TMbed
        from .models.localization.light_attention_subcell import LightAttentionSubcell

        # Model mapping
        model_map = {
            "secondary_structure": ProtT5SecondaryStructure,
            "conservation": ProtT5Conservation,
            "binding_sites": BindEmbed,
            "disorder": Seth,
            "membrane_localization": TMbed,
            "subcellular_localization": LightAttentionSubcell,
        }

        model_class = model_map.get(model_name)
        if not model_class:
            raise ValueError(
                f"Unknown model: {model_name}. Available models: {list(model_map.keys())}"
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
        models = [
            "secondary_structure",
            "conservation",
            "binding_sites",
            "disorder",
            "membrane_localization",
            "subcellular_localization",
        ]

        config = TritonClientConfig.from_env()
        triton_enabled = config.is_enabled()

        return {
            model: {
                "local_onnx": True,
                "triton": triton_enabled
                and TritonModelRouter.is_triton_prediction_available(model),
            }
            for model in models
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
