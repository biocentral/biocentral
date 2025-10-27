"""ONNX inference mixin for local model execution."""

import onnxruntime as ort
from onnxruntime import InferenceSession
from typing import List, Dict, Any
import numpy as np

from biocentral_server.server_management import FileContextManager
from ....model_utils import MODEL_BASE_PATH


class OnnxInferenceMixin:
    """Mixin providing ONNX-based inference capabilities.

    This mixin provides methods for loading and running ONNX models locally.
    It should be used with BaseModel through multiple inheritance.

    Expected attributes from BaseModel:
        - uses_ensemble: bool
        - model_dir_name: Optional[str]
    """

    def _init_onnx_backend(self, model_dir_name: str = None):
        """Initialize ONNX backend by loading model(s).

        Args:
            model_dir_name: Optional directory name, defaults to metadata name
        """
        if not hasattr(self, 'uses_ensemble'):
            raise AttributeError("OnnxInferenceMixin requires 'uses_ensemble' attribute")

        model_name = model_dir_name if model_dir_name else self.get_metadata().name

        if self.uses_ensemble:
            self.models = self._load_multiple_onnx_models(model_name=model_name)
        else:
            self.model = self._load_onnx_model(model_name=model_name)

    @staticmethod
    def _load_onnx_model(model_name: str) -> InferenceSession:
        """Load a single ONNX model from storage.

        Args:
            model_name: Name of the model directory

        Returns:
            Loaded ONNX inference session

        Raises:
            Exception: If model cannot be loaded
        """
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
        """Load multiple ONNX models for ensemble inference.

        Args:
            model_name: Name of the model directory

        Returns:
            List of loaded ONNX inference sessions

        Raises:
            Exception: If models cannot be loaded
        """
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

    def _run_onnx_inference(self, batch: Dict[str, Any]) -> Any:
        """Run ONNX inference on a batch.

        Args:
            batch: Dictionary containing input tensors

        Returns:
            Raw model output
        """
        if self.uses_ensemble:
            # Return all model outputs for ensemble handling by specific model
            return [model.run(None, batch) for model in self.models]
        else:
            return self.model.run(None, batch)
