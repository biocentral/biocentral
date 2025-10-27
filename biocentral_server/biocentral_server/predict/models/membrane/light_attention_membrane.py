import torch
import numpy as np

from typing import Dict
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


class LightAttentionMembrane(BaseModel, LocalOnnxInferenceMixin, TritonInferenceMixin):
    """LightAttention model for membrane prediction.
    
    Supports both ONNX (local) and Triton (remote) backends.
    """
    
    # Triton configuration
    TRITON_MODEL_NAME = "light_attention_membrane"
    TRITON_INPUT_NAMES = ["input", "mask"]
    TRITON_OUTPUT_NAMES = ["output"]

    # Custom transformer for Triton
    @staticmethod
    def TRITON_INPUT_TRANSFORMER(self, batch: Dict) -> Dict:
        """Transform batch for Triton: transpose input."""
        # LightAttentionMembrane requires transposed input (B, L, E) -> (B, E, L)
        batch = self._transpose_batch(batch)
        return batch

    def __init__(self, batch_size: int, backend: str = "onnx"):
        super().__init__(
            batch_size=batch_size,
            backend=backend,
            uses_ensemble=False,
            requires_mask=True,
            requires_transpose=True,
            model_dir_name="la_mem",
        )
        self.class2label_mem = {0: "Membrane", 1: "Soluble"}

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name="LightAttentionMembrane",
            protocol=Protocol.residues_to_class,
            description="Prediction of protein membrane association",
            authors="Stärk, Hannes and Dallago, Christian and Heinzinger, Michael and Rost, Burkhard",
            model_link="https://github.com/HannesStark/protein-localization",
            citation=" https://doi.org/10.1093/bioadv/vbab035",
            licence="MIT",
            outputs=[
                ModelOutput(
                    name="membrane",
                    description="Protein membrane association",
                    output_type=OutputType.PER_SEQUENCE,
                    value_type=str,
                    classes={
                        "Membrane": OutputClass(
                            label="Membrane",
                            description="Protein is associated with membranes",
                        ),
                        "Soluble": OutputClass(
                            label="Soluble",
                            description="Protein is soluble and not membrane-associated",
                        ),
                    },
                )
            ],
            model_size="",  # onnx in MB
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
            if self.backend == "onnx":
                # ONNX: Local inference
                batch_transposed = self._transpose_batch(batch)
                la_mem_Yhat = self.model.run(None, batch_transposed)
                la_mem_Yhat = torch.from_numpy(np.float32(np.stack(la_mem_Yhat[0])))
            elif self.backend == "triton":
                # Triton: Remote inference
                la_mem_Yhat_np = self._run_inference(batch)
                la_mem_Yhat = torch.from_numpy(la_mem_Yhat_np)
            else:
                raise ValueError(f"Unknown backend: {self.backend}")
            
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
