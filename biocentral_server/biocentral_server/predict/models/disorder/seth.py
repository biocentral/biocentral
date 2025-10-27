import torch
import numpy as np

from typing import Dict
from biotrainer.protocols import Protocol

from ..base_model import (
    BaseModel,
    ModelMetadata,
    ModelOutput,
    OutputType,
    OnnxInferenceMixin,
    TritonInferenceMixin,
)


class Seth(BaseModel, OnnxInferenceMixin, TritonInferenceMixin):
    """SETH model for predicting protein disorder.

    Supports both ONNX (local) and Triton (remote) backends.
    """

    # Triton configuration
    TRITON_MODEL_NAME = "seth"
    TRITON_INPUT_NAMES = ["input"]  # Triton expects "input" tensor
    TRITON_OUTPUT_NAMES = ["output"]  # Triton returns "output" tensor

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
            name="SETH",
            protocol=Protocol.residue_to_class,  # TODO residue_to_value
            description="SETH model for predicting nuances of residue disorder in proteins",
            authors="Dagmar Ilzhoefer, Michael Heinzinger, Burkhard Rost",
            model_link="https://github.com/DagmarIlz/SETH",
            citation="https://doi.org/10.1101/2022.06.23.497276",
            licence="GPL-3.0",
            outputs=[
                ModelOutput(
                    name="disorder",
                    description="Disorder scores: Below 8 - disorder, Above 8 - order,"
                    "as defined by CheZOD Z-scores: "
                    "https://doi.org/10.1007/978-1-0716-0524-0_15",
                    output_type=OutputType.PER_RESIDUE,
                    value_type=float,
                )
            ],
            model_size="575.1 KB",
            testset_performance="",
            training_data_link="http://data.bioembeddings.com/public/design/",
            embedder="Rostlab/prot_t5_xl_uniref50",
        )

    def predict(self, sequences: Dict[str, str], embeddings):
        self._ensure_backend_initialized()
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        results = []

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
                for i in range(tensor.shape[0]):
                    seq_tensor = tensor[i]
                    seq_result = self._finalize_raw_prediction(seq_tensor.unsqueeze(0))
                    diso_Yhat.extend(seq_result)
            else:
                raise ValueError(f"Unknown backend: {self.backend}")

            results.extend(diso_Yhat)

        model_output = {"disorder": results}
        return self._post_process(
            model_output=model_output, embedding_ids=embedding_ids, delimiter=","
        )
