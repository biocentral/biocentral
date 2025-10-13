"""Model name routing for Triton inference server.

Maps biocentral embedder names and prediction model names to Triton model repository names.
"""

from typing import Optional, Dict


class TritonModelRouter:
    """Routes model names from biocentral API to Triton model repository."""

    # Embedding model mappings
    EMBEDDING_MODEL_MAP: Dict[str, str] = {
        # ProtT5 models
        "Rostlab/prot_t5_xl_uniref50": "prot_t5_pipeline",
        "prot_t5": "prot_t5_pipeline",
        "prot_t5_xl": "prot_t5_pipeline",
        # ESM-2 models
        "facebook/esm2_t33_650M_UR50D": "esm2_t33_pipeline",
        "esm2_t33_650M": "esm2_t33_pipeline",
        "esm2_t33": "esm2_t33_pipeline",
        "facebook/esm2_t36_3B_UR50D": "esm2_t36_pipeline",
        "esm2_t36_3B": "esm2_t36_pipeline",
        "esm2_t36": "esm2_t36_pipeline",
    }

    # Prediction model mappings
    PREDICTION_MODEL_MAP: Dict[str, str] = {
        # Per-residue predictions
        "secondary_structure": "prott5_sec",
        "prott5_sec": "prott5_sec",
        "conservation": "prott5_cons",
        "prott5_cons": "prott5_cons",
        "binding_sites": "bind_embed",
        "bind_embed": "bind_embed",
        "disorder": "seth_pipeline",
        "seth": "seth",
        "seth_pipeline": "seth_pipeline",
        # Sequence-level predictions
        "membrane_localization": "tmbed",
        "tmbed": "tmbed",
        "subcellular_localization": "light_attention_subcell",
        "light_attention_subcell": "light_attention_subcell",
        "light_attention_membrane": "light_attention_membrane",
        # Variant effect prediction
        "vespag": "vespag",
        "variant_effect": "vespag",
    }

    @classmethod
    def get_embedding_model(cls, embedder_name: str) -> Optional[str]:
        """Get Triton model name for an embedder.

        Args:
            embedder_name: Biocentral embedder name (e.g., "Rostlab/prot_t5_xl_uniref50")

        Returns:
            Triton model name (e.g., "prot_t5_pipeline") or None if not found
        """
        return cls.EMBEDDING_MODEL_MAP.get(embedder_name)

    @classmethod
    def get_prediction_model(cls, model_name: str) -> Optional[str]:
        """Get Triton model name for a prediction model.

        Args:
            model_name: Biocentral model name (e.g., "secondary_structure")

        Returns:
            Triton model name (e.g., "prott5_sec") or None if not found
        """
        return cls.PREDICTION_MODEL_MAP.get(model_name)

    @classmethod
    def is_triton_embedding_available(cls, embedder_name: str) -> bool:
        """Check if embedder has a Triton implementation.

        Args:
            embedder_name: Biocentral embedder name

        Returns:
            True if Triton model exists, False otherwise
        """
        return embedder_name in cls.EMBEDDING_MODEL_MAP

    @classmethod
    def is_triton_prediction_available(cls, model_name: str) -> bool:
        """Check if prediction model has a Triton implementation.

        Args:
            model_name: Biocentral model name

        Returns:
            True if Triton model exists, False otherwise
        """
        return model_name in cls.PREDICTION_MODEL_MAP

    @classmethod
    def get_all_embedding_models(cls) -> Dict[str, str]:
        """Get all embedding model mappings.

        Returns:
            Dictionary mapping biocentral names to Triton names
        """
        return cls.EMBEDDING_MODEL_MAP.copy()

    @classmethod
    def get_all_prediction_models(cls) -> Dict[str, str]:
        """Get all prediction model mappings.

        Returns:
            Dictionary mapping biocentral names to Triton names
        """
        return cls.PREDICTION_MODEL_MAP.copy()

    @classmethod
    def get_embedding_dimension(cls, embedder_name: str) -> Optional[int]:
        """Get embedding dimension for a model.

        Args:
            embedder_name: Biocentral embedder name

        Returns:
            Embedding dimension or None if not found
        """
        triton_model = cls.get_embedding_model(embedder_name)
        if not triton_model:
            return None

        # Map Triton model to embedding dimension
        dimension_map = {
            "prot_t5_pipeline": 1024,
            "esm2_t33_pipeline": 1280,
            "esm2_t36_pipeline": 2560,
        }
        return dimension_map.get(triton_model)

    @classmethod
    def supports_prediction_embedder(cls, model_name: str, embedder_name: str) -> bool:
        """Check if a prediction model supports a specific embedder.

        Currently, all prediction models are trained on ProtT5 (1024-dim) embeddings.

        Args:
            model_name: Prediction model name
            embedder_name: Embedder name

        Returns:
            True if compatible, False otherwise
        """
        if not cls.is_triton_prediction_available(model_name):
            return False

        # All current prediction models use ProtT5 embeddings
        supported_embedders = [
            "Rostlab/prot_t5_xl_uniref50",
            "prot_t5",
            "prot_t5_xl",
        ]

        return embedder_name in supported_embedders
