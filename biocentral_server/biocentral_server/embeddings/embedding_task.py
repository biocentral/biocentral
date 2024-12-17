import numpy as np

from tqdm import tqdm
from typing import Any, Callable

from biotrainer.protocols import Protocol
from biotrainer.utilities import read_FASTA, get_device

from .embed import compute_embeddings_and_save_to_db

from ..server_management import TaskInterface, TaskDTO


class EmbeddingTask(TaskInterface):
    def __init__(self, embedder_name, sequence_file_path, embeddings_out_path, protocol, use_half_precision, device,
                 embeddings_database):
        self.embedder_name = embedder_name
        self.sequence_file_path = sequence_file_path
        self.embeddings_out_path = embeddings_out_path
        self.protocol = Protocol.from_string(protocol) if isinstance(protocol, str) else protocol
        self.use_half_precision = use_half_precision
        self.device = get_device(device)
        self.embeddings_database = embeddings_database

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        all_seq_records = read_FASTA(str(self.sequence_file_path))
        all_seqs = {seq.id: str(seq.seq) for seq in all_seq_records}
        embedder_name = self.embedder_name
        if self.use_half_precision:
            embedder_name += "-HalfPrecision"

        embedding_triples = compute_embeddings_and_save_to_db(embedder_name=self.embedder_name,
                                                              all_seqs=all_seqs,
                                                              embeddings_out_path=self.embeddings_out_path,
                                                              reduce_by_protocol=self.protocol,
                                                              use_half_precision=self.use_half_precision,
                                                              device=self.device,
                                                              database_instance=self.embeddings_database)

        processed_embeddings = {triple.id: triple.embd.cpu().numpy() for triple in embedding_triples}
        del embedding_triples

        round = False
        if round:
            processed_embeddings = self._round_embeddings(processed_embeddings)

        return TaskDTO.finished(result={"embeddings_file": {embedder_name: processed_embeddings}})

    @staticmethod
    def _round_embeddings(embeddings: dict, decimals: int = 4):
        return {
            sequence_id: np.round(embedding, decimals).tolist()
            for sequence_id, embedding in tqdm(embeddings.items(), desc=f"Rounding embeddings to {decimals} decimals..")
        }
