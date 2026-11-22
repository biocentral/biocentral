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


class LightAttentionSubcellularLocalization(BaseModel):
    """LightAttention model for subcellular localization prediction.

    Sequence-level prediction that requires masking and transposed input.
    """

    def __init__(self, batch_size):
        super().__init__(
            batch_size=batch_size,
            uses_ensemble=False,
            requires_mask=True,
            requires_transpose=True,
        )
        self.class2label_subcell = {
            0: "Cell_membrane",
            1: "Cytoplasm",
            2: "Endoplasmatic_reticulum",
            3: "Golgi_apparatus",
            4: "Lysosome_or_Vacuole",
            5: "Mitochondrion",
            6: "Nucleus",
            7: "Peroxisome",
            8: "Plastid",
            9: "Extracellular",
        }

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name=BiocentralPredictionModel.LightAttentionSubcellularLocalization,
            protocol=Protocol.residues_to_class,
            description="Protein subcellular localization prediction",
            authors="Stärk, Hannes and Dallago, Christian and Heinzinger, Michael and Rost, Burkhard",
            model_link="https://github.com/HannesStark/protein-localization",
            citation="https://doi.org/10.1093/bioadv/vbab035",
            licence="MIT",
            outputs=[
                ModelOutput(
                    name="subcellular_localization",
                    description="Protein subcellular localization",
                    output_type=OutputType.PER_SEQUENCE,
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="Cell_membrane",
                            label="Cell membrane",
                            description="Protein is localized to the cell membrane",
                        ),
                        OutputClass(
                            shortcut="Cytoplasm",
                            label="Cytoplasm",
                            description="Protein is localized to the cytoplasm",
                        ),
                        OutputClass(
                            shortcut="Endoplasmatic_reticulum",
                            label="Endoplasmic reticulum",
                            description="Protein is localized to the endoplasmic reticulum",
                        ),
                        OutputClass(
                            shortcut="Golgi_apparatus",
                            label="Golgi apparatus",
                            description="Protein is localized to the Golgi apparatus",
                        ),
                        OutputClass(
                            shortcut="Lysosome_or_Vacuole",
                            label="Lysosome or Vacuole",
                            description="Protein is localized to lysosomes or vacuoles",
                        ),
                        OutputClass(
                            shortcut="Mitochondrion",
                            label="Mitochondrion",
                            description="Protein is localized to mitochondria",
                        ),
                        OutputClass(
                            shortcut="Nucleus",
                            label="Nucleus",
                            description="Protein is localized to the nucleus",
                        ),
                        OutputClass(
                            shortcut="Peroxisome",
                            label="Peroxisome",
                            description="Protein is localized to peroxisomes",
                        ),
                        OutputClass(
                            shortcut="Plastid",
                            label="Plastid",
                            description="Protein is localized to plastids",
                        ),
                        OutputClass(
                            shortcut="Extracellular",
                            label="Extracellular",
                            description="Protein is secreted outside the cell",
                        ),
                    ],
                )
            ],
            model_size="75.8 MB",
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
            subcell_Yhat = torch.from_numpy(np.float32(np.stack(raw_output[0])))
            subcell_Yhat = self._finalize_raw_prediction(
                torch.max(subcell_Yhat, dim=1)[1], dtype=np.byte
            )

            results.extend(subcell_Yhat)

        model_output = {"subcellular_localization": results}
        return self._post_process(
            model_output=model_output,
            embedding_ids=embedding_ids,
            label_maps={"subcellular_localization": self.class2label_subcell},
        )
