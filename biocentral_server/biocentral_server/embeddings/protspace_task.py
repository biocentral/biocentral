from __future__ import annotations

import numpy as np
import pandas as pd

from protspace.utils import REDUCERS
from typing import Callable, Dict, List
from protspace.data.processors import BaseProcessor
from biotrainer.input_files import BiotrainerSequenceRecord

from .embedding_task import LoadEmbeddingsTask

from ..utils import get_logger
from ..server_management import TaskInterface, TaskDTO, TaskStatus

logger = get_logger(__name__)


class ProtSpaceTask(TaskInterface):
    def __init__(
        self,
        embedder_name: str,
        sequences: List[BiotrainerSequenceRecord],
        method: str,
        config: Dict,
    ):
        self.embedder_name = embedder_name
        self.sequences = sequences

        self.method = method
        self.config = config

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        load_embeddings_task = LoadEmbeddingsTask(
            embedder_name=self.embedder_name,
            sequence_input=self.sequences,
            reduced=True,
            use_half_precision=False,
            device="cpu",
        )
        load_dto = None
        for dto in self.run_subtask(load_embeddings_task):
            load_dto = dto

        if not load_dto or load_dto.embeddings is None:
            return TaskDTO(
                status=TaskStatus.FAILED,
                error="Loading of embeddings failed before projection!",
            )

        embeddings: List[BiotrainerSequenceRecord] = load_dto.embeddings

        embedding_dict = {
            embd_record.seq_id: embd_record.embedding for embd_record in embeddings
        }
        protspace_headers = list(embedding_dict.keys())

        dimensions = self.config.pop("n_components")
        processor = BaseProcessor(config=self.config, reducers=REDUCERS)
        metadata = pd.DataFrame({"identifier": protspace_headers})

        logger.info(
            f"Applying {self.method.upper()} reduction. Dimensions: {dimensions}. Config: {self.config}"
        )
        reduction = processor.process_reduction(
            data=np.array(list(embedding_dict.values())),
            method=self.method,
            dims=dimensions,
        )
        output = processor.create_output(
            metadata=metadata, reductions=[reduction], headers=protspace_headers
        )
        projection_result = {key: table.to_pydict() for key, table in output.items()}
        return TaskDTO(status=TaskStatus.FINISHED, projection_result=projection_result)
