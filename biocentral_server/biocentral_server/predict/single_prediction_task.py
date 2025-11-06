from typing import Callable, Dict, List, Optional, Tuple
from biotrainer.protocols import Protocol
from biotrainer.input_files import BiotrainerSequenceRecord

from .models.base_model import BaseModel

from ..utils import get_logger
from ..embeddings import LoadEmbeddingsTask
from ..server_management import TaskInterface, TaskDTO, TaskStatus

logger = get_logger(__name__)


class SinglePredictionTask(TaskInterface):
    def __init__(
        self, model: BaseModel, sequence_input: List[BiotrainerSequenceRecord], device
    ):
        self.model = model
        self.model_metadata = model.get_metadata()
        self.sequence_input = sequence_input
        self.device = device

    def _remap_predictions(self, predictions: Dict[str, List]):
        """Embeddings have seq_hash -> embedding, we need seq_id -> prediction"""
        seq_hash_to_ids = {}
        for sequence in self.sequence_input:
            seq_hash = sequence.get_hash()
            if seq_hash not in seq_hash_to_ids:
                seq_hash_to_ids[seq_hash] = []
            seq_hash_to_ids[seq_hash].append(sequence.seq_id)

        result = {}
        for seq_hash, seq_ids in seq_hash_to_ids.items():
            for seq_id in seq_ids:
                result[seq_id] = predictions[seq_hash]

        if len(self.sequence_input) != len(result):
            logger.warn(
                f"Encountered different number of input and result predictions: "
                f"{len(self.sequence_input)}, {len(result)}"
            )
        return result

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        # TODO CHECK SEQUENCE RECORDS
        error_dto, embed_records = self._embed_sequences()
        if error_dto:
            return error_dto

        embeddings = {
            embd_record.seq_id: embd_record.embedding for embd_record in embed_records
        }
        predictions = self.model.predict(
            sequences={
                seq_record.get_hash(): seq_record.seq
                for seq_record in self.sequence_input
            },
            embeddings=embeddings,
        )
        predictions = self._remap_predictions(predictions=predictions)
        return TaskDTO(status=TaskStatus.FINISHED, predictions=predictions)

    def _embed_sequences(
        self,
    ) -> Tuple[Optional[TaskDTO], List[BiotrainerSequenceRecord]]:
        reduced = (
            True
            if self.model_metadata.protocol in Protocol.using_per_sequence_embeddings()
            else False
        )
        load_embeddings_task = LoadEmbeddingsTask(
            embedder_name=self.model_metadata.embedder,
            sequence_input=self.sequence_input,
            reduced=reduced,
            use_half_precision=False,
            device=self.device,
        )
        load_dto = None
        for dto in self.run_subtask(load_embeddings_task):
            load_dto = dto

        if not load_dto or load_dto.embeddings is None:
            return TaskDTO(
                status=TaskStatus.FAILED,
                error="Loading of embeddings failed before export!",
            ), []

        return None, load_dto.embeddings
