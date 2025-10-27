import torch
import numpy as np

from abc import ABC, abstractmethod
from biotrainer.protocols import Protocol
from typing import List, Dict, Union, Any, Literal
from biotrainer.utilities import get_device

from .prediction import Prediction
from .model_metadata import ModelMetadata

from ...model_utils import get_batched_data

# Backend type
BackendType = Literal["onnx", "triton"]


class BaseModel(ABC):
    """Base class for all prediction models.

    This class provides shared functionality for all prediction models,
    including preprocessing, postprocessing, and batching logic.
    Specific inference backends (ONNX, Triton) are provided via mixins.
    """

    def __init__(
        self,
        batch_size: int,
        backend: BackendType = "onnx",
        uses_ensemble: bool = False,
        requires_mask: bool = False,
        requires_transpose: bool = False,
        model_dir_name: str = None,
    ):
        """
        Initialize the model.

        Args:
            batch_size: Batch size for predictions
            backend: Inference backend to use ("onnx" or "triton")
            uses_ensemble: Whether the model uses multiple models (ensemble)
            requires_mask: Whether inputs need masking
            requires_transpose: Whether inputs need transposition
            model_dir_name: Optional directory name, defaults to meta_data.name if not provided
        """
        self.batch_size = batch_size
        self.backend = backend
        self.uses_ensemble = uses_ensemble
        self.requires_mask = requires_mask
        self.requires_transpose = requires_transpose
        self.non_padded_embedding_lengths = {}  # Undo padding after predictions
        self.device = get_device()
        self.model_dir_name = model_dir_name

        # Lazy initialization flag - backend initialized on first use
        self._backend_initialized = False

    def _ensure_backend_initialized(self):
        """Lazy initialization - load backend only when first needed.

        This method should be called at the start of predict() to ensure
        the backend is initialized before inference.
        """
        if not self._backend_initialized:
            self._init_backend()
            self._backend_initialized = True

    def _init_backend(self):
        """Initialize the selected inference backend."""
        if self.backend == "onnx":
            if not hasattr(self, '_init_onnx_backend'):
                raise RuntimeError(
                    f"{self.__class__.__name__} must inherit from OnnxInferenceMixin "
                    "to use ONNX backend"
                )
            self._init_onnx_backend(model_dir_name=self.model_dir_name)

        elif self.backend == "triton":
            if not hasattr(self, '_init_triton_backend'):
                raise RuntimeError(
                    f"{self.__class__.__name__} must inherit from TritonInferenceMixin "
                    "to use Triton backend"
                )
            self._init_triton_backend()

        else:
            raise ValueError(f"Unknown backend: {self.backend}. Must be 'onnx' or 'triton'")

    def _run_inference(self, batch: Dict[str, Any]) -> Any:
        """Run inference on a batch using the selected backend.

        Args:
            batch: Dictionary containing input tensors

        Returns:
            Raw model output
        """
        if self.backend == "onnx":
            return self._run_onnx_inference(batch)
        elif self.backend == "triton":
            return self._run_triton_inference(batch)
        else:
            raise ValueError(f"Unknown backend: {self.backend}")

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
            data=embeddings.values(),
            mask=self.requires_mask,
        )

    def _transpose_batch(self, batch: Dict[str, Any]) -> Dict[str, Any]:
        """
        Transpose batch dimensions if required.

        Args:
            batch: Batch data

        Returns:
            Transposed batch data
        """
        if not self.requires_transpose:
            return batch
        return {
            k: v.transpose(0, 2, 1) if k == "input" else v for k, v in batch.items()
        }

    @staticmethod
    def _finalize_raw_prediction(tensor: torch.tensor, dtype=None) -> List:
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

    @abstractmethod
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
        raise NotImplementedError

    def _post_process(
        self,
        model_output: Dict[str, Any],
        embedding_ids: List[str],
        label_maps: Dict[str, Dict[int, str]] = None,
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
        model_name = self.get_metadata().name
        protocol = self.get_metadata().protocol
        per_residue = protocol in Protocol.per_residue_protocols()

        # Check delimiter
        if delimiter and len(delimiter) > 0:
            assert 0 <= len(delimiter) <= 1, (
                "Delimiter must be exactly one or no character!"
            )
            assert per_residue, (
                "Per-sequence prediction is not compatible with a delimiter!"
            )

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
                            lambda p: label_map[p]
                            if label_map
                            else str(
                                p
                            )  # Process per-residue prediction (array of values)
                            for pred_idx, y_hat in enumerate(prediction)
                            if pred_idx
                            < self.non_padded_embedding_lengths[embedding_id]
                        ]
                    )
                else:
                    # Process per-sequence prediction (single value)
                    formatted_value = (
                        label_map[prediction] if label_map else str(prediction)
                    )

                # Create and add the prediction
                formatted_predictions[embedding_id].append(
                    Prediction(
                        model_name=model_name,
                        prediction_name=prediction_name,
                        protocol=protocol.name,
                        prediction=formatted_value,
                    )
                )

        return formatted_predictions
