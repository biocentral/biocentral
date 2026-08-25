from typing import Optional


def validate_embedder_name(embedder_name: str) -> Optional[str]:
    """Checks the given embedder name from a request and returns None if it is valid and an error otherwise."""
    embed_name = embedder_name.lower()
    if embed_name.startswith("synthyra"):
        return "Embedders from Synthyra are not supported due to custom code execution."
    return None
