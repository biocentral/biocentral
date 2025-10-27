import torch
import numpy as np

from typing import List, Any, Dict
from biotrainer.protocols import Protocol
from vespag import (
    ScoreNormalizer,
    compute_mutation_score,
    mask_non_mutations,
    generate_sav_landscape,
)

from ..base_model import (
    BaseModel,
    ModelMetadata,
    Prediction,
    MutationPrediction,
    ModelOutput,
    OutputType,
    OnnxInferenceMixin,
    TritonInferenceMixin,
)


class VespaG(BaseModel, OnnxInferenceMixin, TritonInferenceMixin):
    """VespaG model for variant effect prediction.

    Supports both ONNX (local) and Triton (remote) backends.
    Predicts effects of single amino acid variants on protein function.
    """

    # Triton configuration
    TRITON_MODEL_NAME = "vespag"
    TRITON_INPUT_NAMES = ["input"]
    TRITON_OUTPUT_NAMES = ["output"]

    def __init__(self, batch_size: int, backend: str = "onnx"):
        super().__init__(
            batch_size=batch_size,
            backend=backend,
            uses_ensemble=False,
            requires_mask=False,
            requires_transpose=False,
        )
        self.zero_based_mutations = False  # VespaG default
        self.mutations_per_protein = {}  # Calculated during predict
        self.normalizer = ScoreNormalizer("minmax")
        self.prediction_name = "variant_effect"

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name="VespaG",
            protocol=Protocol.residue_to_class,  # TODO residue_to_value / mutation
            description="Single amino acid variant effect prediction based on VESPA and GEMME models",
            authors="Céline Marquet, Julius Schlensok, Marina Abakarova, Burkhard Rost, Elodie Laine",
            model_link="https://github.com/JSchlensok/VespaG",
            citation="https://doi.org/10.1093/bioinformatics/btae621",
            licence="GPL-3.0",
            outputs=[
                ModelOutput(
                    name="variant_effect",
                    description="Prediction of the effect of amino acid mutations on protein function",
                    output_type=OutputType.MUTATION,
                    value_type=float,
                    # Scores are normalized between 0 and 1
                    value_range=(0.0, 1.0),
                    unit="score",
                )
            ],
            model_size="2.6 MB",
            testset_performance="",
            training_data_link="https://zenodo.org/records/11085958",
            embedder="facebook/esm2_t36_3B_UR50D",  # Smaller model for testing: facebook/esm2_t33_650M_UR50D
        )

    def _prepare_inputs(self, embeddings):
        """Prepare embeddings for VespaG prediction.

        VespaG expects ESM2-T36 embeddings (2560-dim).
        Returns list of batches with single sequences.
        """
        return [
            {"input": torch.from_numpy(embedding).unsqueeze(0).numpy()}
            for embedding in embeddings.values()
        ]

    def predict(self, sequences: Dict[str, str], embeddings):
        self._ensure_backend_initialized()
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        self.mutations_per_protein = generate_sav_landscape(
            sequences=sequences,
            zero_based_mutations=self.zero_based_mutations,
            tqdm=False,
        )
        vespag_scores = {}
        for seq_idx, sequence_embedding in enumerate(inputs):
            seq_id = embedding_ids[seq_idx]

            # Backend-agnostic inference
            if self.backend == "onnx":
                raw_output = self.model.run(None, sequence_embedding)
                y = torch.from_numpy(np.float32(np.stack(raw_output[0]))).squeeze(0)
            elif self.backend == "triton":
                raw_output = self._run_inference(sequence_embedding)
                y = torch.from_numpy(raw_output.astype(np.float32)).squeeze(0)
            else:
                raise ValueError(f"Unknown backend: {self.backend}")

            y = mask_non_mutations(y, sequences[seq_id])
            vespag_scores[seq_id] = y.detach().numpy()

        self.normalizer.fit(
            np.concatenate([y.flatten() for y in vespag_scores.values()])
        )
        model_output = {self.prediction_name: vespag_scores}
        return self._post_process(
            model_output=model_output, embedding_ids=embedding_ids
        )

    def _post_process(
        self,
        model_output: Dict[str, Any],
        embedding_ids: List[str],
        label_maps: Dict[str, Dict[int, str]] = None,
        delimiter: str = "",
    ) -> Dict[str, List[Prediction]]:
        scores_per_protein = {}
        model_name = self.get_metadata().name
        protocol = self.get_metadata().protocol
        for seq_id, y in model_output[self.prediction_name].items():
            scores_per_protein[seq_id] = [
                MutationPrediction(
                    model_name=model_name,
                    prediction_name=self.prediction_name,
                    protocol=protocol.name,
                    prediction=compute_mutation_score(
                        y,
                        mutation,
                        normalizer=self.normalizer,
                    ),
                    mutation=mutation,
                )
                for mutation in self.mutations_per_protein[seq_id]
            ]
        return scores_per_protein
