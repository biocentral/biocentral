import logging
import numpy as np
import pandas as pd

from typing import Callable, Dict
from protspace.utils.prepare_json import DataProcessor

from ..server_management import TaskInterface, TaskDTO, EmbeddingsDatabase

logger = logging.getLogger(__name__)


def load_embeddings_via_sequences(embeddings_db: EmbeddingsDatabase,
                                  embedder_name: str,
                                  sequences: Dict[str, str]) -> Dict[str, np.ndarray]:
    triples = embeddings_db.get_embeddings(sequences=sequences, embedder_name=embedder_name, reduced=True)
    return {triple.id: triple.embd for triple in triples}


class ProtSpaceTask(TaskInterface):

    def __init__(self, load_embeddings_strategy, method: str, dimensions: int):
        self.load_embeddings_strategy = load_embeddings_strategy
        self.dimensions = dimensions
        self.method = method

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        # TODO One Hot Encodings?
        embedding_map = self.load_embeddings_strategy()
        protspace_headers = list(embedding_map.keys())

        data_processor = DataProcessor(config={})
        # TODO Metadata
        metadata = pd.DataFrame({"identifier": protspace_headers})

        logger.info(f"Applying {self.method.upper()} (dims: {self.dimensions}) reduction")
        reduction = data_processor.process_reduction(np.array(list(embedding_map.values())), self.method, self.dimensions)
        output = data_processor.create_output(metadata=metadata, reductions=[reduction], headers=protspace_headers)
        return TaskDTO.finished(result=output)
