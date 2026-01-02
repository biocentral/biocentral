import torch

from biotrainer.embedders import get_embedding_service
from biotrainer.embedders.services import EmbeddingService
from biotrainer.embedders.interfaces import EmbedderInterface
from typing import List, Generator, Optional, Union, Dict, Any

from ..utils import get_logger
from ..server_management import (
    TritonClientConfig,
    get_shared_repository,
)

logger = get_logger(__name__)


def get_biotrainer_embedding_service(
    embedder_name: str,
    custom_tokenizer_config: Optional[str],
    use_half_precision: Optional[bool] = False,
    device: Optional[Union[str, torch.device]] = None,
    finetuning_config: Optional[Dict[str, Any]] = None,
    force_biotrainer: Optional[bool] = False,
):
    """Biotrainer library adapter to get the appropriate EmbeddingService instance.
    Does not support finetuning yet.
    :param force_biotrainer: Force usage of Biotrainer library even if Triton is available (fallback).
    """
    if force_biotrainer:
        return get_embedding_service(
            embedder_name,
            custom_tokenizer_config,
            use_half_precision,
            device,
            finetuning_config,
        )

    if BiotrainerTritonEmbedder.is_triton_embedding_available(embedder_name):
        embedder = BiotrainerTritonEmbedder(embedder_name=embedder_name)
        return EmbeddingService(
            embedder=embedder, use_half_precision=use_half_precision
        )
    return get_embedding_service(
        embedder_name,
        custom_tokenizer_config,
        use_half_precision,
        device,
        finetuning_config,
    )


class BiotrainerTritonEmbedder(EmbedderInterface):
    def __init__(self, embedder_name: str):
        self.config = TritonClientConfig.from_env()
        self.triton_repo = get_shared_repository(self.config)
        self.triton_model_name = self._get_triton_model_name(embedder_name)

    @staticmethod
    def _get_triton_model_name(embedder_name: str) -> Optional[str]:
        """Get Triton model name for an embedder.

        Args:
            embedder_name: Biocentral embedder name (e.g., "Rostlab/prot_t5_xl_uniref50")

        Returns:
            Triton model name (e.g., "prot_t5_pipeline") or None if not found
        """
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

        return EMBEDDER_TRITON_MAP.get(embedder_name)

    @staticmethod
    def _get_embedding_dimension(embedder_name: str) -> Optional[int]:
        """Get embedding dimension for an embedder.

        Args:
            embedder_name: Biocentral embedder name

        Returns:
            Embedding dimension or None if not found
        """
        triton_model = BiotrainerTritonEmbedder._get_triton_model_name(embedder_name)
        if not triton_model:
            return None

        # Map Triton model to embedding dimension
        dimension_map = {
            "prot_t5_pipeline": 1024,
            "esm2_t33_pipeline": 1280,
            "esm2_t36_pipeline": 2560,
        }
        return dimension_map.get(triton_model)

    @staticmethod
    def is_triton_embedding_available(embedder_name: str) -> bool:
        """Check if Triton embedding is available for embedder."""
        try:
            config = TritonClientConfig.from_env()
            if not config.is_enabled():
                return False

            # Check if embedder has a Triton model mapping
            triton_model = BiotrainerTritonEmbedder._get_triton_model_name(
                embedder_name
            )
            if not triton_model:
                return False

            # Check if model is available in Triton
            repository = get_shared_repository(config)
            return repository.is_model_available(triton_model)
        except Exception as e:
            logger.warning(
                f"Failed to check Triton availability for {embedder_name}: {e}"
            )
            return False

    def _embed_single(self, sequence: str) -> torch.Tensor:
        embd = list(self._embed_batch([sequence]))[0]
        return embd

    def _embed_batch(self, batch: List[str]) -> Generator[torch.Tensor, None, None]:
        print(f"embedding triton {self.triton_model_name}..")
        batch_size = self.config.triton_max_batch_size
        for i in range(0, len(batch), batch_size):
            current_batch = batch[i : i + batch_size]
            print(len(current_batch))
            embeddings = self.triton_repo.compute_embeddings(
                sequences=current_batch,
                model_name=self.triton_model_name,
                pooled=False,  # Pooling is handled by embedding service separately
            )
            embeddings_torch = [torch.from_numpy(embd) for embd in embeddings]
            yield from embeddings_torch
