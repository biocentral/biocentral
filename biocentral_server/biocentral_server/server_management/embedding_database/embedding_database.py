import io
import hashlib
import h5py
import base64

from tqdm import tqdm
from pathlib import Path
from datetime import datetime
from biotrainer.input_files import BiotrainerSequenceRecord
from typing import List, Dict, Tuple, Any, Optional, Generator

from .database_strategy import DatabaseStrategy
from .postgresql_strategy import PostgreSQLStrategy

from ...utils import get_logger

logger = get_logger(__name__)


def dict_chunks(dct: Dict[str, str], n) -> Generator[Dict[str, str], None, None]:
    """Yield successive n-sized chunks from dct."""
    lst = [(key, value) for key, value in dct.items()]
    for i in range(0, len(lst), n):
        chunk = {key: value for (key, value) in lst[i:i + n]}
        yield chunk


class EmbeddingsDatabase:
    def __init__(self, postgres_config):
        self.strategy: Optional[DatabaseStrategy] = None
        self.strategy = PostgreSQLStrategy()
        self.strategy.init_db(postgres_config)

        logger.info(f"Using database: PostgreSQL")

    def clear_embeddings(self, sequence=None, model_name=None):
        return self.strategy.clear_embeddings(sequence, model_name)

    @staticmethod
    def unify_seqs_with_embeddings(seqs: Dict[str, str], embds: Dict[str, Any]) -> List[BiotrainerSequenceRecord]:
        return [BiotrainerSequenceRecord(seq_id=seq_id, seq=seq, embedding=embds.get(seq_id))
                for seq_id, seq in seqs.items() if embds.get(seq_id) is not None]

    def _prepare_embedding_data(self, sequence, embedder_name, per_sequence, per_residue):
        hash_key = self.strategy.generate_sequence_hash(sequence)
        compressed_per_sequence = self.strategy.compress_embedding(per_sequence)
        compressed_per_residue = self.strategy.compress_embedding(per_residue)
        return (hash_key, len(sequence), datetime.utcnow(), embedder_name,
                compressed_per_sequence, compressed_per_residue)

    def save_embeddings(self, embd_records: List[BiotrainerSequenceRecord], embedder_name, reduced: bool):
        # TODO [Refactoring] Improve .onnx handling
        if self.is_onnx_model(embedder_name):
            embedder_name = self.get_onnx_model_hash(embedder_name)

        embedding_data = [self._prepare_embedding_data(sequence=embd_record.seq,
                                                       embedder_name=embedder_name,
                                                       per_sequence=embd_record.embedding if reduced else None,
                                                       per_residue=embd_record.embedding if not reduced else None)
                          for embd_record in embd_records]
        self.strategy.save_embeddings(embedding_data)

    def filter_existing_embeddings(self, sequences: Dict[str, str],
                                   embedder_name: str,
                                   reduced: bool) -> Tuple[Dict[str, str], Dict[str, str]]:
        """
        Filter the database for existing embeddings.

        :param sequences: Dictionary of sequences (seq_hash -> sequence).
        :param embedder_name: Name of the embedder.
        :param reduced: If per-sequence embeddings should be filtered.
        :return: A tuple containing (existing, non_existing) embeddings
        """
        if self.is_onnx_model(embedder_name):
            embedder_name = self.get_onnx_model_hash(embedder_name)

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
                       reduced: bool) -> List[BiotrainerSequenceRecord]:
        if ".onnx" in embedder_name:
            embedder_name = self.get_onnx_model_hash(embedder_name)

        max_batch_size_reading = 2500

        if len(sequences) < max_batch_size_reading:
            result = self.strategy.get_embeddings(sequences=sequences, embedder_name=embedder_name)
            return [BiotrainerSequenceRecord(seq_id=seq_id, seq=sequences[seq_id],
                                             embedding=embd.get("per_sequence" if reduced else "per_residue"))
                    for seq_id, embd in result.items()]

        result = []
        for chunk in tqdm(dict_chunks(sequences, max_batch_size_reading), desc="Reading embeddings from database"):
            get_result = self.strategy.get_embeddings(sequences=chunk, embedder_name=embedder_name)
            result.extend([BiotrainerSequenceRecord(seq_id=seq_id, seq=sequences[seq_id],
                                                    embedding=embd.get("per_sequence" if reduced else "per_residue"))
                           for seq_id, embd in get_result.items()])
        return result

    def delete_embeddings_by_model(self, embedder_name: str) -> bool:
        if self.is_onnx_model(embedder_name):
            embedder_name = self.get_onnx_model_hash(embedder_name)
        return self.strategy.delete_embeddings_by_model(embedder_name)

    @staticmethod
    def export_embeddings_task_result_to_h5_bytes_string(embd_records: List[BiotrainerSequenceRecord]) -> str:
        h5_io = io.BytesIO()
        with h5py.File(h5_io, 'w') as embeddings_file:
            for embd_record in embd_records:
                seq_hash = embd_record.get_hash()
                embeddings_file.create_dataset(seq_hash, data=embd_record.embedding, compression="gzip", chunks=True)
                embeddings_file[seq_hash].attrs["original_id"] = embd_record.seq_id

        h5_io.seek(0)
        h5_base64 = base64.b64encode(h5_io.getvalue()).decode('utf-8')
        h5_io.close()
        return h5_base64

    @staticmethod
    def is_onnx_model(embedder_name: str) -> bool:
        return ".onnx" in embedder_name or "onnx/" in embedder_name

    @staticmethod
    def get_onnx_model_hash(onnx_path: str):
        return "onnx/" + hashlib.md5(onnx_path.encode('utf8')).hexdigest()
