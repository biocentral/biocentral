"""Triton-based prediction adapter for protein property prediction.

This module provides a Triton-backed implementation of the prediction interface,
allowing predictions to be computed via Triton Inference Server instead of local ONNX.
"""

import asyncio
from typing import Dict, List
import torch
import numpy as np

from biotrainer.protocols import Protocol

from ..utils import get_logger
from ..server_management import (
    TritonClientConfig,
    TritonModelRouter,
    create_triton_repository,
)
from .models.base_model import BaseModel, Prediction, ModelMetadata

logger = get_logger(__name__)


class TritonPredictor(BaseModel):
    """Triton-based predictor that delegates inference to Triton Inference Server.

    This class provides the same interface as BaseModel but uses Triton for inference
    instead of local ONNX models. It maintains compatibility with existing prediction
    workflows while leveraging Triton's optimizations.
    """

    def __init__(
        self,
        batch_size: int,
        triton_model_name: str,
        metadata: ModelMetadata,
        label_maps: Dict[str, Dict[int, str]] = None,
        delimiter: str = "",
    ):
        """Initialize Triton predictor.

        Args:
            batch_size: Batch size for predictions
            triton_model_name: Name of the model in Triton repository
            metadata: Model metadata
            label_maps: Mapping from prediction_name to label mappings
            delimiter: Delimiter for per-residue predictions
        """
        # Skip BaseModel __init__ since we don't load ONNX models
        self.batch_size = batch_size
        self.triton_model_name = triton_model_name
        self._metadata = metadata
        self.label_maps = label_maps or {}
        self.delimiter = delimiter
        self.non_padded_embedding_lengths = {}

        # Triton configuration
        self.config = TritonClientConfig.from_env()
        self.triton_repo = None

    @staticmethod
    def get_metadata() -> ModelMetadata:
        """Return model metadata.

        Note: This is overridden in instance to return the metadata passed to __init__
        """
        raise NotImplementedError("Use instance metadata instead")

    def get_instance_metadata(self) -> ModelMetadata:
        """Get the metadata for this instance."""
        return self._metadata

    async def _connect_triton(self):
        """Connect to Triton server."""
        if self.triton_repo is None:
            self.triton_repo = create_triton_repository(self.config)
            await self.triton_repo.connect()

    async def _disconnect_triton(self):
        """Disconnect from Triton server."""
        if self.triton_repo is not None:
            await self.triton_repo.disconnect()
            self.triton_repo = None

    async def _predict_async(
        self, sequences: Dict[str, str], embeddings: Dict[str, torch.Tensor]
    ) -> Dict[str, List[Prediction]]:
        """Async prediction via Triton.

        Args:
            sequences: Dictionary mapping sequence hashes to amino acid sequences
            embeddings: Dictionary mapping sequence hashes to embeddings

        Returns:
            Model predictions
        """
        # Store sequence lengths for undoing padding
        self.non_padded_embedding_lengths = {
            seq_id: embedding.shape[0] for seq_id, embedding in embeddings.items()
        }

        # Connect to Triton
        await self._connect_triton()

        try:
            # Convert embeddings to numpy and prepare for batching
            embedding_ids = list(embeddings.keys())
            embedding_arrays = [
                embeddings[seq_id].cpu().numpy() for seq_id in embedding_ids
            ]

            # Process in batches
            all_predictions = {}
            for i in range(0, len(embedding_arrays), self.batch_size):
                batch_embeddings = embedding_arrays[i : i + self.batch_size]
                batch_ids = embedding_ids[i : i + self.batch_size]

                # Pad embeddings to same length for batching
                max_len = max(emb.shape[0] for emb in batch_embeddings)
                embed_dim = batch_embeddings[0].shape[1]

                padded_batch = np.zeros(
                    (len(batch_embeddings), max_len, embed_dim), dtype=np.float32
                )
                for j, emb in enumerate(batch_embeddings):
                    padded_batch[j, : emb.shape[0], :] = emb

                # Call Triton
                try:
                    predictions = await self.triton_repo.compute_predictions(
                        embeddings=padded_batch,
                        model_name=self.triton_model_name,
                    )

                    # Post-process predictions
                    batch_predictions = self._post_process_batch(
                        predictions=predictions,
                        embedding_ids=batch_ids,
                    )
                    all_predictions.update(batch_predictions)

                except Exception as e:
                    logger.error(
                        f"Triton prediction failed for batch {i//self.batch_size}: {e}"
                    )
                    raise

            return all_predictions

        finally:
            await self._disconnect_triton()

    def predict(
        self, sequences: Dict[str, str], embeddings: Dict[str, torch.Tensor]
    ) -> Dict[str, List[Prediction]]:
        """Run model prediction via Triton.

        Args:
            sequences: Dictionary mapping sequence hashes to amino acid sequences
            embeddings: Dictionary mapping sequence hashes to embeddings

        Returns:
            Model predictions
        """
        # Run async prediction in event loop
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            return loop.run_until_complete(
                self._predict_async(sequences, embeddings)
            )
        finally:
            loop.close()

    def _post_process_batch(
        self,
        predictions: np.ndarray,
        embedding_ids: List[str],
    ) -> Dict[str, List[Prediction]]:
        """Post-process Triton predictions into Prediction objects.

        Args:
            predictions: Raw predictions from Triton
            embedding_ids: List of sequence IDs

        Returns:
            Formatted predictions
        """
        formatted_predictions = {}
        model_name = self._metadata.name
        protocol = self._metadata.protocol
        per_residue = protocol in Protocol.per_residue_protocols()

        # Handle different prediction shapes
        if len(predictions.shape) == 3:
            # Per-residue predictions: (batch, seq_len, n_classes)
            for batch_idx, embedding_id in enumerate(embedding_ids):
                if embedding_id not in formatted_predictions:
                    formatted_predictions[embedding_id] = []

                seq_predictions = predictions[batch_idx]
                seq_len = self.non_padded_embedding_lengths[embedding_id]

                # Get predictions for this sequence (undo padding)
                seq_predictions = seq_predictions[:seq_len]

                # Convert to class predictions
                if seq_predictions.shape[1] > 1:
                    # Multi-class: take argmax
                    class_predictions = np.argmax(seq_predictions, axis=1)
                else:
                    # Binary: threshold at 0.5
                    class_predictions = (seq_predictions[:, 0] > 0.5).astype(int)

                # Map to labels if available
                prediction_name = list(self._metadata.outputs.keys())[0]
                label_map = self.label_maps.get(prediction_name, {})

                if per_residue:
                    # Join per-residue predictions with delimiter
                    formatted_value = self.delimiter.join(
                        [
                            label_map.get(int(pred), str(pred))
                            for pred in class_predictions
                        ]
                    )
                else:
                    # Single prediction (shouldn't happen with 3D output)
                    formatted_value = label_map.get(
                        int(class_predictions[0]), str(class_predictions[0])
                    )

                formatted_predictions[embedding_id].append(
                    Prediction(
                        model_name=model_name,
                        prediction_name=prediction_name,
                        protocol=protocol.name,
                        prediction=formatted_value,
                    )
                )

        elif len(predictions.shape) == 2:
            # Sequence-level predictions: (batch, n_classes)
            for batch_idx, embedding_id in enumerate(embedding_ids):
                if embedding_id not in formatted_predictions:
                    formatted_predictions[embedding_id] = []

                seq_prediction = predictions[batch_idx]

                # Convert to class prediction
                if seq_prediction.shape[0] > 1:
                    class_prediction = np.argmax(seq_prediction)
                else:
                    class_prediction = int(seq_prediction[0] > 0.5)

                # Map to label
                prediction_name = list(self._metadata.outputs.keys())[0]
                label_map = self.label_maps.get(prediction_name, {})
                formatted_value = label_map.get(class_prediction, str(class_prediction))

                formatted_predictions[embedding_id].append(
                    Prediction(
                        model_name=model_name,
                        prediction_name=prediction_name,
                        protocol=protocol.name,
                        prediction=formatted_value,
                    )
                )

        return formatted_predictions


def create_triton_predictor(
    model_name: str,
    batch_size: int = 16,
) -> TritonPredictor:
    """Factory function to create a Triton predictor for a given model.

    Args:
        model_name: Biocentral model name (e.g., "secondary_structure")
        batch_size: Batch size for predictions

    Returns:
        TritonPredictor instance

    Raises:
        ValueError: If no Triton model is available for the given model name
    """
    # Get Triton model name
    triton_model = TritonModelRouter.get_prediction_model(model_name)
    if not triton_model:
        raise ValueError(f"No Triton model available for {model_name}")

    # Import the corresponding model class to get metadata
    # This is a bit hacky but avoids duplicating metadata definitions
    model_classes = {
        "secondary_structure": "biocentral_server.predict.models.secondary_structure.prott5_secstruct.ProtT5SecondaryStructure",
        "conservation": "biocentral_server.predict.models.conservation.prott5_conservation.ProtT5Conservation",
        "binding_sites": "biocentral_server.predict.models.binding.bind_embed.BindEmbed",
        "disorder": "biocentral_server.predict.models.disorder.seth.Seth",
        "membrane_localization": "biocentral_server.predict.models.membrane.tmbed.TMbed",
        "subcellular_localization": "biocentral_server.predict.models.localization.light_attention_subcell.LightAttentionSubcell",
    }

    # Get model class and metadata
    model_class_path = model_classes.get(model_name)
    if not model_class_path:
        raise ValueError(f"Unknown model: {model_name}")

    # Dynamically import the model class
    module_path, class_name = model_class_path.rsplit(".", 1)
    import importlib

    module = importlib.import_module(module_path)
    model_class = getattr(module, class_name)

    # Get metadata
    metadata = model_class.get_metadata()

    # TODO: Extract label maps from model class if needed
    label_maps = {}

    return TritonPredictor(
        batch_size=batch_size,
        triton_model_name=triton_model,
        metadata=metadata,
        label_maps=label_maps,
    )
