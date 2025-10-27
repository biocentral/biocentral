import torch
import numpy as np

from tmbed import Decoder
from typing import Dict, List
from biotrainer.protocols import Protocol

from ..base_model import (
    BaseModel,
    ModelMetadata,
    ModelOutput,
    OutputClass,
    OutputType,
    OnnxInferenceMixin,
    TritonInferenceMixin,
)


class TMbed(BaseModel, OnnxInferenceMixin, TritonInferenceMixin):
    """TMbed model for transmembrane topology prediction.

    Supports both ONNX (local) and Triton (remote) backends.
    Uses an ensemble of models and requires masking.
    """

    # Triton configuration
    TRITON_MODEL_NAME = "tmbed"
    TRITON_INPUT_NAMES = ["input", "mask"]
    TRITON_OUTPUT_NAMES = ["output"]

    @staticmethod
    def TRITON_OUTPUT_TRANSFORMER(self, outputs: List[np.ndarray]) -> np.ndarray:
        """Transpose TMbed output from (batch, num_classes, seq_len) to (batch, seq_len, num_classes)."""
        # TMbed Triton returns (batch, 7, seq_len), need (batch, seq_len, 7)
        return np.transpose(outputs[0], (0, 2, 1))

    def __init__(self, batch_size, backend: str = "onnx"):
        super().__init__(
            batch_size=batch_size,
            backend=backend,
            uses_ensemble=True,
            requires_mask=True,
            requires_transpose=True,
        )
        self.decoder = Decoder().to(self.device)
        self.pred2label = {0: "B", 1: "b", 2: "H", 3: "h", 4: "S", 5: "i", 6: "o"}

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name="TMbed",
            protocol=Protocol.residue_to_class,
            description="Prediction of transmembrane proteins",
            authors="Bernhofer, Michael and Rost, Burkhard",
            model_link="https://github.com/BernhoferM/TMbed",
            citation="https://doi.org/10.1186/s12859-022-04873-x",
            licence="Apache-2.0",
            outputs=[
                ModelOutput(
                    name="trans_membrane",
                    description="Per-residue transmembrane topology prediction",
                    output_type=OutputType.PER_RESIDUE,
                    value_type=str,
                    classes={
                        "B": OutputClass(
                            label="Transmembrane beta strand",
                            description="Residue is part of a transmembrane beta strand "
                            "(IN-->OUT orientation)",
                        ),
                        "b": OutputClass(
                            label="Transmembrane beta strand",
                            description="Residue is part of a transmembrane beta strand "
                            "(OUT-->IN orientation)",
                        ),
                        "H": OutputClass(
                            label="Transmembrane alpha helix",
                            description="Residue is part of a transmembrane helix "
                            "(IN-->OUT orientation)",
                        ),
                        "h": OutputClass(
                            label="Transmembrane alpha helix",
                            description="Residue is part of a transmembrane helix "
                            "(OUT-->IN orientation)",
                        ),
                        "S": OutputClass(
                            label="Signal peptide",
                            description="Residue is part of a signal peptide",
                        ),
                        "i": OutputClass(
                            label="Non-Transmembrane, inside",
                            description="Residue is on the inside (cytoplasmic) side",
                        ),
                        "o": OutputClass(
                            label="Non-Transmembrane, outside",
                            description="Residue is on the outside (extracellular) side",
                        ),
                    },
                )
            ],
            model_size="1.4 MB",
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
            B, L, _ = batch["input"].shape

            if self.backend == "onnx":
                # ONNX: Run ensemble manually
                # Container for summing up predictions of individual models in the ensemble
                pred = torch.zeros((B, len(self.models), L), device=self.device)
                for model in self.models:
                    y = model.run(None, batch)
                    y = torch.from_numpy(np.float32(np.stack(y[0])))
                    pred = pred + torch.softmax(y, dim=1).to(self.device)

                probabilities = pred / len(self.models)
                mem_Yhat = self._finalize_raw_prediction(
                    self.decoder(
                        probabilities, torch.from_numpy(batch["mask"]).to(self.device)
                    ),
                    dtype=np.byte,
                )

            elif self.backend == "triton":
                # Triton: Ensemble handled on server, output already transposed
                raw_output = self._run_inference(batch)
                # raw_output is (batch, seq_len, 7) after transformer
                probabilities = torch.from_numpy(raw_output)
                mem_Yhat = self._finalize_raw_prediction(
                    self.decoder(
                        probabilities, torch.from_numpy(batch["mask"]).to(self.device)
                    ),
                    dtype=np.byte,
                )
            else:
                raise ValueError(f"Unknown backend: {self.backend}")

            results.extend(mem_Yhat)

        model_output = {"trans_membrane": results}
        return self._post_process(
            model_output=model_output,
            embedding_ids=embedding_ids,
            label_maps={"trans_membrane": self.pred2label},
        )
