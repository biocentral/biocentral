import torch
import numpy as np
import onnxruntime as ort

from abc import ABC, abstractmethod
from onnxruntime import InferenceSession
from biotrainer.protocols import Protocol
from typing import List, Dict, Union, Any
from biotrainer.utilities import get_device

from biocentral_server.server_management import FileContextManager
from .prediction import Prediction
from .model_metadata import ModelMetadata

from ...model_utils import get_batched_data, MODEL_BASE_PATH


class BaseModel(ABC):
    """Base class for all prediction models."""

    def __init__(self, batch_size: int,
                 uses_ensemble: bool = False,
                 requires_mask: bool = False,
                 requires_transpose: bool = False,
                 model_dir_name: str = None, ):
        """
        Initialize the model.

        Args:
            batch_size: Batch size for predictions
            uses_ensemble: Whether the model uses multiple models (ensemble)
            requires_mask: Whether inputs need masking
            requires_transpose: Whether inputs need transposition
            model_dir_name: Optional directory name, defaults to meta_data.name if not provided
        """
        self.batch_size = batch_size
        self.requires_mask = requires_mask
        self.requires_transpose = requires_transpose
        self.non_padded_embedding_lengths = {}  # Undo padding after predictions
        self.device = get_device()

        # Load model(s)
        model_name = model_dir_name if model_dir_name else self.get_metadata().name
        if uses_ensemble:
            self.models = self._load_multiple_onnx_models(model_name=model_name)
        else:
            self.model = self._load_onnx_model(model_name=model_name)

    @staticmethod
    def _load_onnx_model(model_name: str) -> InferenceSession:
        file_context_manager = FileContextManager()
        model_dir = f"{MODEL_BASE_PATH}/{model_name.lower()}"

        with file_context_manager.storage_dir_read(dir_path=model_dir) as onnx_path:
            for onnx_file in onnx_path.iterdir():
                try:
                    onnx_model = ort.InferenceSession(onnx_file)
                    return onnx_model
                except Exception:
                    raise Exception(f"Model {onnx_file} could not be loaded!")

        raise Exception(f"Model could not be found in model directory {model_dir}!")

    @staticmethod
    def _load_multiple_onnx_models(model_name: str) -> List[InferenceSession]:
        file_context_manager = FileContextManager()
        model_dir = f"{MODEL_BASE_PATH}/{model_name.lower()}"
        models = []
        with file_context_manager.storage_dir_read(dir_path=model_dir) as onnx_path:
            for onnx_file in onnx_path.iterdir():
                try:
                    onnx_model = ort.InferenceSession(onnx_file)
                    models.append((onnx_file.name, onnx_model))
                except Exception:
                    raise Exception(f"Model {onnx_file} could not be loaded!")

        if len(models) == 0:
            raise Exception(f"Model {model_name} could not be loaded!")

        # TODO [Refactoring] Sorting for cv_index does not work with temp files
        models = [model[1] for model in sorted(models, key=lambda x: x[0])]
        return models

    @staticmethod
    @abstractmethod
    def get_metadata() -> ModelMetadata:
        """Return model metadata."""
        raise NotImplementedError

    def _prepare_inputs(self, embeddings: Dict[str, torch.Tensor]) -> Union[
        List[Dict[str, np.ndarray]], List[Dict[str, torch.Tensor]]]:
        """
        Prepare inputs for the model.

        Args:
            embeddings: Dictionary mapping sequence IDs to embeddings

        Returns:
            Batched inputs ready for model prediction
        """
        # Store original sequence lengths
        self.non_padded_embedding_lengths = {idx: embedding.shape[0] for idx, embedding in embeddings.items()}

        # Get batched data with attention masks if required
        return get_batched_data(batch_size=self.batch_size, data=embeddings.values(), mask=self.requires_mask)

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
        return {k: v.transpose(0, 2, 1) if k == "input" else v for k, v in batch.items()}

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
    def predict(self, sequences: Dict[str, str], embeddings: Dict[str, torch.Tensor]) -> Dict[str, List[Prediction]]:
        """
        Run model prediction.

        Args:
            sequences: Dictionary mapping sequence IDs to amino acid sequences
            embeddings: Dictionary mapping sequence IDs to embeddings

        Returns:
            Model predictions
        """
        raise NotImplementedError

    def _post_process(self, model_output: Dict[str, Any], embedding_ids: List[str],
                      label_maps: Dict[str, Dict[int, str]] = None,
                      delimiter: str = "") -> Dict[str, List[Prediction]]:
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
            assert 0 <= len(delimiter) <= 1, "Delimiter must be exactly one or no character!"
            assert per_residue, "Per-sequence prediction is not compatible with a delimiter!"

        for prediction_name, outputs in model_output.items():
            label_map = label_maps.get(prediction_name, {}) if label_maps else None

            for embd_idx, prediction in enumerate(outputs):
                embedding_id = embedding_ids[embd_idx]

                if embedding_id not in formatted_predictions:
                    formatted_predictions[embedding_id] = []

                if per_residue:
                    # Process per-residue prediction (array of values)
                    transform_fn = lambda p: label_map[p] if label_map else str(p)

                    # Undo padding and join with delimiter
                    formatted_value = delimiter.join([
                        transform_fn(y_hat)
                        for pred_idx, y_hat in enumerate(prediction)
                        if pred_idx < self.non_padded_embedding_lengths[embedding_id]
                    ])
                else:
                    # Process per-sequence prediction (single value)
                    formatted_value = label_map[prediction] if label_map else str(prediction)

                # Create and add the prediction
                formatted_predictions[embedding_id].append(Prediction(
                    model_name=model_name,
                    prediction_name=prediction_name,
                    protocol=protocol,
                    prediction=formatted_value
                ))

        return formatted_predictions
