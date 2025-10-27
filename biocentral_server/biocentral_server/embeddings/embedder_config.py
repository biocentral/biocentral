"""Configuration for embedder to Triton model name mapping."""

from typing import Optional


# Mapping from biocentral embedder names to Triton pipeline model names
EMBEDDER_TRITON_MAP = {
    # ProtT5 variants
    "Rostlab/prot_t5_xl_uniref50": "prot_t5_pipeline",
    "prot_t5": "prot_t5_pipeline",
    "prot_t5_xl": "prot_t5_pipeline",
    # ESM2-T33 variants
    "facebook/esm2_t33_650M_UR50D": "esm2_t33_pipeline",
    "esm2_t33": "esm2_t33_pipeline",
    # ESM2-T36 variants
    "facebook/esm2_t36_3B_UR50D": "esm2_t36_pipeline",
    "esm2_t36": "esm2_t36_pipeline",
}


def get_triton_model_name(embedder_name: str) -> Optional[str]:
    """Get Triton model name for an embedder.
    
    Args:
        embedder_name: Biocentral embedder name (e.g., "Rostlab/prot_t5_xl_uniref50")
        
    Returns:
        Triton model name (e.g., "prot_t5_pipeline") or None if not found
    """
    return EMBEDDER_TRITON_MAP.get(embedder_name)


def get_embedding_dimension(embedder_name: str) -> Optional[int]:
    """Get embedding dimension for an embedder.
    
    Args:
        embedder_name: Biocentral embedder name
        
    Returns:
        Embedding dimension or None if not found
    """
    triton_model = get_triton_model_name(embedder_name)
    if not triton_model:
        return None
    
    # Map Triton model to embedding dimension
    dimension_map = {
        "prot_t5_pipeline": 1024,
        "esm2_t33_pipeline": 1280,
        "esm2_t36_pipeline": 2560,
    }
    return dimension_map.get(triton_model)

