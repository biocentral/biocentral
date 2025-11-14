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
    LocalOnnxInferenceMixin,
    TritonInferenceMixin,
)


class TMbed(BaseModel, LocalOnnxInferenceMixin, TritonInferenceMixin):
    """TMbed model for transmembrane topology prediction.

    Supports both ONNX (local) and Triton (remote) backends.
    Uses an ensemble of models and requires masking.
    """

    # Triton configuration
    @staticmethod
    def TRITON_MODEL_NAME() -> str:
        """Name of model in Triton repository."""
        return "tmbed"

    @staticmethod
    def TRITON_INPUT_NAMES() -> List[str]:
        """Names of input tensors."""
        return ["ensemble_input", "mask"]

    @staticmethod
    def TRITON_OUTPUT_NAMES() -> List[str]:
        """Names of output tensors."""
        return [f"output_{i}" for i in range(5)]  # 5 CV folds

    # Custom transformers for Triton
    def triton_input_transformer(self, batch: Dict) -> Dict:
        """Transform batch for Triton: rename 'input' to 'ensemble_input'."""
        if "input" in batch:
            batch["ensemble_input"] = batch.pop("input")
        return batch

    def triton_output_transformer(self, outputs: List[np.ndarray]) -> np.ndarray:
        """Apply softmax to each CV fold and average.

        TMbed uses 5-fold CV ensemble. Each fold returns raw logits (batch, 7, seq_len).
        Process:
        1. Apply softmax(dim=1) over 7 topology classes for each fold
        2. Average the 5 softmax probability distributions
        3. Return (batch, 7, seq_len) format expected by decoder
        """
        # Apply softmax over topology classes (dim=1) for each CV fold
        softmax_outputs = []
        for logits in outputs:  # Each is (batch, 7, seq_len)
            # Softmax over dim=1 (the 7 topology classes)
            # Subtract max for numerical stability
            exp_logits = np.exp(logits - np.max(logits, axis=1, keepdims=True))
            softmax = exp_logits / np.sum(exp_logits, axis=1, keepdims=True)
            softmax_outputs.append(softmax)

        # Average across the 5 CV folds
        avg_probabilities = np.mean(
            softmax_outputs, axis=0
        )  # Shape: (batch, 7, seq_len)

        # Return in (batch, 7, seq_len) format expected by TMbed decoder
        return avg_probabilities

    def __init__(self, batch_size, backend: str = "onnx"):
        super().__init__(
            batch_size=batch_size,
            backend=backend,
            uses_ensemble=True,
            requires_mask=True,
            requires_transpose=False,  # TMbed doesn't need transpose for Triton
        )
        self.decoder = Decoder()
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
        input_name = self._infer_input_name()
        embedding_ids = list(embeddings.keys())
        results = []
        for batch in inputs:
            B, L, _ = batch[input_name].shape

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
                # Triton: Ensemble handled on server
                raw_output = self._run_inference(batch)
                # raw_output is (batch, 7, seq_len) after transformer - same as ONNX
                probabilities = torch.from_numpy(raw_output)
                mem_Yhat = self._finalize_raw_prediction(
                    self.decoder(probabilities, torch.from_numpy(batch["mask"])),
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
