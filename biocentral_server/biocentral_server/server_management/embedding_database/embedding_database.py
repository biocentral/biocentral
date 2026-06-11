import hashlib

from tqdm import tqdm
from datetime import datetime
from typing import List, Dict, Tuple, Any, Generator
from biotrainer_core.data_classes import SequenceData
from biotrainer_core.h5_files import EmbeddingDatabaseDTO


from .database_strategy import DatabaseStrategy
from .postgresql_strategy import PostgreSQLStrategy

from ...utils import get_logger

logger = get_logger(__name__)


def dict_chunks(dct: Dict[str, str], n) -> Generator[Dict[str, str], None, None]:
    """Yield successive n-sized chunks from dct."""
    lst = [(key, value) for key, value in dct.items()]
    for i in range(0, len(lst), n):
        chunk = {key: value for (key, value) in lst[i : i + n]}
        yield chunk


class EmbeddingsDatabase:
    def __init__(self, postgres_config):
        self.strategy: DatabaseStrategy = PostgreSQLStrategy()
        self.strategy.init_db(postgres_config)

        logger.info("Using database: PostgreSQL")

    def clear_embeddings(self, sequence=None, model_name=None):
        return self.strategy.clear_embeddings(sequence, model_name)

    @staticmethod
    def _prepare_embedding_data(
        hash_key: str,
        seq_len: int,
        embedder_name,
        embd_per_sequence,
        embd_per_residue,
        keep: bool,
    ) -> EmbeddingDatabaseDTO:
        return EmbeddingDatabaseDTO(
            hash_key=hash_key,
            seq_len=seq_len,
            access_count=1,
            created_at=datetime.utcnow(),
            last_accessed=datetime.utcnow(),
            embedder_name=embedder_name,
            embd_per_sequence=embd_per_sequence,
            embd_per_residue=embd_per_residue,
            keep=keep,
        )

    def save_embeddings(
        self,
        embd_records: List[SequenceData],
        embedder_name: str,
        reduced: bool,
        keep: bool = False,
    ):
        """Save calculated embeddings to database."""
        # TODO [Refactoring] Improve .onnx handling
        if self.is_onnx_model(embedder_name):
            embedder_name = self.get_onnx_model_hash(embedder_name)

        embedding_data = [
            self._prepare_embedding_data(
                hash_key=embd_record.get_hash(),
                seq_len=len(embd_record.seq),
                embedder_name=embedder_name,
                embd_per_sequence=embd_record.embedding if reduced else None,
                embd_per_residue=embd_record.embedding if not reduced else None,
                keep=keep,
            )
            for embd_record in embd_records
        ]
        self.strategy.save_embeddings(embedding_data)

    def snack_embeddings(self, embedding_dtos: List[EmbeddingDatabaseDTO]):
        """Save embedding dtos as is directly to database."""
        self.strategy.save_embeddings(embedding_dtos)

    def filter_existing_embeddings(
        self, sequences: Dict[str, str], embedder_name: str, reduced: bool
    ) -> Tuple[Dict[str, str], Dict[str, str]]:
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
            return self.strategy.filter_existing_embeddings(
                sequences, embedder_name, reduced
            )

        exist_result = {}
        non_exist_result = {}
        for chunk in tqdm(
            dict_chunks(sequences, max_batch_size_filtering),
            desc="Filtering existing sequences in database",
        ):
            exist_chunk, non_exist_chunk = self.strategy.filter_existing_embeddings(
                chunk, embedder_name, reduced
            )
            exist_result.update(exist_chunk)
            non_exist_result.update(non_exist_chunk)

        return exist_result, non_exist_result

    def get_embeddings(
        self, sequences: Dict[str, str], embedder_name: str, reduced: bool
    ) -> List[SequenceData]:
        if ".onnx" in embedder_name:
            embedder_name = self.get_onnx_model_hash(embedder_name)

        max_batch_size_reading = 2500

        if len(sequences) < max_batch_size_reading:
            result = self.strategy.get_embeddings(
                sequences=sequences, embedder_name=embedder_name
            )
            return [
                SequenceData(
                    seq_id=seq_id,
                    seq=sequences[seq_id],
                    embedding=embd.get("per_sequence" if reduced else "per_residue"),
                )
                for seq_id, embd in result.items()
            ]

        result = []
        for chunk in tqdm(
            dict_chunks(sequences, max_batch_size_reading),
            desc="Reading embeddings from database",
        ):
            get_result = self.strategy.get_embeddings(
                sequences=chunk, embedder_name=embedder_name
            )
            result.extend(
                [
                    SequenceData(
                        seq_id=seq_id,
                        seq=sequences[seq_id],
                        embedding=embd.get(
                            "per_sequence" if reduced else "per_residue"
                        ),
                    )
                    for seq_id, embd in get_result.items()
                ]
            )
        return result

    def delete_embeddings_by_model(self, embedder_name: str) -> bool:
        if self.is_onnx_model(embedder_name):
            embedder_name = self.get_onnx_model_hash(embedder_name)
        return self.strategy.delete_embeddings_by_model(embedder_name)

    @staticmethod
    def is_onnx_model(embedder_name: str) -> bool:
        return ".onnx" in embedder_name or "onnx/" in embedder_name

    @staticmethod
    def get_onnx_model_hash(onnx_path: str):
        return "onnx/" + hashlib.md5(onnx_path.encode("utf8")).hexdigest()

    def get_database_size(self) -> int:
        return self.strategy.get_database_size()

    def cleanup_database(
        self, older_than_days: int = 30, size_threshold: int = 10 * 1024 * 1024 * 1024
    ) -> int:
        return self.strategy.cleanup_database(
            older_than_days=older_than_days, size_threshold=size_threshold
        )

    def get_database_statistics(self) -> Dict[str, Any]:
        return self.strategy.get_database_statistics()

    def get_all_embeddings(self) -> Generator[EmbeddingDatabaseDTO, None, None]:
        """Yield all embeddings from the database."""
        yield from self.strategy.get_all_embeddings()
