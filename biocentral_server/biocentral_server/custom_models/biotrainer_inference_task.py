from pathlib import Path

from typing import Callable, List
from biotrainer.training import BiotrainerModel
from biotrainer.training.output_files import InferenceOutputManager
from biotrainer_core.data_classes import SequenceData, Protocol

from ..server_management.shared_endpoint_models import Prediction
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
                    value=pred,
                )
            ]
            for seq_hash, pred in predictions["mapped_predictions"].items()
        }

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        file_context_manager = FileContextManager()
        with file_context_manager.storage_dir_read(
            self.model_out_path
        ) as model_out_path:
            biotrainer_model = BiotrainerModel.from_training_result(model_out_path)
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
            predictions = inferencer.from_embeddings(embeddings=embeddings)
            predictions = self._to_prediction_model(
                iom=iom, predictions=predictions
            )  # TODO Deprecate

            return TaskDTO(status=TaskStatus.FINISHED, predictions=predictions)
