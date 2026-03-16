from typing import Callable, Dict, List

from biotrainer.embedders import get_predefined_embedder_names
from biotrainer.input_files import BiotrainerSequenceRecord

from .embed import compute_embeddings, compute_memory_encodings

from ..server_management import (
    TaskInterface,
    TaskDTO,
    EmbeddingsDatabase,
    EmbeddingDatabaseFactory,
    TaskStatus,
    EmbeddingProgress,
)


class CalculateEmbeddingsTask(TaskInterface):
    """Calculate embeddings via biotrainer embeddings service adapter using the embeddings database"""

    def __init__(
        self,
        embedder_name: str,
        sequence_input: List[BiotrainerSequenceRecord],
        reduced: bool,
        use_half_precision: bool,
        custom_tokenizer_config: str = None,
    ):
        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.custom_tokenizer_config = custom_tokenizer_config

    def _read_sequence_input(self) -> Dict[str, str]:
        if isinstance(self.sequence_input, List):
            return {
                seq_record.get_hash(): str(seq_record.seq)
                for seq_record in self.sequence_input
            }
        assert False, f"Unknown sequence input type: {type(self.sequence_input)}"

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        all_seqs = self._read_sequence_input()

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        for progress in compute_embeddings(
            embedder_name=self.embedder_name,
            custom_tokenizer_config=self.custom_tokenizer_config,
            all_seqs=all_seqs,
            reduced=self.reduced,
            use_half_precision=self.use_half_precision,
            embeddings_db=embeddings_db,
        ):
            update_dto_callback(
                TaskDTO(
                    status=TaskStatus.RUNNING,
                    embedding_progress=progress,
                )
            )

        return TaskDTO(status=TaskStatus.FINISHED, embedded_sequences=all_seqs)


class _MemoryEmbeddingsTask(CalculateEmbeddingsTask):
    """Calculate embeddings, but store them in RAM, not in the database (OHE, Random, etc.)"""

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        assert self.embedder_name in get_predefined_embedder_names()

        all_seqs = self._read_sequence_input()
        memory_embeddings = compute_memory_encodings(
            embedder_name=self.embedder_name, all_seqs=all_seqs, reduced=self.reduced
        )
        len_memory_embeddings = len(memory_embeddings)
        update_dto_callback(
            TaskDTO(
                status=TaskStatus.RUNNING,
                embedding_progress=EmbeddingProgress(
                    current=len_memory_embeddings, total=len_memory_embeddings
                ),
            )
        )

        return TaskDTO(status=TaskStatus.FINISHED, embeddings=memory_embeddings)


class LoadEmbeddingsTask(TaskInterface):
    """Load Embeddings as Triples to Memory"""

    def __init__(
        self,
        embedder_name: str,
        sequence_input: List[BiotrainerSequenceRecord],
        reduced: bool,
        use_half_precision: bool,
        custom_tokenizer_config: str = None,
    ):
        if use_half_precision:
            embedder_name += "-half"

        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.custom_tokenizer_config = custom_tokenizer_config

    def _handle_memory_embedding(self):
        memory_task = _MemoryEmbeddingsTask(
            embedder_name=self.embedder_name,
            sequence_input=self.sequence_input,
            reduced=self.reduced,
            use_half_precision=False,
        )
        memory_dto = None
        for dto in self.run_subtask(memory_task):
            memory_dto = dto

        if not memory_dto:
            return TaskDTO.errored("Could not compute memory embeddings!")

        # Unify with original input
        record_ids2embd = {
            embd_record.get_hash(): embd_record.embedding
            for embd_record in memory_dto.embeddings
        }

        try:
            input_with_embeddings = [
                seq_record.copy_with_embedding(
                    embedding=record_ids2embd[seq_record.get_hash()]
                )
                for seq_record in self.sequence_input
            ]
            return TaskDTO(status=TaskStatus.FINISHED, embeddings=input_with_embeddings)
        except KeyError as e:
            return TaskDTO.errored(f"Could not find embedding for sequence id: {e}")

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        if self.embedder_name in get_predefined_embedder_names():
            return self._handle_memory_embedding()

        calculate_task = CalculateEmbeddingsTask(
            embedder_name=self.embedder_name,
            sequence_input=self.sequence_input,
            reduced=self.reduced,
            use_half_precision=self.use_half_precision,
            custom_tokenizer_config=self.custom_tokenizer_config,
        )
        calculate_dto = None
        for dto in self.run_subtask(calculate_task):
            calculate_dto = dto
            if calculate_dto.embedding_progress is not None:
                update_dto_callback(calculate_dto)

        if not calculate_dto or calculate_dto.embedded_sequences is None:
            return TaskDTO.errored("Calculating of embeddings failed before loading!")

        embedded_sequences = calculate_dto.embedded_sequences

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        embd_records = embeddings_db.get_embeddings(
            sequences=embedded_sequences,
            embedder_name=self.embedder_name,
            reduced=self.reduced,
        )
        record_ids2embd = {
            embd_record.get_hash(): embd_record.embedding
            for embd_record in embd_records
        }
        missing = [
            seq_id
            for seq_id in embedded_sequences.keys()
            if seq_id not in record_ids2embd
        ]

        if len(missing) > 0:
            # TODO Add retry of embedding calculation
            return TaskDTO.errored(
                f"Missing number of embeddings before loading: {len(missing)}"
            )

        # Unify with original input
        try:
            input_with_embeddings = [
                seq_record.copy_with_embedding(
                    embedding=record_ids2embd[seq_record.get_hash()]
                )
                for seq_record in self.sequence_input
            ]
            return TaskDTO(status=TaskStatus.FINISHED, embeddings=input_with_embeddings)
        except KeyError as e:
            return TaskDTO.errored(f"Could not find embedding for sequence id: {e}")


class ExportEmbeddingsTask(TaskInterface):
    """Calculate Embeddings and Export to H5"""

    def __init__(
        self,
        embedder_name: str,
        sequence_input: List[BiotrainerSequenceRecord],
        reduced: bool,
        use_half_precision: bool,
        custom_tokenizer_config: str = None,
    ):
        # TODO [Refactoring] Maybe completely remove use_half_precision and default to False
        if use_half_precision:
            embedder_name += "-half"

        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.custom_tokenizer_config = custom_tokenizer_config

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        load_task = LoadEmbeddingsTask(
            embedder_name=self.embedder_name,
            sequence_input=self.sequence_input,
            reduced=self.reduced,
            use_half_precision=self.use_half_precision,
            custom_tokenizer_config=self.custom_tokenizer_config,
        )

        load_dto = None
        for dto in self.run_subtask(load_task):
            load_dto = dto
            if load_dto.embedding_progress is not None:
                update_dto_callback(load_dto)

        if not load_dto or load_dto.embeddings is None:
            return TaskDTO.errored("Loading of embeddings failed before export!")

        h5_string = EmbeddingsDatabase.export_embeddings_task_result_to_h5_bytes_string(
            load_dto.embeddings
        )
        return TaskDTO(status=TaskStatus.FINISHED, embeddings_file=h5_string)
