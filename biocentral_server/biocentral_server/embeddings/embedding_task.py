from pathlib import Path
from typing import Callable, Dict, Union, List

from biotrainer.utilities import get_device
from biotrainer.embedders import get_predefined_embedder_names
from biotrainer.input_files import BiotrainerSequenceRecord, read_FASTA

from .embed import compute_embeddings, compute_memory_encodings

from ..server_management import TaskInterface, TaskDTO, EmbeddingsDatabase, EmbeddingDatabaseFactory, FileContextManager


class CalculateEmbeddingsTask(TaskInterface):
    """ Calculate embeddings via biotrainer embeddings service adapter using the embeddings database """

    def __init__(self, embedder_name: str, sequence_input: Union[List[BiotrainerSequenceRecord], Path], reduced: bool,
                 use_half_precision: bool, device, custom_tokenizer_config: str = None):
        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.device = get_device(device)
        self.custom_tokenizer_config = custom_tokenizer_config

    def _read_sequence_input(self) -> Dict[str, str]:
        if isinstance(self.sequence_input, List):
            return {seq_record.get_hash(): str(seq_record.seq) for seq_record in self.sequence_input}
        file_context_manager = FileContextManager()
        with file_context_manager.storage_read(self.sequence_input) as seq_file_path:
            all_seq_records = read_FASTA(str(seq_file_path))

        # This will make sure that only unique sequences are filtered
        return {seq_record.get_hash(): str(seq_record.seq) for seq_record in all_seq_records}

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        all_seqs = self._read_sequence_input()

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        for current, total in compute_embeddings(embedder_name=self.embedder_name,
                                                 custom_tokenizer_config=self.custom_tokenizer_config,
                                                 all_seqs=all_seqs,
                                                 reduced=self.reduced,
                                                 use_half_precision=self.use_half_precision,
                                                 device=self.device,
                                                 embeddings_db=embeddings_db):
            update_dto_callback(TaskDTO.running().add_update(update={"embedding_current": current,
                                                                     "embedding_total": total}))

        return TaskDTO.finished(result={"all_seqs": all_seqs})


class _MemoryEmbeddingsTask(CalculateEmbeddingsTask):
    """ Calculate embeddings, but store them in RAM, not in the database (OHE, Random, etc.) """

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        assert self.embedder_name in get_predefined_embedder_names()

        all_seqs = self._read_sequence_input()
        memory_embeddings = compute_memory_encodings(embedder_name=self.embedder_name, all_seqs=all_seqs,
                                                     reduced=self.reduced)
        len_memory_embeddings = len(memory_embeddings)
        update_dto_callback(TaskDTO.running().add_update(update={"embedding_current": len_memory_embeddings,
                                                                 "embedding_total": len_memory_embeddings}))

        return TaskDTO.finished(result={"embeddings": memory_embeddings})


class LoadEmbeddingsTask(TaskInterface):
    """ Load Embeddings as Triples to Memory """

    def __init__(self, embedder_name: str, sequence_input: Union[List[BiotrainerSequenceRecord], Path], reduced: bool,
                 use_half_precision: bool, device, custom_tokenizer_config: str = None):
        if use_half_precision:
            embedder_name += "-half"

        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.device = get_device(device)
        self.custom_tokenizer_config = custom_tokenizer_config

    def _handle_memory_embedding(self):
        memory_task = _MemoryEmbeddingsTask(embedder_name=self.embedder_name, sequence_input=self.sequence_input,
                                            reduced=self.reduced, use_half_precision=False, device=self.device)
        memory_dto = None
        for dto in self.run_subtask(memory_task):
            memory_dto = dto

        if not memory_dto:
            return TaskDTO.failed(error="Could not compute memory embeddings!")

        return TaskDTO.finished(result={"embeddings": memory_dto.update["embeddings"], "missing": []})

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        if self.embedder_name in get_predefined_embedder_names():
            return self._handle_memory_embedding()

        calculate_task = CalculateEmbeddingsTask(embedder_name=self.embedder_name, sequence_input=self.sequence_input,
                                                 reduced=self.reduced, use_half_precision=self.use_half_precision,
                                                 device=self.device,
                                                 custom_tokenizer_config=self.custom_tokenizer_config)
        calculate_dto = None
        for dto in self.run_subtask(calculate_task):
            calculate_dto = dto
            if "embedding_current" in calculate_dto.update:
                update_dto_callback(calculate_dto)

        if not calculate_dto or "all_seqs" not in calculate_dto.update:
            return TaskDTO.failed(error="Calculating of embeddings failed before loading!")

        all_seqs = calculate_dto.update["all_seqs"]

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        embd_records = embeddings_db.get_embeddings(sequences=all_seqs,
                                                    embedder_name=self.embedder_name,
                                                    reduced=self.reduced)
        record_ids = {embd_record.seq_id for embd_record in embd_records}
        missing = [seq_id for seq_id in all_seqs.keys() if seq_id not in record_ids]

        return TaskDTO.finished(result={"embeddings": embd_records, 'missing': missing})


class ExportEmbeddingsTask(TaskInterface):
    """ Calculate Embeddings and Export to H5 """

    def __init__(self, embedder_name: str, sequence_input: Union[List[BiotrainerSequenceRecord], Path], reduced: bool,
                 use_half_precision: bool, device, embeddings_out_path: Path, custom_tokenizer_config: str = None):
        # TODO [Refactoring] Maybe completely remove use_half_precision and default to False
        if use_half_precision:
            embedder_name += "-half"

        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.device = get_device(device)
        self.embeddings_out_path = embeddings_out_path
        self.custom_tokenizer_config = custom_tokenizer_config

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        load_task = LoadEmbeddingsTask(embedder_name=self.embedder_name, sequence_input=self.sequence_input,
                                       reduced=self.reduced, use_half_precision=self.use_half_precision,
                                       device=self.device,
                                       custom_tokenizer_config=self.custom_tokenizer_config)

        load_dto = None
        for dto in self.run_subtask(load_task):
            load_dto = dto
            if "embedding_current" in load_dto.update:
                update_dto_callback(load_dto)

        if not load_dto or "embeddings" not in load_dto.update:
            return TaskDTO.failed(error="Loading of embeddings failed before export!")

        missing = load_dto.update["missing"]
        embeddings: List[BiotrainerSequenceRecord] = load_dto.update["embeddings"]
        if len(missing) > 0:
            return TaskDTO.failed(error=f"Missing number of embeddings before export: {len(missing)}")

        h5_string = EmbeddingsDatabase.export_embeddings_task_result_to_h5_bytes_string(embeddings)
        return TaskDTO.finished(result={"embeddings_file": h5_string})
