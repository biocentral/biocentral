from pathlib import Path

from typing import Callable, List
from biotrainer.training import BiotrainerModel
from biotrainer_core.data_classes import SequenceData, Protocol

from ..utils import get_logger
from ..server_management import (
    TaskInterface,
    TaskDTO,
    FileContextManager,
    TaskStatus,
    PreEmbedMixin,
)

logger = get_logger(__name__)


class BiotrainerInferenceTask(TaskInterface, PreEmbedMixin):
    def __init__(self, model_out_path: Path, sequence_input: List[SequenceData]):
        super().__init__()
        self.model_out_path = model_out_path
        self.sequence_input = sequence_input

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        file_context_manager = FileContextManager()
        with file_context_manager.storage_dir_read(
            self.model_out_path
        ) as model_out_path:
            biotrainer_model = BiotrainerModel.from_training_result(
                model_out_path / "out.yml"
            )
            inferencer = biotrainer_model.inferencer()
            iom = biotrainer_model.inference_output_manager()

            embedder_name = iom.embedder_name()
            reduced = iom.protocol() in Protocol.using_per_sequence_embeddings()
            error_dto, embeddings = self._pre_embed_with_db(
                embedder_name=embedder_name,
                sequence_input=self.sequence_input,
                reduced=reduced,
                update_dto_callback=update_dto_callback,
            )
            if error_dto:
                return error_dto

            embeddings = {
                embd_record.get_hash(): embd_record.embedding
                for embd_record in embeddings
            }
            inference_result = inferencer.from_embeddings(embeddings=embeddings)

            hash2id = {
                seq_record.get_hash(): seq_record.seq_id
                for seq_record in self.sequence_input
            }
            inference_result = inference_result.replace_seq_ids(hash2id=hash2id)
            return TaskDTO(
                status=TaskStatus.FINISHED, biotrainer_inference_result=inference_result
            )
