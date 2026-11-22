import onnxruntime as ort
from typing import List, Dict, Any, Optional
from onnxruntime import InferenceSession

from .model_metadata import ModelMetadata

from ...model_utils import MODEL_REPOSITORY_PATH


class LocalOnnxBackend:
    """Backend providing ONNX-based inference capabilities.

    This class provides methods for loading and running ONNX models locally.
    It should be used with BaseModel through multiple inheritance.

    Expected attributes from BaseModel:
        - uses_ensemble: bool
    """

    def __init__(self,
                 uses_ensemble: bool,
                 metadata: ModelMetadata):
        self.uses_ensemble = uses_ensemble
        self.metadata = metadata

    def _init_onnx_backend(self):
        """Initialize ONNX backend by loading model(s)."""
        model_name_for_dir = self.metadata.name.to_onnx_dir_name()

        if self.uses_ensemble:
            self.models = self._load_multiple_onnx_models(
                model_name_for_dir=model_name_for_dir
            )
        else:
            self.model = self._load_onnx_model(model_name_for_dir=model_name_for_dir)

    @staticmethod
    def _load_onnx_model(model_name_for_dir: str) -> InferenceSession:
        """Load a single ONNX model from storage.

        Args:
            model_name_for_dir: Name of the model directory

        Returns:
            Loaded ONNX inference session

        Raises:
            Exception: If model cannot be loaded
        """
        model_repo_path = MODEL_REPOSITORY_PATH
        for directory in model_repo_path.iterdir():
            if directory.is_file():
                continue

            if model_name_for_dir in directory.name.lower():
                onnx_file = directory / "1" / "model.onnx"
                if onnx_file.exists() and onnx_file.is_file():
                    try:
                        onnx_model = ort.InferenceSession(onnx_file)
                        return onnx_model
                    except Exception:
                        raise Exception(f"Model {onnx_file} could not be loaded!")

        raise Exception(
            f"Model {model_name_for_dir} could not be found in model directory {model_repo_path}!"
        )

    @staticmethod
    def _load_multiple_onnx_models(model_name_for_dir: str) -> List[InferenceSession]:
        """Load multiple ONNX models for ensemble inference.

        Args:
            model_name_for_dir: Name of the model directory

        Returns:
            List of loaded ONNX inference sessions

        Raises:
            Exception: If models cannot be loaded
        """
        model_repo_path = MODEL_REPOSITORY_PATH
        models = []

        for directory in model_repo_path.iterdir():
            if directory.is_file():
                continue

            if (
                model_name_for_dir in directory.name.lower()
                and "_cv" in directory.name.lower()
            ):
                onnx_file = directory / "1" / "model.onnx"
                if onnx_file.exists() and onnx_file.is_file():
                    try:
                        onnx_model = ort.InferenceSession(onnx_file)
                        model_cv = int(directory.name.split("_cv")[-1])
                        models.append((model_cv, onnx_model))
                    except Exception:
                        raise Exception(f"Model {onnx_file} could not be loaded!")

        if len(models) == 0:
            raise Exception(f"Model {model_name_for_dir} could not be loaded!")

        models = [model[1] for model in sorted(models, key=lambda x: x[0])]
        return models

    def infer_input_name(self) -> str:
        model = getattr(self, "model", None) or self.models[0]
        return model.get_inputs()[0].name

    def run_onnx_inference_single(self, batch: Dict[str, Any],
                                  output_names: Optional[List[str]] = None) -> Any:
        """Run ONNX inference on a batch.

        For non-ensemble models, returns the single model's output list.

        Args:
            batch: Dictionary containing input tensors
            output_names: Optional list of output names to return

        Returns:
            Raw model output
        """
        assert not self.uses_ensemble
        return self.model.run(output_names, batch)

    def run_onnx_inference_ensemble(self, batch: Dict[str, Any],
                                    output_names: Optional[List[str]] = None) -> list[Any]:
        """Run an ensemble of ONNX model inference on a batch.

        For ensemble models, returns a list of outputs (one per model).

        Args:
            batch: Dictionary containing input tensors
            output_names: Optional list of output names to return

        Returns:
            Raw model output list
        """
        assert self.uses_ensemble
        # Return all model outputs for ensemble handling by specific model
        return [model.run(output_names, batch) for model in self.models]
