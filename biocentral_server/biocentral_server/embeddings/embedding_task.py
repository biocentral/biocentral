from pathlib import Path
from typing import Callable, Dict, Union

from biotrainer.utilities import read_FASTA, get_device

from .embed import compute_embeddings, compute_one_hot_encodings

from ..server_management import TaskInterface, TaskDTO, EmbeddingDatabaseFactory, FileContextManager


class _CalculateEmbeddingsTask(TaskInterface):
    """ Calculate embeddings via biotrainer embeddings service adapter using the embeddings database """
    def __init__(self, embedder_name: str, sequence_input: Union[Dict[str, str], Path], reduced: bool,
                 use_half_precision: bool, device):
        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.device = get_device(device)

    def _read_sequence_input(self) -> Dict[str, str]:
        if isinstance(self.sequence_input, Dict):
            return self.sequence_input
        file_context_manager = FileContextManager()
        with file_context_manager.storage_read(self.sequence_input) as seq_file_path:
            all_seq_records = read_FASTA(str(seq_file_path))
        return {seq.id: str(seq.seq) for seq in all_seq_records}

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        all_seqs = self._read_sequence_input()

        embedder_name = self.embedder_name
        if self.use_half_precision:
            embedder_name += "-half"

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        _ = compute_embeddings(embedder_name=self.embedder_name,
                               all_seqs=all_seqs,
                               reduced=self.reduced,
                               use_half_precision=self.use_half_precision,
                               device=self.device,
                               embeddings_db=embeddings_db)

        return TaskDTO.finished(result={"all_seqs": all_seqs})


class _OneHotEncodeTask(_CalculateEmbeddingsTask):
    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        all_seqs = self._read_sequence_input()
        ohe = compute_one_hot_encodings(all_seqs=all_seqs, reduced=self.reduced)
        return TaskDTO.finished(result={"ohe": ohe})


class LoadEmbeddingsTask(TaskInterface):
    """ Load Embeddings as Triples """

    def __init__(self, embedder_name: str, sequence_input: Union[Dict[str, str], Path], reduced: bool,
                 use_half_precision: bool, device):
        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.device = get_device(device)

    def _handle_ohe(self):
        ohe_task = _OneHotEncodeTask(embedder_name=self.embedder_name, sequence_input=self.sequence_input,
                                     reduced=self.reduced, use_half_precision=False, device=self.device)
        ohe_dto = None
        for dto in self.run_subtask(ohe_task):
            ohe_dto = dto

        if not ohe_dto:
            return TaskDTO.failed(error="Could not compute one-hot encoding!")

        return TaskDTO.finished(result={"embeddings": ohe_dto.update["ohe"], "missing": []})

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        if self.embedder_name == "one_hot_encoding":
            return self._handle_ohe()

        calculate_task = _CalculateEmbeddingsTask(embedder_name=self.embedder_name, sequence_input=self.sequence_input,
                                                  reduced=self.reduced, use_half_precision=self.use_half_precision,
                                                  device=self.device)
        calculate_dto = None
        for dto in self.run_subtask(calculate_task):
            calculate_dto = dto

        if not calculate_dto:
            return TaskDTO.failed(error="Calculating of embeddings failed before export!")

        all_seqs = calculate_dto.update["all_seqs"]

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        triples = embeddings_db.get_embeddings(sequences=all_seqs, embedder_name=self.embedder_name,
                                               reduced=self.reduced)
        triple_ids = {triple.id for triple in triples}
        missing = [seq_id for seq_id in all_seqs.keys() if seq_id not in triple_ids]

        return TaskDTO.finished(result={"embeddings": triples, 'missing': missing})


class ExportEmbeddingsTask(TaskInterface):
    """ Calculate Embeddings and Export to H5 """

    def __init__(self, embedder_name: str, sequence_input: Union[Dict[str, str], Path], reduced: bool,
                 use_half_precision: bool, device, embeddings_out_path: Path):
        self.embedder_name = embedder_name
        self.sequence_input = sequence_input
        self.reduced = reduced
        self.use_half_precision = use_half_precision
        self.device = get_device(device)
        self.embeddings_out_path = embeddings_out_path

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        load_task = LoadEmbeddingsTask(embedder_name=self.embedder_name, sequence_input=self.sequence_input,
                                                  reduced=self.reduced, use_half_precision=self.use_half_precision,
                                                  device=self.device)

        load_dto = None
        for dto in self.run_subtask(load_task):
            load_dto = dto

        if not load_dto:
            return TaskDTO.failed(error="Loading of embeddings failed before export!")

        missing = load_dto.update["missing"]
        embeddings = load_dto.update["embeddings"]
        if len(missing) > 0:
            return TaskDTO.failed(error=f"Missing number of embeddings before export: {len(missing)}")

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        file_context_manager = FileContextManager()

        with file_context_manager.storage_write(self.embeddings_out_path) as h5_out_path:
            _ = embeddings_db.export_embedding_triples_to_hdf5(embeddings, h5_out_path)
        return TaskDTO.finished(result={"embeddings_file": self.embeddings_out_path})
