import torch
from contextlib import contextmanager
from typing import Dict, Union, Optional

from biotrainer.embedders import EmbeddingService

from .biotrainer_embedding_adapter import get_adapter_embedding_service

from ..embedding_database import EmbeddingsDatabase


def _setup_biotrainer_database_storage(embeddings_db: EmbeddingsDatabase,
                                      sequence_dict: Dict[str, str],
                                      reduced: bool):
    """
    Temporarily replaces biotrainer's get_embedding_service with a version that uses database storage.
    Use with contextmanager to ensure cleanup.
    """
    from biotrainer import embedders

    # Store original function
    original_get_service = embedders.get_embedding_service

    # Create replacement function
    def get_embedding_service_with_db(embeddings_file_path: Union[str, None],
                                      embedder_name: Union[str, None],
                                      use_half_precision: Optional[bool] = False,
                                      device: Optional[Union[str, torch.device]] = None) -> EmbeddingService:
        return get_adapter_embedding_service(
            embeddings_file_path=embeddings_file_path,
            embedder_name=embedder_name,
            use_half_precision=use_half_precision,
            device=device,
            embeddings_db=embeddings_db,
            sequence_dict=sequence_dict,
            reduced=reduced
        )

    # Replace function
    embedders.get_embedding_service = get_embedding_service_with_db

    return original_get_service


@contextmanager
def use_database_storage_in_biotrainer(embeddings_db: EmbeddingsDatabase,
                                       sequence_dict: Dict[str, str],
                                       reduced: bool):
    """
    Context manager that temporarily replaces biotrainer's embedding storage with database storage.
    By doing this, biotrainer can use the embeddings_database rather than relying on h5 files.
    """
    from biotrainer import embedders

    # Setup injection
    original_func = _setup_biotrainer_database_storage(
        embeddings_db=embeddings_db,
        sequence_dict=sequence_dict,
        reduced=reduced
    )

    try:
        yield
    finally:
        # Restore original function
        embedders.get_embedding_service = original_func