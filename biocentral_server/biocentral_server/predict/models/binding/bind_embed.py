import torch
import numpy as np

from torch import nn
from typing import List, Any, Dict, Optional
from biotrainer_core.data_classes import Protocol

from ..base_model import (
    BaseModel,
    ModelMetadata,
    ModelOutput,
    OutputClass,
    OutputType,
)
from ..biocentral_prediction_model import BiocentralPredictionModel

from ....server_management import Prediction


class BindEmbed(BaseModel):
    """BindEmbed model for binding site prediction.

    Uses an ensemble of 5 models with sigmoid activation and averaging.
    """

    def __init__(self, batch_size: int):
        super().__init__(
            batch_size=batch_size,
            uses_ensemble=True,
            requires_mask=False,
            requires_transpose=True,
        )
        self.sigmoid = nn.Sigmoid()
        self.binding_classes = {
            0: ("metal", "M"),
            1: ("nucleic", "N"),
            2: ("small", "S"),
        }

    @staticmethod
    def label_mapping() -> Dict[int, str]:
        """Binding type label mapping (index -> shortcut)."""
        return {0: "M", 1: "N", 2: "S"}

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name=BiocentralPredictionModel.BindEmbed,
            protocol=Protocol.residue_to_class,
            description="bindEmbed21DL - Binding residue prediction for various ligand classes",
            authors="Littmann, Maria and Heinzinger, Michael and Dallago, Christian and Weissenow, Konstantin and Rost, Burkhard",
            model_link="https://github.com/Rostlab/bindPredict",
            citation="https://doi.org/10.1038/s41598-021-03431-4",
            licence="MIT",
            outputs=[
                ModelOutput(
                    name="metal",
                    description="Per-residue binding affinity for metal",
                    output_type=OutputType.PER_RESIDUE,
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="M",
                            label="Metal affinity",
                            description="Residue binds to metal",
                        ),
                        OutputClass(
                            shortcut="-",
                            label="No metal affinity",
                            description="Residue does not bind to metal",
                        ),
                    ],
                ),
                ModelOutput(
                    name="nucleic",
                    description="Per-residue binding affinity for nucleic acids",
                    output_type=OutputType.PER_RESIDUE,
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="N",
                            label="Nucleic affinity",
                            description="Residue binds to nucleic acids",
                        ),
                        OutputClass(
                            shortcut="-",
                            label="No nucleic affinity",
                            description="Residue does not bind to nucleic acids",
                        ),
                    ],
                ),
                ModelOutput(
                    name="small",
                    description="Per-residue binding affinity for small organic molecules",
                    output_type=OutputType.PER_RESIDUE,
                    value_type="str",
                    classes=[
                        OutputClass(
                            shortcut="S",
                            label="Small molecules affinity",
                            description="Residue binds to small organic molecules",
                        ),
                        OutputClass(
                            shortcut="-",
                            label="No small molecules affinity",
                            description="Residue does not bind to small organic molecules",
                        ),
                    ],
                ),
            ],
            model_size="2.6 MB",
            training_data_link="http://data.bioembeddings.com/public/design/",
            embedder="Rostlab/prot_t5_xl_uniref50",
        )

    def _predict_implementation(self, sequences: Dict[str, str], embeddings):
        inputs = self._prepare_inputs(embeddings=embeddings)
        input_name = self._infer_input_name()
        embedding_ids = list(embeddings.keys())
        results = []

        for batch in inputs:
            B, L, _ = batch[input_name].shape

            # Run ensemble manually
            batch_transposed = self._transpose_batch(batch)
            ensemble_container = torch.zeros(
                (B, L, len(self.binding_classes.keys())),
                device="cpu",
                dtype=torch.float16,
            )
            for model_output_numpy in self._run_backend_inference_ensemble(batch=batch_transposed):
                model_output_torch = torch.from_numpy(
                    np.float32(np.stack(model_output_numpy[0]))
                )
                pred = self.sigmoid(model_output_torch)
                pred = torch.from_numpy(np.float32(np.stack(pred)))
                ensemble_container = ensemble_container + pred
            # normalize
            bind_Yhat = ensemble_container / len(self.models)
            bind_Yhat = self._finalize_raw_prediction(
                bind_Yhat > 0.5, dtype=np.byte
            )

            results.extend(bind_Yhat)

        model_output = {"binding": results}
        return self._post_process(
            model_output=model_output, embedding_ids=embedding_ids
        )

    def _post_process(
        self,
        model_output: Dict[str, Any],
        embedding_ids: List[str],
        label_maps: Optional[Dict[str, Dict[int, str]]] = None,
        delimiter: str = "",
    ) -> Dict[str, List[Prediction]]:
        formatted_predictions = {}
        model_name = self.get_metadata().name.name
        protocol = self.get_metadata().protocol

        for binding_id, (binding_type, bind_short) in self.binding_classes.items():
            for i, pred in enumerate(model_output["binding"]):
                embedding_id = embedding_ids[i]
                if embedding_id not in formatted_predictions:
                    formatted_predictions[embedding_id] = []

                prediction = "".join(
                    [
                        bind_short if j == 1 else "-"
                        for pred_idx, j in enumerate(pred[:, binding_id])
                        if pred_idx < self.non_padded_embedding_lengths[embedding_id]
                    ]
                )
                formatted_predictions[embedding_id].append(
                    Prediction(
                        model_name=model_name,
                        prediction_name=binding_type,
                        protocol=protocol.name,
                        value=prediction,
                    )
                )

        return formatted_predictions
