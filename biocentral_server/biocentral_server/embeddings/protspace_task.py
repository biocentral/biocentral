from __future__ import annotations

import logging
import numpy as np
import pandas as pd

from typing import Callable, Dict

from biotrainer.protocols import Protocol
from protspace.utils.prepare_json import DataProcessor

from .embedding_task import OneHotEncodeTask
from ..server_management import TaskInterface, TaskDTO, EmbeddingsDatabase

logger = logging.getLogger(__name__)

def load_embeddings_strategy_factory(embedder_name: str,
                                     sequences: Dict[str, str],
                                     embeddings_db: EmbeddingsDatabase,
                                     ) -> Callable:
    if embedder_name == "one_hot_encoding":
        return lambda protspace_task: _load_one_hot_encodings(protspace_task, sequences)
    return lambda protspace_task: _load_embeddings_via_sequences(protspace_task, embeddings_db, embedder_name, sequences)


def _load_embeddings_via_sequences(protspace_task: ProtSpaceTask,
                                   embeddings_db: EmbeddingsDatabase,
                                   embedder_name: str,
                                   sequences: Dict[str, str]) -> Dict[str, np.ndarray]:
    triples = embeddings_db.get_embeddings(sequences=sequences, embedder_name=embedder_name, reduced=True)
    return {triple.id: triple.embd for triple in triples}


def _load_one_hot_encodings(protspace_task: ProtSpaceTask,
                           sequences: Dict[str, str]) -> Dict[str, np.ndarray]:
    one_hot_encode_subtask = OneHotEncodeTask(sequences=sequences, protocol=Protocol.using_per_sequence_embeddings()[0])
    current_dto = None
    for dto in protspace_task.run_subtask(one_hot_encode_subtask):
        current_dto = dto
    if current_dto:
        return current_dto.update["one_hot_encoding"]
    raise ValueError("No one hot encoding found in subtask dto!")


class ProtSpaceTask(TaskInterface):

    def __init__(self, load_embeddings_strategy, method: str, config: Dict):
        self.load_embeddings_strategy = load_embeddings_strategy
        self.config = config
        self.method = method

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        # TODO One Hot Encodings?
        embedding_map = self.load_embeddings_strategy(self)
        protspace_headers = list(embedding_map.keys())

        dimensions = self.config.pop('n_components')
        data_processor = DataProcessor(config=self.config)
        # TODO Metadata
        metadata = pd.DataFrame({"identifier": protspace_headers})

        logger.info(f"Applying {self.method.upper()} reduction. Dimensions: {dimensions}. Config: {self.config}")
        reduction = data_processor.process_reduction(np.array(list(embedding_map.values())), self.method,
                                                     dims=dimensions, )
        output = data_processor.create_output(metadata=metadata, reductions=[reduction], headers=protspace_headers)
        return TaskDTO.finished(result=output)
