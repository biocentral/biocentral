import torch
import numpy as np

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


class LightAttentionMembrane(BaseModel):
    """LightAttention model for membrane prediction."""

    def __init__(self, batch_size: int):
        super().__init__(
            batch_size=batch_size,
            uses_ensemble=False,
            requires_mask=True,
            requires_transpose=True,
        )
        self.class2label_mem = {0: "Membrane", 1: "Soluble"}

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name=BiocentralPredictionModel.LightAttentionMembrane,
            protocol=Protocol.residues_to_class,
            description="Prediction of protein membrane association",
            authors="Stärk, Hannes and Dallago, Christian and Heinzinger, Michael and Rost, Burkhard",
            model_link="https://github.com/HannesStark/protein-localization",
            citation="https://doi.org/10.1093/bioadv/vbab035",
            licence="MIT",
            outputs=[
                ModelOutput(
                    name="membrane",
                    description="Protein membrane association",
                    output_type=OutputType.PER_SEQUENCE,
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="Membrane",
                            label="Membrane",
                            description="Protein is associated with membranes",
                        ),
                        OutputClass(
                            shortcut="Soluble",
                            label="Soluble",
                            description="Protein is soluble and not membrane-associated",
                        ),
                    ],
                )
            ],
            model_size="",  # onnx in MB
            training_data_link="http://data.bioembeddings.com/public/design/",
            embedder="Rostlab/prot_t5_xl_uniref50",
        )

    def _predict_implementation(self, sequences: Dict[str, str], embeddings):
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        results = []

        for batch in inputs:
            # Transpose batch and run ONNX inference
            batch_transposed = self._transpose_batch(batch)
            raw_output = self._run_backend_inference_single(batch=batch_transposed)
            la_mem_Yhat = torch.from_numpy(np.float32(np.stack(raw_output[0])))

            la_mem_Yhat = self._finalize_raw_prediction(
                torch.max(la_mem_Yhat, dim=1)[1], dtype=np.byte
            )
            results.extend(la_mem_Yhat)

        model_output = {"membrane": results}
        return self._post_process(
            model_output=model_output,
            embedding_ids=embedding_ids,
            label_maps={"membrane": self.class2label_mem},
        )
