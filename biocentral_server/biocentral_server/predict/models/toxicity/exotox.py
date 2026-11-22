import torch

from typing import Dict, List
from biotrainer_core.data_classes import Protocol

from ..base_model import (
    BaseModel,
    ModelMetadata,
    ModelOutput,
    OutputClass,
    OutputType,
)
from ..biocentral_prediction_model import BiocentralPredictionModel


class ExoTox(BaseModel):
    """ExoTox model for predicting if a protein is a bacterial exotoxin."""

    def __init__(self, batch_size: int):
        super().__init__(
            batch_size=batch_size,
            uses_ensemble=False,
            requires_mask=False,
            requires_transpose=False,
        )
        self.class2label_mem = {0: "NOT_EXOTOXIN", 1: "EXOTOXIN"}

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name=BiocentralPredictionModel.ExoTox,
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
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="NOT_EXOTOXIN",
                            label="NOT_EXOTOXIN",
                            description="Protein is not an exotoxin",
                        ),
                        OutputClass(
                            shortcut="EXOTOXIN",
                            label="EXOTOXIN",
                            description="Protein is an exotoxin",
                        ),
                    ],
                )
            ],
            model_size="147.4 KB",
            training_data_link="https://data.ub.uni-muenchen.de/576/",
            embedder="Rostlab/prot_t5_xl_uniref50",
        )

    def _predict_implementation(self, sequences: Dict[str, str], embeddings):
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        results = []

        for batch in inputs:
            # Transpose batch and run ONNX inference with specific output name
            batch_transposed = self._transpose_batch(batch)
            exotox_pred = self._run_backend_inference_single(batch=batch_transposed, output_names=["label"])[0]
            results.extend(exotox_pred)

        model_output = {"exotoxin": results}
        return self._post_process(
            model_output=model_output,
            embedding_ids=embedding_ids,
            label_maps={"exotoxin": self.class2label_mem},
        )
