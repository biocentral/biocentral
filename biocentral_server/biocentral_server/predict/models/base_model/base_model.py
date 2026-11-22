import torch
import numpy as np

from abc import ABC, abstractmethod
from biotrainer_core.data_classes import Protocol
from typing import List, Dict, Union, Any, Iterable, Optional

from .backend_onnx import LocalOnnxBackend
from .model_metadata import ModelMetadata

from ...model_utils import get_batched_data

from ....server_management import Prediction


class BaseModel(ABC):
    """Base class for all prediction models.

    This class provides shared functionality for all prediction models,
    including preprocessing, postprocessing, and batching logic.
    Uses ONNX Runtime for local inference.
    """

    def __init__(
        self,
        batch_size: int,
        uses_ensemble: bool = False,
        requires_mask: bool = False,
        requires_transpose: bool = False,
    ):
        """
        Initialize the model.

        Args:
            batch_size: Batch size for predictions
            uses_ensemble: Whether the model uses multiple models (ensemble)
            requires_mask: Whether inputs need masking
            requires_transpose: Whether inputs need transposition
        """
        self.batch_size = batch_size
        self.uses_ensemble = uses_ensemble
        self.requires_mask = requires_mask
        self.requires_transpose = requires_transpose
        self.non_padded_embedding_lengths = {}  # Undo padding after predictions

        # Only one backend available at the moment (ONNX local)
        self._backend = LocalOnnxBackend(uses_ensemble=uses_ensemble,
                                        metadata=self.get_metadata())
        self._backend_initialized = False

    def __ensure_backend_initialized(self):
        """Lazy initialization - load backend only when first needed.

        This method should be called at the start of predict() to ensure
        the backend is initialized before inference.
        """
        if not self._backend_initialized:
            # Needs to be made generic of other backends come available again
            self._backend._init_onnx_backend()
            self._backend_initialized = True

    @property
    def model(self):
        """Delegate to backend's single ONNX model instance."""
        return self._backend.model

    @property
    def models(self):
        """Delegate to backend's ensemble ONNX model instances."""
        return self._backend.models

    # ** Inference backend calls. Two different functions for single / ensemble for better typing **
    def _run_backend_inference_single(self, batch: Dict[str, Any],
                                      output_names: Optional[List[str]] = None) -> Any:
        return self._backend.run_onnx_inference_single(batch=batch, output_names=output_names)

    def _run_backend_inference_ensemble(self, batch: Dict[str, Any],
                                        output_names: Optional[List[str]] = None) -> list[Any]:
        return self._backend.run_onnx_inference_ensemble(batch=batch, output_names=output_names)

    @staticmethod
    @abstractmethod
    def get_metadata() -> ModelMetadata:
        """Return model metadata."""
        raise NotImplementedError

    def _prepare_inputs(
        self, embeddings: Dict[str, torch.Tensor]
    ) -> Union[List[Dict[str, np.ndarray]], List[Dict[str, torch.Tensor]]]:
        """
        Prepare inputs for the model.

        Args:
            embeddings: Dictionary mapping sequence IDs to embeddings

        Returns:
            Batched inputs ready for model prediction
        """
        # Store original sequence lengths
        self.non_padded_embedding_lengths = {
            idx: embedding.shape[0] for idx, embedding in embeddings.items()
        }

        # Get batched data with attention masks if required
        return get_batched_data(
            batch_size=self.batch_size,
            protocol=self.get_metadata().protocol,
            input_name=self._infer_input_name(),
            data=embeddings.values(),
            mask=self.requires_mask,
        )

    def _infer_input_name(self) -> str:
        return self._backend.infer_input_name()

    def _transpose_batch(self, batch: Dict[str, Any]) -> Dict[str, Any]:
        """
        Transpose batch dimensions if required.

        Transposes 'input' tensor from (B, L, E) to (B, E, L).
        Always converts to PyTorch tensor and uses permute.

        Args:
            batch: Batch data

        Returns:
            Transposed batch data
        """
        if not self.requires_transpose:
            return batch

        result = {}
        input_name = self._infer_input_name()
        for k, v in batch.items():
            if k == input_name:
                if isinstance(v, np.ndarray):
                    v = torch.from_numpy(v)
                elif isinstance(v, Iterable):
                    v = torch.tensor(v)
                else:
                    raise ValueError(f"Unsupported type: {type(v)}")
                transposed = v.permute(0, 2, 1)
                # Convert back to numpy for ONNX compatibility
                result[k] = transposed.numpy()
            else:
                result[k] = v
        return result

    @staticmethod
    def _format_prediction_value(value: Any) -> str:
        """
        Format prediction value to string with max 3 significant digits for floats.

        Args:
            value: The prediction value to format

        Returns:
            Formatted string representation
        """
        if isinstance(value, int):
            return str(value)
        if isinstance(value, float):
            return f"{value:.3g}"
        return str(value)

    @staticmethod
    def _finalize_raw_prediction(tensor: torch.Tensor, dtype=None) -> List:
        """
        Do conversions on the raw onnx model predictions to finalize the model output.

        This includes detach, to cpu, squeezing, numpy, to dtype if provided

        Args:
            tensor: PyTorch tensor to convert
            dtype: Optional numpy dtype to convert the array to (e.g., np.byte)

        Returns:
            Python list on CPU with optional dtype conversion
        """
        result = tensor.detach().cpu()
        if len(tensor.shape) > 1:
            result = result.squeeze(dim=-1)

        result = result.numpy()

        # Convert to specified dtype if provided
        if dtype is not None:
            result = result.astype(dtype)

        return list(result)

    def predict(
        self, sequences: Dict[str, str], embeddings: Dict[str, torch.Tensor]
    ) -> Dict[str, List[Prediction]]:
        """
        Run model prediction.

        Args:
            sequences: Dictionary mapping sequence hashes to amino acid sequences
            embeddings: Dictionary mapping sequence hashes to embeddings

        Returns:
            Model predictions
        """
        self.__ensure_backend_initialized()
        return self._predict_implementation(sequences, embeddings)

    @abstractmethod
    def _predict_implementation(
        self, sequences: Dict[str, str], embeddings: Dict[str, torch.Tensor]
    ) -> Dict[str, List[Prediction]]:
        """
        Run model-specific prediction implementation. Must be overridden by subclasses.

        Args:
            sequences: Dictionary mapping sequence hashes to amino acid sequences
            embeddings: Dictionary mapping sequence hashes to embeddings

        Returns:
            Model predictions
        """
        raise NotImplementedError

    def _post_process(
        self,
        model_output: Dict[str, Any],
        embedding_ids: List[str],
        label_maps: Optional[Dict[str, Dict[int, str]]] = None,
        delimiter: str = "",
    ) -> Dict[str, List[Prediction]]:
        """
        Unified implementation for post-processing model output for both per-residue and per-sequence predictions.

        Args:
            model_output: Raw model output as mapping from prediction_name to output.
            embedding_ids: List of sequence IDs
            label_maps: Mapping from prediction_name to mapping of prediction indices to string labels
            delimiter: Delimiter to separate per-residue predictions (default: "")

        Returns:
            Formatted model predictions
        """
        formatted_predictions = {}
        model_name = self.get_metadata().name.name
        protocol = self.get_metadata().protocol
        per_residue = protocol in Protocol.per_residue_protocols()

        # Check delimiter
        if delimiter and len(delimiter) > 0:
            assert (
                0 <= len(delimiter) <= 1
            ), "Delimiter must be exactly one or no character!"
            assert (
                per_residue
            ), "Per-sequence prediction is not compatible with a delimiter!"

        for prediction_name, outputs in model_output.items():
            label_map = label_maps.get(prediction_name, {}) if label_maps else None

            for embd_idx, prediction in enumerate(outputs):
                embedding_id = embedding_ids[embd_idx]

                if embedding_id not in formatted_predictions:
                    formatted_predictions[embedding_id] = []

                if per_residue:
                    # Undo padding and join with delimiter
                    formatted_value = delimiter.join(
                        [
                            (
                                label_map[y_hat]
                                if label_map
                                else self._format_prediction_value(y_hat)
                            )
                            for pred_idx, y_hat in enumerate(prediction)
                            if pred_idx
                            < self.non_padded_embedding_lengths[embedding_id]
                        ]
                    )
                else:
                    # Process per-sequence prediction (single value)
                    formatted_value = (
                        label_map[prediction]
                        if label_map
                        else self._format_prediction_value(prediction)
                    )

                # Create and add the prediction
                formatted_predictions[embedding_id].append(
                    Prediction(
                        model_name=model_name,
                        prediction_name=prediction_name,
                        protocol=protocol.name,
                        value=formatted_value,
                    )
                )

        return formatted_predictions
