import torch
import numpy as np

from typing import Dict, List
from biotrainer.protocols import Protocol
from scipy.ndimage import gaussian_filter1d

from ..base_model import (
    BaseModel,
    ModelMetadata,
    ModelOutput,
    OutputType,
    LocalOnnxInferenceMixin,
    TritonInferenceMixin,
)
from ..biocentral_prediction_model import BiocentralPredictionModel


class UdonPred(BaseModel, LocalOnnxInferenceMixin, TritonInferenceMixin):
    """UdonPred model for predicting protein disorder.

    Supports both ONNX (local) and Triton (remote) backends.
    """

    # Triton configuration
    @staticmethod
    def TRITON_MODEL_NAME() -> str:
        """Name of model in Triton repository."""
        return "udonpred"

    @staticmethod
    def TRITON_INPUT_NAMES() -> List[str]:
        """Names of input tensors."""
        return ["embedding"]

    @staticmethod
    def TRITON_OUTPUT_NAMES() -> List[str]:
        """Names of output tensors."""
        return ["score"]

    def __init__(self, batch_size: int, backend: str = "onnx"):
        super().__init__(
            batch_size=batch_size,
            backend=backend,
            uses_ensemble=False,
            requires_mask=False,
            requires_transpose=False,
        )

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name=BiocentralPredictionModel.UdonPred,
            protocol=Protocol.residue_to_value,
            description="UdonPred: Untangling Protein Intrinsic Disorder Prediction",
            authors="Julius Schlensok, David Wagemann, Tobias Senoner, Markus Haak, Burkhard Rost",
            model_link="https://github.com/DavidWagemann/UdonPred",
            citation="https://doi.org/10.64898/2026.01.26.701679",
            licence="GPL-3.0",
            outputs=[
                ModelOutput(
                    name="disorder_trizod",
                    # TODO Improve description
                    description="Disorder scores (TriZOD)",
                    output_type=OutputType.PER_RESIDUE,
                    value_type="float",
                )
            ],
            model_size="1.1 MB",
            training_data_link="https://figshare.com/articles/dataset/UdonPred/31444642",
            embedder="Rostlab/ProstT5",
        )

    def _trim_and_smooth_predictions(
        self,
        results: List[List[float]],
        embedding_ids: List[str],
        smooth: float,
    ) -> List[List[float]]:
        """Trims padded sequence to original length and applys smoothing (UdonPred behaviour)"""
        processed_results = []

        for embedding_id, sequence_scores in zip(embedding_ids, results):
            original_length = self.non_padded_embedding_lengths[embedding_id]
            scores_seq = np.asarray(sequence_scores, dtype=np.float64)[:original_length]

            if smooth > 0:
                scores_seq = gaussian_filter1d(
                    scores_seq,
                    sigma=smooth,
                    axis=0,
                )

            processed_results.append(scores_seq.tolist())

        return processed_results

    def predict(self, sequences: Dict[str, str], embeddings):
        # Fixed constant from UdonPred
        # https://github.com/DavidWagemann/UdonPred/blob/80c5f0abd0debead4659a7b1d45d2cec65f5fb18/predict.py#L218
        smooth = 1.5

        self._ensure_backend_initialized()
        inputs = self._prepare_inputs(
            embeddings=embeddings
        )  # TODO Batch size seems to be always one
        embedding_ids = list(embeddings.keys())
        results = []  # list of floats with disorder scores for each residue

        for batch in inputs:
            # Run inference using selected backend
            raw_output = self._run_inference(batch)

            # Process output based on backend
            if self.backend == "onnx":
                # ONNX returns list of outputs, take first one
                diso_Yhat = self._finalize_raw_prediction(
                    torch.from_numpy(np.float32(np.stack(raw_output[0])))
                )
            elif self.backend == "triton":
                # Triton returns numpy array directly (already processed by mixin)
                # Shape should be (batch, seq_len, 1) - squeeze to (batch, seq_len)
                if len(raw_output.shape) == 3 and raw_output.shape[-1] == 1:
                    raw_output = np.squeeze(raw_output, axis=-1)
                # Convert to tensor and process per sequence to preserve per-residue structure
                tensor = torch.from_numpy(raw_output)
                diso_Yhat = []
                for i in range(tensor.shape[0]):  # iterates over batch (sequences)
                    seq_tensor = tensor[i]
                    seq_result = self._finalize_raw_prediction(seq_tensor.unsqueeze(0))
                    diso_Yhat.extend(seq_result)
            else:
                raise ValueError(f"Unknown backend: {self.backend}")

            results.extend(diso_Yhat)

        processed_results = self._trim_and_smooth_predictions(
            results, embedding_ids, smooth
        )

        model_output = {"disorder_trizod": processed_results}
        return self._post_process(
            model_output=model_output, embedding_ids=embedding_ids, delimiter=","
        )
