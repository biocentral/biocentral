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


class ProtT5SecondaryStructure(BaseModel):
    """ProtT5SecondaryStructure model for secondary structure prediction.

    Predicts 3-state and 8-state secondary structure.
    """

    def __init__(self, batch_size):
        super().__init__(
            batch_size=batch_size,
            uses_ensemble=False,
            requires_mask=False,
            requires_transpose=False,
        )
        self.label_mapping_3_states = {0: "H", 1: "E", 2: "L"}
        self.label_mapping_8_states = {
            idx: state for idx, state in enumerate("GHIBESTC")
        }

    @staticmethod
    def label_mapping() -> Dict[int, str]:
        """3-state secondary structure label mapping (index -> label)."""
        return {0: "H", 1: "E", 2: "L"}

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name=BiocentralPredictionModel.ProtT5SecondaryStructure,
            protocol=Protocol.residue_to_class,
            description="ProtT5 secondary structure prediction",
            authors="Elnaggar, Ahmed and Heinzinger, Michael and Dallago, Christian and Rehawi, Ghalia and Yu, Wang and Jones, Llion and Gibbs, Tom and Feher, Tamas and Angerer, Christoph and Steinegger, Martin and Bhowmik, Debsindhu and Rost, Burkhard",
            model_link="https://github.com/agemagician/ProtTrans",
            citation="https://doi.org/10.1109/TPAMI.2021.3095381",
            licence="MIT",
            outputs=[
                ModelOutput(
                    name="d3_Yhat",
                    description="3-state secondary structure prediction",
                    output_type=OutputType.PER_RESIDUE,
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="H",
                            label="Helix",
                            description="Residue is part of an alpha helix",
                        ),
                        OutputClass(
                            shortcut="E",
                            label="Sheet",
                            description="Residue is part of a beta sheet",
                        ),
                        OutputClass(
                            shortcut="L",
                            label="Other",
                            description="Residue is part of a loop or coil",
                        ),
                    ],
                ),
                ModelOutput(
                    name="d8_Yhat",
                    description="8-state DSSP secondary structure prediction",
                    output_type=OutputType.PER_RESIDUE,
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="G",
                            label="3-10 Helix",
                            description="Residue is part of a 3-10 helix",
                        ),
                        OutputClass(
                            shortcut="H",
                            label="Alpha Helix",
                            description="Residue is part of an alpha helix",
                        ),
                        OutputClass(
                            shortcut="I",
                            label="Pi Helix",
                            description="Residue is part of a pi helix",
                        ),
                        OutputClass(
                            shortcut="B",
                            label="Beta Bridge",
                            description="Residue is part of an isolated beta bridge",
                        ),
                        OutputClass(
                            shortcut="E",
                            label="Extended Strand",
                            description="Residue is part of an extended strand in a beta ladder",
                        ),
                        OutputClass(
                            shortcut="S",
                            label="Bend",
                            description="Residue is part of a bend",
                        ),
                        OutputClass(
                            shortcut="T",
                            label="Turn",
                            description="Residue is part of a hydrogen-bonded turn",
                        ),
                        OutputClass(
                            shortcut="C",
                            label="Coil",
                            description="Residue is part of a coil (none of the above)",
                        ),
                    ],
                ),
            ],
            model_size="929.0 KB",
            training_data_link="http://data.bioembeddings.com/public/design/",
            embedder="Rostlab/prot_t5_xl_uniref50",
        )

    def _predict_implementation(self, sequences: Dict[str, str], embeddings):
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        model_output = {"d3_Yhat": [], "d8_Yhat": []}

        for batch in inputs:
            # Run ONNX inference; returns both 3-state and 8-state predictions
            raw_output = self._run_backend_inference_single(batch=batch)
            d3_Yhat = torch.from_numpy(np.float32(np.stack(raw_output[0])))
            d8_Yhat = torch.from_numpy(np.float32(np.stack(raw_output[1])))
            d3_Yhat = self._finalize_raw_prediction(
                torch.max(d3_Yhat, dim=-1, keepdim=True)[1], dtype=np.byte
            )
            d8_Yhat = self._finalize_raw_prediction(
                torch.max(d8_Yhat, dim=-1, keepdim=True)[1], dtype=np.byte
            )
            model_output["d3_Yhat"].extend(d3_Yhat)
            model_output["d8_Yhat"].extend(d8_Yhat)

        return self._post_process(
            model_output=model_output,
            embedding_ids=embedding_ids,
            label_maps={
                "d3_Yhat": self.label_mapping_3_states,
                "d8_Yhat": self.label_mapping_8_states,
            },
        )
