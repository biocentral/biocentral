from pathlib import Path

from biotrainer.protocols import Protocol
from biotrainer.inference import Inferencer
from typing import Callable, Optional, List, Tuple
from biotrainer.output_files import InferenceOutputManager
from biotrainer.input_files import BiotrainerSequenceRecord

from ..server_management.shared_endpoint_models import Prediction
from ..utils import get_logger
from ..embeddings import LoadEmbeddingsTask
from ..server_management import (
    TaskInterface,
    TaskDTO,
    FileContextManager,
    TaskStatus,
)

logger = get_logger(__name__)


class BiotrainerInferenceTask(TaskInterface):
    def __init__(
        self, model_out_path: Path, sequence_input: List[BiotrainerSequenceRecord]
    ):
        super().__init__()
        self.model_out_path = model_out_path
        self.sequence_input = sequence_input

    def _to_prediction_model(self, iom: InferenceOutputManager, predictions: dict):
        seq_hash_to_ids = {
            seq_record.get_hash(): seq_record.seq_id
            for seq_record in self.sequence_input
        }
        return {
            seq_hash_to_ids[seq_hash]: [
                Prediction(
                    model_name=iom._derived_values["model_hash"],  # TODO
                    prediction_name="inference",
                    protocol=iom.protocol().name,
                    prediction=pred,
                )
            ]
            for seq_hash, pred in predictions["mapped_predictions"].items()
        }

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        file_context_manager = FileContextManager()
        with file_context_manager.storage_dir_read(
            self.model_out_path
        ) as model_out_path:
            inferencer, iom = Inferencer.create_from_out_file(
                out_file_path=str(model_out_path / "out.yml"),
                automatic_path_correction=True,
            )
            embedder_name = iom.embedder_name()
            reduced = iom.protocol() in Protocol.using_per_sequence_embeddings()
            error_dto, embeddings = self._pre_embed_with_db(
                embedder_name=embedder_name,
                all_seqs=self.sequence_input,
                reduced=reduced,
                update_dto_callback=update_dto_callback,
            )
            if error_dto:
                return error_dto

            # TODO Avoid unnecessary conversion in biotrainer
            embeddings = {
                embd_record.get_hash(): embd_record.embedding
                for embd_record in embeddings
            }
            predictions = inferencer.from_embeddings(embeddings=embeddings)
            predictions = self._to_prediction_model(iom=iom, predictions=predictions)

            return TaskDTO(status=TaskStatus.FINISHED, predictions=predictions)

    def _pre_embed_with_db(
        self,
        embedder_name: str,
        all_seqs: List[BiotrainerSequenceRecord],
        reduced: bool,
        update_dto_callback: Callable,
    ) -> Tuple[Optional[TaskDTO], List[BiotrainerSequenceRecord]]:
        load_embedding_task = LoadEmbeddingsTask(
            embedder_name=embedder_name,
            custom_tokenizer_config=None,  # TODO
            sequence_input=all_seqs,
            reduced=reduced,
            use_half_precision=False,
            device="cuda:0",
        )
        load_dto: Optional[TaskDTO] = None
        for current_dto in self.run_subtask(load_embedding_task):
            load_dto = current_dto
            if load_dto.embedding_current is not None:
                update_dto_callback(load_dto)

        if not load_dto:
            return TaskDTO(
                status=TaskStatus.FAILED, error="Could not compute embeddings!"
            ), []

        embeddings: List[BiotrainerSequenceRecord] = load_dto.embeddings
        if len(embeddings) == 0:
            return TaskDTO(
                status=TaskStatus.FAILED,
                error="Did not receive embeddings for training!",
            ), []

        return None, embeddings
