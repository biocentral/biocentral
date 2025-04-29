import torch
import numpy as np

from typing import List, Dict
from biotrainer.protocols import Protocol

from ..base_model import BaseModel, ModelMetadata, Prediction, ModelOutput, OutputClass, OutputType


class SETH(BaseModel):

    def __init__(self, batch_size):
        super().__init__(batch_size=batch_size, uses_ensemble=False, requires_mask=False, requires_transpose=False)

    @staticmethod
    def get_metadata() -> ModelMetadata:
        return ModelMetadata(
            name="SETH",
            protocol=Protocol.residue_to_class,  # TODO residue_to_value
            description='SETH model for predicting nuances of residue disorder in proteins',
            authors='Dagmar Ilzhoefer, Michael Heinzinger, Burkhard Rost',
            model_link='https://github.com/DagmarIlz/SETH',
            citation='https://doi.org/10.1101/2022.06.23.497276',
            licence='GPL-3.0',
            outputs=[ModelOutput(name="disorder",
                                 description="Disorder scores: Below 8 - disorder, Above 8 - order,"
                                             "as defined by CheZOD Z-scores: "
                                             "https://doi.org/10.1007/978-1-0716-0524-0_15",
                                 output_type=OutputType.PER_RESIDUE,
                                 value_type=float,
                                 )
                     ],
            model_size='575.1 KB',
            testset_performance='',
            training_data_link='http://data.bioembeddings.com/public/design/',
            embedder='Rostlab/prot_t5_xl_uniref50'
        )

    def predict(self, sequences: Dict[str, str], embeddings):
        inputs = self._prepare_inputs(embeddings=embeddings)
        embedding_ids = list(embeddings.keys())
        results = []
        for batch in inputs:
            diso_Yhat = self.model.run(None, batch)
            diso_Yhat = self._finalize_raw_prediction(torch.from_numpy(np.float32(np.stack(diso_Yhat[0]))))
            results.extend(diso_Yhat)
        model_output = {"disorder": results}
        return self._post_process(model_output=model_output, embedding_ids=embedding_ids, delimiter=",")
