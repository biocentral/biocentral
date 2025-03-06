from __future__ import annotations

import logging

import numpy as np
import pandas as pd

from typing import Callable, Dict

from biotrainer.protocols import Protocol
from biotrainer.embedders import EmbeddingService
from protspace.utils.prepare_json import DataProcessor

from .embedding_task import OneHotEncodeTask
from ..server_management import TaskInterface, TaskDTO, EmbeddingDatabaseFactory, FileContextManager

logger = logging.getLogger(__name__)


class ProtSpaceTask(TaskInterface):

    def __init__(self, embedder_name: str, sequences: Dict[str, str], method: str, config: Dict):
        self.embedder_name = embedder_name
        self.sequences = sequences

        self.method = method
        self.config = config

    def _load_embeddings(self) -> Dict[str, np.ndarray]:
        if self.embedder_name == "one_hot_encoding":
            return self._load_one_hot_encodings()
        return self._load_embeddings_via_sequences()

    def _load_embeddings_via_sequences(self) -> Dict[str, np.ndarray]:
        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        triples = embeddings_db.get_embeddings(sequences=self.sequences, embedder_name=self.embedder_name,
                                               reduced=True)
        return {triple.id: triple.embd for triple in triples}

    def _load_one_hot_encodings(self) -> Dict[str, np.ndarray]:
        file_context_manager = FileContextManager()
        # TODO [OPTIMIZATION] Create temporary directory in file system
        with file_context_manager.storage_write("/tmp/ohe.h5") as tmpfile:
            one_hot_encode_subtask = OneHotEncodeTask(sequences=self.sequences,
                                                      protocol=Protocol.using_per_sequence_embeddings()[0],
                                                      embeddings_out_path=tmpfile)
        current_dto = None
        for dto in self.run_subtask(one_hot_encode_subtask):
            current_dto = dto
        if current_dto:
            h5_file_path = current_dto.update["embeddings_file"]
            return EmbeddingService.load_embeddings(embeddings_file_path=str(h5_file_path))
        raise ValueError("No one hot encoding found in subtask dto!")

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        embedding_map = self._load_embeddings()
        protspace_headers = list(embedding_map.keys())

        dimensions = self.config.pop('n_components')
        data_processor = DataProcessor(config=self.config)
        metadata = pd.DataFrame({"identifier": protspace_headers})

        logger.info(f"Applying {self.method.upper()} reduction. Dimensions: {dimensions}. Config: {self.config}")
        reduction = data_processor.process_reduction(np.array(list(embedding_map.values())), self.method,
                                                     dims=dimensions, )
        output = data_processor.create_output(metadata=metadata, reductions=[reduction], headers=protspace_headers)
        return TaskDTO.finished(result=output)
