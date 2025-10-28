from pathlib import Path
from biotrainer.protocols import Protocol
from typing import Callable, Optional, List
from biotrainer.inference import Inferencer
from biotrainer.input_files import BiotrainerSequenceRecord

from ..embeddings import LoadEmbeddingsTask
from ..server_management import (
    TaskInterface,
    TaskDTO,
    FileContextManager,
)


class BiotrainerInferenceTask(TaskInterface):
    def __init__(
        self, model_out_path: Path, seq_records: List[BiotrainerSequenceRecord]
    ):
        super().__init__()
        self.model_out_path = model_out_path
        self.seq_records = seq_records

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
            embeddings = self._pre_embed_with_db(
                embedder_name=embedder_name,
                all_seqs=self.seq_records,
                reduced=reduced,
                update_dto_callback=update_dto_callback,
            )

            # TODO Avoid unnecessary conversion in biotrainer
            embeddings = {
                embd_record.seq_id: embd_record.embedding for embd_record in embeddings
            }
            predictions = inferencer.from_embeddings(embeddings=embeddings)

            print(predictions)
            return TaskDTO.finished(result=predictions)

    def _pre_embed_with_db(
        self,
        embedder_name: str,
        all_seqs: List[BiotrainerSequenceRecord],
        reduced: bool,
        update_dto_callback: Callable,
    ) -> List[BiotrainerSequenceRecord]:
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
            if "embedding_current" in load_dto.update:
                update_dto_callback(load_dto)

        if not load_dto:
            raise Exception("Could not compute embeddings!")

        missing = load_dto.update["missing"]
        embeddings: List[BiotrainerSequenceRecord] = load_dto.update["embeddings"]
        if len(missing) > 0:
            return TaskDTO.failed(
                error=f"Missing number of embeddings before inference: {len(missing)}"
            )

        return embeddings
