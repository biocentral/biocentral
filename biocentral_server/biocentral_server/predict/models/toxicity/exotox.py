import torch

from typing import Dict, List
from biotrainer.protocols import Protocol

from ..base_model import (
    BaseModel,
    ModelMetadata,
    ModelOutput,
    OutputClass,
    OutputType,
    LocalOnnxInferenceMixin,
    TritonInferenceMixin,
)


class ExoTox(BaseModel, LocalOnnxInferenceMixin, TritonInferenceMixin):
    """ExoTox model for predicting if a protein is a bacterial exotoxin.

    Supports both ONNX (local) and Triton (remote) backends.
    """

    # Triton configuration
    @staticmethod
    def TRITON_MODEL_NAME() -> str:
        """Name of model in Triton repository."""
        return "exotox"

    @staticmethod
    def TRITON_INPUT_NAMES() -> List[str]:
        """Names of input tensors."""
        return ["X"]

    @staticmethod
    def TRITON_OUTPUT_NAMES() -> List[str]:
        """Names of output tensors."""
        return ["label"]

    # Custom transformer for Triton
    def triton_input_transformer(self, batch: Dict) -> Dict:
        """Transform batch for Triton: transpose input."""
        return self._transpose_batch(batch)

    def __init__(self, batch_size: int, backend: str = "onnx"):
        super().__init__(
            batch_size=batch_size,
            backend=backend,
            uses_ensemble=False,
            requires_mask=False,
            requires_transpose=False,
            model_dir_name="exotox",
        )
        self.class2label_mem = {0: "NOT_EXOTOXIN", 1: "EXOTOXIN"}

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name="ExoTox",
            protocol=Protocol.sequence_to_class,
            description="Prediction of exotoxins",
            authors="Tanja Krueger and Damla A. Durmaz & Luisa F. Jimenez-Soto",
            model_link="https://data.ub.uni-muenchen.de/576/",
            citation="https://doi.org/10.1186/s13040-025-00469-2",
            licence="CC BY 4.0",
            outputs=[
                ModelOutput(
                    name="exotoxin",
                    description="Protein is an exotoxin or not",
                    output_type=OutputType.PER_SEQUENCE,
                    value_type=str,
                    classes={
                        "NOT_EXOTOXIN": OutputClass(
                            label="NOT_EXOTOXIN",
                            description="Protein is not an exotoxin",
                        ),
                        "EXOTOXIN": OutputClass(
                            label="EXOTOXIN",
                            description="Protein is an exotoxin",
                        ),
                    },
                )
            ],
            model_size="147.4 KB",
            testset_performance="",
            training_data_link="https://data.ub.uni-muenchen.de/576/",
            embedder="Rostlab/prot_t5_xl_uniref50",
        )

    def predict(self, sequences: Dict[str, str], embeddings):
        self._ensure_backend_initialized()
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        results = []

        for batch in inputs:
            if self.backend == "onnx":
                # ONNX: Local inference
                batch_transposed = self._transpose_batch(batch)
                exotox_pred = self.model.run(["label"], batch_transposed)[0]
            elif self.backend == "triton":
                # Triton: Remote inference
                exotox_pred_np = self._run_inference(batch)
                exotox_pred = [torch.from_numpy(exotox_pred_np).item()]
            else:
                raise ValueError(f"Unknown backend: {self.backend}")

            results.extend(exotox_pred)

        model_output = {"exotoxin": results}
        return self._post_process(
            model_output=model_output,
            embedding_ids=embedding_ids,
            label_maps={"exotoxin": self.class2label_mem},
        )
