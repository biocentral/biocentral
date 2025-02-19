import io
import h5py
import base64
import logging

from tqdm import tqdm
from pathlib import Path
from datetime import datetime
from collections import namedtuple
from typing import List, Dict, Tuple, Any, Optional, Generator

from .tinydb_strategy import TinyDBStrategy
from .database_strategy import DatabaseStrategy
from .postgresql_strategy import PostgreSQLStrategy

logger = logging.getLogger(__name__)

EmbeddingsDatabaseTriple = namedtuple("EmbeddingsDatabaseTriple", ["id", "seq", "embd"])


def dict_chunks(dct: Dict[str, str], n) -> Generator[Dict[str, str], None, None]:
    """Yield successive n-sized chunks from dct."""
    lst = [(key, value) for key, value in dct.items()]
    for i in range(0, len(lst), n):
        chunk = {key: value for (key, value) in lst[i:i + n]}
        yield chunk


class EmbeddingsDatabase:
    def __init__(self, config):
        self.strategy: Optional[DatabaseStrategy] = None
        use_postgresql = config.get("USE_POSTGRESQL", False)
        try:
            self.strategy = PostgreSQLStrategy() if use_postgresql else TinyDBStrategy()
            self.strategy.init_db(config)
        except Exception as e:
            logger.error(f"Failed to init database strategy with exception {e}")
            logger.error(f"Trying to fall back to tindydb strategy..")
            self.strategy = TinyDBStrategy()
            self.strategy.init_db(config)

        logger.info(f"Using database: {'PostgreSQL' if use_postgresql else 'TinyDB'}")

    def clear_embeddings(self, sequence=None, model_name=None):
        return self.strategy.clear_embeddings(sequence, model_name)

    @staticmethod
    def unify_seqs_with_embeddings(seqs: Dict[str, str], embds: Dict[str, Any]) -> List[EmbeddingsDatabaseTriple]:
        return [EmbeddingsDatabaseTriple(seq_id, seq, embds.get(seq_id)) for seq_id, seq in seqs.items() if
                embds.get(seq_id) is not None]

    def _prepare_embedding_data(self, sequence, embedder_name, per_sequence, per_residue):
        hash_key = self.strategy.generate_sequence_hash(sequence)
        compressed_per_sequence = self.strategy.compress_embedding(per_sequence)
        compressed_per_residue = self.strategy.compress_embedding(per_residue)
        return (hash_key, len(sequence), datetime.utcnow(), embedder_name,
                compressed_per_sequence, compressed_per_residue)

    def save_embeddings(self, ids_seqs_embds: List[EmbeddingsDatabaseTriple], embedder_name, reduced: bool):
        embedding_data = [self._prepare_embedding_data(sequence=embedding_triple.seq,
                                                       embedder_name=embedder_name,
                                                       per_sequence=embedding_triple.embd if reduced else None,
                                                       per_residue=embedding_triple.embd if not reduced else None)
                          for embedding_triple in ids_seqs_embds]
        self.strategy.save_embeddings(embedding_data)

    def filter_existing_embeddings(self, sequences: Dict[str, str],
                                   embedder_name: str,
                                   reduced: bool) -> Tuple[Dict[str, str], Dict[str, str]]:
        max_batch_size_filtering = 50000
        if len(sequences) < max_batch_size_filtering:
            return self.strategy.filter_existing_embeddings(sequences, embedder_name, reduced)

        exist_result = {}
        non_exist_result = {}
        for chunk in tqdm(dict_chunks(sequences, max_batch_size_filtering),
                          desc="Filtering existing sequences in database"):
            exist_chunk, non_exist_chunk = self.strategy.filter_existing_embeddings(chunk, embedder_name,
                                                                                    reduced)
            exist_result.update(exist_chunk)
            non_exist_result.update(non_exist_chunk)

        return exist_result, non_exist_result

    def get_embeddings(self, sequences: Dict[str, str],
                       embedder_name: str,
                       reduced: bool) -> List[EmbeddingsDatabaseTriple]:
        max_batch_size_reading = 2500

        if len(sequences) < max_batch_size_reading:
            result = self.strategy.get_embeddings(sequences=sequences, embedder_name=embedder_name)
            return [EmbeddingsDatabaseTriple(id=seq_id, seq=sequences[seq_id],
                                             embd=embd.get("per_sequence" if reduced else "per_residue")) for
                    seq_id, embd in result.items()]

        result = []
        for chunk in tqdm(dict_chunks(sequences, max_batch_size_reading), desc="Reading embeddings from database"):
            get_result = self.strategy.get_embeddings(sequences=chunk, embedder_name=embedder_name)
            result.extend([EmbeddingsDatabaseTriple(id=seq_id, seq=sequences[seq_id],
                                                    embd=embd.get("per_sequence" if reduced else "per_residue")) for
                           seq_id, embd in get_result.items()])
        return result

    @staticmethod
    def export_embedding_triples_to_hdf5(triples: List[EmbeddingsDatabaseTriple], output_path: Path):
        with h5py.File(output_path, "w") as embeddings_file:
            for idx, triple in enumerate(triples):
                embeddings_file.create_dataset(str(idx), data=triple.embd, compression="gzip", chunks=True)
                embeddings_file[str(idx)].attrs[
                    "original_id"] = triple.id  # Follows biotrainer & bio_embeddings standard

    @staticmethod
    def export_embeddings_task_result_to_hdf5(embeddings_task_result: Dict[str, Any], output_path: Path):
        with h5py.File(output_path, "w") as embeddings_file:
            for idx, seq_id in enumerate(embeddings_task_result.keys()):
                embeddings = embeddings_task_result.get(seq_id)
                embeddings_file.create_dataset(str(idx), data=embeddings, compression="gzip", chunks=True)
                embeddings_file[str(idx)].attrs["original_id"] = seq_id

    @staticmethod
    def export_embeddings_task_result_to_hdf5_bytes_string(embeddings_task_result: Dict[str, Any]) -> str:
        h5_io = io.BytesIO()
        with h5py.File(h5_io, 'w') as embeddings_file:
            for idx, seq_id in enumerate(embeddings_task_result.keys()):
                embeddings = embeddings_task_result.get(seq_id)
                embeddings_file.create_dataset(str(idx), data=embeddings, compression="gzip", chunks=True)
                embeddings_file[str(idx)].attrs["original_id"] = seq_id

        h5_io.seek(0)
        h5_base64 = base64.b64encode(h5_io.getvalue()).decode('utf-8')
        h5_io.close()
        return h5_base64