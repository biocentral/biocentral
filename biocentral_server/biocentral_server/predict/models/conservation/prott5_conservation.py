import torch
import numpy as np

from typing import List, Dict
from biotrainer.protocols import Protocol

from ..base_model import (
    BaseModel,
    ModelMetadata,
    Prediction,
    ModelOutput,
    OutputClass,
    OutputType,
)


class ProtT5Conservation(BaseModel):
    def __init__(self, batch_size):
        super().__init__(
            batch_size=batch_size,
            uses_ensemble=False,
            requires_mask=False,
            requires_transpose=False,
        )

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name="ProtT5Conservation",
            protocol=Protocol.residue_to_class,
            description="VESPA model for protein residue conservation prediction",
            authors="C{'{e}}line Marquet and Michael Heinzinger and Tobias Olenyi and Christian Dallago and Kyra Erckert and Michael Bernhofer and Dmitrii Nechaev and Burkhard Rost",
            model_link="https://github.com/Rostlab/VESPA",
            citation="https://doi.org/10.1007/s00439-021-02411-y",
            licence="AGPL-3.0",
            outputs=[
                ModelOutput(
                    name="conservation",
                    description="Per-residue evolutionary conservation prediction, "
                    "as defined by 10.1093/bioinformatics/bth070",
                    output_type=OutputType.PER_RESIDUE,
                    value_type=str,
                    classes={
                        "0": OutputClass(
                            label="Variable",
                            description="Residue is evolutionarily variable",
                        ),
                        "1": OutputClass(
                            label="Variable",
                            description="Residue is evolutionarily variable",
                        ),
                        "2": OutputClass(
                            label="Variable",
                            description="Residue is evolutionarily variable",
                        ),
                        "3": OutputClass(
                            label="Variable",
                            description="Residue is evolutionarily variable",
                        ),
                        "4": OutputClass(
                            label="Average",
                            description="Residue is equally conserved and variable",
                        ),
                        "5": OutputClass(
                            label="Average",
                            description="Residue is equally conserved and variable",
                        ),
                        "6": OutputClass(
                            label="Average",
                            description="Residue is equally conserved and variable",
                        ),
                        "7": OutputClass(
                            label="Variable",
                            description="Residue is evolutionarily conserved",
                        ),
                        "8": OutputClass(
                            label="Conserved",
                            description="Residue is evolutionarily conserved",
                        ),
                    },
                )
            ],
            model_size="926.7 KB",
            testset_performance="",
            training_data_link="http://data.bioembeddings.com/public/design/",
            embedder="Rostlab/prot_t5_xl_uniref50",
        )

    def predict(
        self, sequences: Dict[str, str], embeddings
    ) -> Dict[str, List[Prediction]]:
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        results = []
        for batch in inputs:
            cons_Yhat = self.model.run(None, batch)
            cons_Yhat = torch.from_numpy(np.float32(np.stack(cons_Yhat[0])))
            cons_Yhat = self._finalize_raw_prediction(
                torch.max(cons_Yhat, dim=-1, keepdim=True)[1], dtype=np.byte
            )
            results.extend(cons_Yhat)
        model_output = {"conservation": results}
        return self._post_process(
            model_output=model_output, embedding_ids=embedding_ids
        )
