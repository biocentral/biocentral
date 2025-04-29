from typing import Callable, Dict
from biotrainer.protocols import Protocol

from ..embeddings import LoadEmbeddingsTask
from .models.base_model import BaseModel
from ..server_management import TaskInterface, TaskDTO


class SinglePredictionTask(TaskInterface):
    def __init__(self, model: BaseModel, sequence_input: Dict[str, str], device):
        self.model = model
        self.model_metadata = model.get_metadata()
        self.sequence_input = sequence_input
        self.device = device

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        embeddings = self._embed_sequences()
        predictions = self.model.predict(sequences=self.sequence_input, embeddings=embeddings)
        return TaskDTO.finished(result={"predictions": predictions})

    def _embed_sequences(self):
        reduced = True if self.model_metadata.protocol in Protocol.using_per_sequence_embeddings() else False
        load_embeddings_task = LoadEmbeddingsTask(embedder_name=self.model_metadata.embedder,
                                                  sequence_input=self.sequence_input,
                                                  reduced=reduced,
                                                  use_half_precision=False,
                                                  device=self.device)
        load_dto = None
        for dto in self.run_subtask(load_embeddings_task):
            load_dto = dto

        if not load_dto:
            return TaskDTO.failed(error="Loading of embeddings failed before export!")

        missing = load_dto.update["missing"]
        embeddings = load_dto.update["embeddings"]
        if len(missing) > 0:
            return TaskDTO.failed(error=f"Missing number of embeddings before export: {len(missing)}")

        return {triple.id: triple.embd for triple in embeddings}
