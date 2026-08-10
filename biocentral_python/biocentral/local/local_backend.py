from __future__ import annotations

from pathlib import Path
from typing import Dict, Any, List, Optional

from platformdirs import user_cache_dir

from biocentral_api import (
    BiotrainerModelResult,
    BiotrainerInferenceResult,
    Prediction,
    SequenceData,
    ProjectionResult,
)
from biocentral_api.clients import EmbeddingsResult

from ..base import NotAvailableError


def _get_cache_dir() -> Path:
    cache_dir = Path(user_cache_dir("biocentral"))
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir


def _get_models_dir() -> Path:
    models_dir = _get_cache_dir() / "models"
    models_dir.mkdir(parents=True, exist_ok=True)
    return models_dir


def _get_embeddings_dir() -> Path:
    embed_dir = _get_cache_dir() / "embeddings"
    embed_dir.mkdir(parents=True, exist_ok=True)
    return embed_dir


def _get_model_dir(model_hash: str) -> Path:
    model_dir = _get_models_dir() / model_hash
    model_dir.mkdir(parents=True, exist_ok=True)
    return model_dir


class LocalBackend:
    """Backend that executes operations locally using biotrainer.

    Requires: pip install biocentral[local]
    """

    def __init__(self, device: Optional[str] = None):
        try:
            import torch
            from biotrainer.training import BiotrainerModel
            from biotrainer.embedding import EmbeddingService
        except ImportError:
            raise ImportError(
                "Local mode requires biotrainer. Install with: pip install biocentral[local]"
            )
        self._device = device

    def embed(
        self,
        embedder_name: str,
        sequence_data: Dict[str, str],
        reduce: bool = True,
        use_half_precision: bool = False,
    ) -> EmbeddingsResult:
        from biotrainer.embedding import EmbeddingAPI
        from biotrainer_core.data_classes import Protocol
        from biocentral_api.utils import calculate_sequence_hash

        embd_api = EmbeddingAPI(
            embedder_name=embedder_name,
            custom_tokenizer_config=None,
            use_half_precision=use_half_precision,
            device=self._device,
            finetuning_config=None,
        )
        protocol = (
            Protocol.using_per_sequence_embeddings()[0]
            if reduce
            else Protocol.using_per_residue_embeddings()[0]
        )
        hash2id: Dict[str, str] = {
            calculate_sequence_hash(seq): seq_id
            for seq_id, seq in sequence_data.items()
        }
        embeddings_file = embd_api.compute_embeddings(
            input_data=sequence_data,
            protocol=protocol,
            output_dir=_get_embeddings_dir(),
        )

        return EmbeddingsResult(hash2id=hash2id, embeddings_file_str=embeddings_file)

    def train(
        self, config: Dict[str, Any], training_data: List[SequenceData]
    ) -> BiotrainerModelResult:
        from biotrainer.training import BiotrainerModel

        # Add output_dir to config if not set
        output_dir = (
            _get_models_dir()
        )  # Automatically creates model_hash directory in biotrainer
        config_copy = dict(config)
        config_copy["output_dir"] = str(output_dir)

        # Add device if not set
        if self._device is not None and "device" not in config_copy:
            config_copy["device"] = str(self._device)

        model = BiotrainerModel()
        result = model.train(config=config_copy, input_data=training_data)

        return result

    def inference(
        self, model_hash: str, inference_data: Dict[str, str]
    ) -> BiotrainerInferenceResult:
        from biotrainer.training import BiotrainerModel
        from biocentral_api import SequenceData

        model_dir = _get_model_dir(model_hash)
        out_file = model_dir / "out.yml"

        if not out_file.exists():
            raise FileNotFoundError(
                f"No cached model found for hash '{model_hash}'. "
                f"Expected output file at: {out_file}. "
                f"Train a model first or check the model hash."
            )

        model = BiotrainerModel.from_training_result(out_file)
        model_input = [
            SequenceData(seq_id=seq_id, seq=seq)
            for seq_id, seq in inference_data.items()
        ]
        return model.predict(model_input=model_input)

    def project(
        self,
        embedder_name: str,
        method: str,
        sequence_data: Dict[str, str],
        projection_config: Dict[str, str],
    ) -> ProjectionResult:
        raise NotAvailableError(
            "Projection is only available in API mode. "
            "Use Biocentral(mode='api') to access this feature."
        )

    def predict(
        self, model_names: List[str], sequence_data: Dict[str, str]
    ) -> Dict[str, List[Prediction]]:
        raise NotAvailableError(
            "Prediction from pre-trained server-hosted models is only available in API mode. "
            "Use Biocentral(mode='api') to access this feature."
        )
