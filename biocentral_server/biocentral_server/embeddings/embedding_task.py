import tempfile
from pathlib import Path

import numpy as np

from tqdm import tqdm
from typing import Callable, List, Dict

from biotrainer.protocols import Protocol
from biotrainer.utilities import read_FASTA, get_device

from .embed import compute_embeddings_and_save_to_db

from ..server_management import (TaskInterface, TaskDTO, EmbeddingsDatabase, EmbeddingsDatabaseTriple,
                                 EmbeddingDatabaseFactory, FileContextManager)


def _postprocess_embeddings(embedding_triples: List[EmbeddingsDatabaseTriple],
                            do_rounding=False,
                            round_decimals=4):
    # TODO [Optimization] Check if tolist() is costly regarding RAM
    if do_rounding:
        return {
            triple.id: np.round(triple.embd.cpu().numpy(), round_decimals).tolist()
            for triple in
            tqdm(embedding_triples, desc=f"Rounding embeddings to {round_decimals} decimals..")
        }
    return {triple.id: triple.embd.cpu().numpy().tolist() for triple in embedding_triples}


class OneHotEncodeTask(TaskInterface):
    def __init__(self, sequences: Dict[str, str], protocol):
        self.sequences = sequences
        self.protocol = Protocol.from_string(protocol) if isinstance(protocol, str) else protocol

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        with tempfile.TemporaryDirectory() as tmpdir:
            embedding_triples = compute_embeddings_and_save_to_db(embedder_name="one_hot_encoding",
                                                                  all_seqs=self.sequences,
                                                                  embeddings_out_path=Path(tmpdir),
                                                                  reduce_by_protocol=self.protocol,
                                                                  use_half_precision=False,
                                                                  device="cpu")
            post_processed_embeddings = _postprocess_embeddings(embedding_triples=embedding_triples, do_rounding=False,
                                                                round_decimals=4)
        return TaskDTO.finished(result={"one_hot_encoding": post_processed_embeddings})


class EmbeddingTask(TaskInterface):
    def __init__(self, embedder_name: str, sequence_file_path, embeddings_out_path, protocol, use_half_precision, device):
        self.embedder_name = embedder_name
        self.sequence_file_path = sequence_file_path
        self.embeddings_out_path = embeddings_out_path
        self.protocol = Protocol.from_string(protocol) if isinstance(protocol, str) else protocol
        self.use_half_precision = use_half_precision
        self.device = get_device(device)

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        file_context_manager = FileContextManager()
        with file_context_manager.storage_read(self.sequence_file_path) as seq_file_path:
            all_seq_records = read_FASTA(str(seq_file_path))
            all_seqs = {seq.id: str(seq.seq) for seq in all_seq_records}

        embedder_name = self.embedder_name
        if self.use_half_precision:
            embedder_name += "-HalfPrecision"

        embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
        with file_context_manager.storage_write(self.embeddings_out_path) as embeddings_out_path:
            embedding_triples = compute_embeddings_and_save_to_db(embedder_name=self.embedder_name,
                                                                  all_seqs=all_seqs,
                                                                  embeddings_out_path=embeddings_out_path,
                                                                  reduce_by_protocol=self.protocol,
                                                                  use_half_precision=self.use_half_precision,
                                                                  device=self.device,
                                                                  embeddings_db=embeddings_db)

            post_processed_embeddings = _postprocess_embeddings(embedding_triples=embedding_triples, do_rounding=False,
                                                                round_decimals=4)
            del embedding_triples

        return TaskDTO.finished(result={"embeddings_file": {embedder_name: post_processed_embeddings}},
                                on_result_retrieval_hook=lambda
                                    result: {
                                    "embeddings_file": EmbeddingsDatabase.export_embeddings_task_result_to_hdf5_bytes_string(
                                        result["embeddings_file"][embedder_name])})
