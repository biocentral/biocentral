import h5py
import logging

from pathlib import Path
from flask import current_app
from collections import namedtuple
from typing import List, Dict, Tuple, Any

from .tinydb_strategy import TinyDBStrategy
from .postgresql_strategy import PostgreSQLStrategy

logger = logging.getLogger(__name__)

EmbeddingsDatabaseTriple = namedtuple("EmbeddingsDatabaseTriple", ["id", "seq", "embd"])


class EmbeddingsDatabase:
    def __init__(self):
        self.strategy = None

    def init_app(self, app):
        self.strategy = PostgreSQLStrategy() if app.config.get('USE_POSTGRESQL', False) else TinyDBStrategy()
        self.strategy.init_app(app)

    def save_embedding(self, sequence, embedder_name, per_sequence, per_residue):
        return self.strategy.save_embedding(sequence, embedder_name, per_sequence, per_residue)

    def get_embedding(self, sequence, embedder_name):
        return self.strategy.get_embedding(sequence, embedder_name)

    def clear_embeddings(self, sequence=None, model_name=None):
        return self.strategy.clear_embeddings(sequence, model_name)

    @staticmethod
    def unify_seqs_with_embeddings(seqs: Dict[str, str], embds: Dict[str, Any]) -> List[EmbeddingsDatabaseTriple]:
        return [EmbeddingsDatabaseTriple(seq_id, seq, embds.get(seq_id)) for seq_id, seq in seqs.items() if
                embds.get(seq_id) is not None]

    def save_embeddings(self, ids_seqs_embds: List[EmbeddingsDatabaseTriple], embedder_name, reduced: bool):
        for embedding_triple in ids_seqs_embds:
            self.save_embedding(sequence=embedding_triple.seq,
                                embedder_name=embedder_name,
                                per_residue=None if reduced else embedding_triple.embd,
                                per_sequence=embedding_triple.embd if reduced else None)

    def _embedding_exists(self, sequence: str, embedder_name: str, reduced: bool) -> bool:
        embedding = self.get_embedding(sequence, embedder_name)
        return embedding and (embedding['per_sequence'] if reduced else embedding['per_residue']) is not None

    def filter_existing_embeddings(self, sequences: Dict[str, str],
                                   embedder_name: str,
                                   reduced: bool) -> Tuple[Dict[str, str], Dict[str, str]]:
        existing = {seq_id: seq for seq_id, seq in sequences.items() if
                    self._embedding_exists(seq, embedder_name, reduced)}
        non_existing = {seq_id: seq for seq_id, seq in sequences.items() if seq_id not in existing}
        return existing, non_existing

    def get_embeddings(self, sequences: Dict[str, str],
                       embedder_name: str,
                       reduced: bool) -> List[EmbeddingsDatabaseTriple]:
        result = []
        for seq_id, seq in sequences.items():
            embedding_dict = self.get_embedding(sequence=seq, embedder_name=embedder_name)
            if embedding_dict:
                embedding = embedding_dict.get("per_sequence" if reduced else "per_residue")
                if embedding is not None:
                    result.append(EmbeddingsDatabaseTriple(seq_id, seq, embedding))
                else:
                    current_app.logger.error(f"Embedding could not be found for sequence: {seq_id}")
            else:
                current_app.logger.error(f"Embedding could not be found for sequence: {seq_id}")
        return result

    @staticmethod
    def export_embeddings_to_hdf5(triples: List[EmbeddingsDatabaseTriple], output_path: Path):
        with h5py.File(output_path, "w") as embeddings_file:
            for idx, triple in enumerate(triples):
                embeddings_file.create_dataset(str(idx), data=triple.embd, compression="gzip", chunks=True)
                embeddings_file[str(idx)].attrs["original_id"] = triple.id  # Follows biotrainer & bio_embeddings standard
