import torch
import blosc2
import psycopg
import numpy as np

from contextlib import contextmanager
from typing import Dict, Tuple, List, Any

from .database_strategy import DatabaseStrategy

from ...utils import get_logger

logger = get_logger(__name__)


class PostgreSQLStrategy(DatabaseStrategy):
    def __init__(self):
        self.db_config = None

    def init_db(self, config):
        self.db_config = config
        with self._get_connection() as conn:
            with conn.cursor() as cur:
                try:
                    cur.execute("""
                                CREATE TABLE IF NOT EXISTS embeddings
                                (
                                    sequence_hash   TEXT,
                                    sequence_length INTEGER,
                                    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    last_accessed   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    access_count    INTEGER   DEFAULT 1,
                                    embedder_name   TEXT,
                                    per_sequence    BYTEA,
                                    per_residue     BYTEA,
                                    PRIMARY KEY (sequence_hash, embedder_name)
                                )
                                """)
                except psycopg.errors.UniqueViolation:
                    conn.rollback()

                # Create index for efficient cleanup queries
                cur.execute("""
                            CREATE INDEX IF NOT EXISTS idx_sequence_hash_embedder_name
                                ON embeddings (sequence_hash, embedder_name)
                            """)
                cur.execute("""
                            CREATE INDEX IF NOT EXISTS idx_last_accessed
                                ON embeddings (last_accessed)
                            """)
                conn.commit()

    @contextmanager
    def _get_connection(self):
        conn = psycopg.connect(**self.db_config)
        try:
            yield conn
        finally:
            conn.close()

    @staticmethod
    def compress_embedding(embedding):
        if embedding is None:
            return None
        if torch.is_tensor(embedding):
            embedding = embedding.cpu().numpy()
        elif not isinstance(embedding, np.ndarray):
            embedding = np.array(embedding)
        return blosc2.pack_array(embedding)

    @staticmethod
    def _decompress_embedding(compressed):
        if not compressed:
            return None
        numpy_array = blosc2.unpack_array(compressed)
        return torch.from_numpy(numpy_array)

    def save_embeddings(self, embeddings_data: List[Tuple]):
        try:
            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    cur.executemany(
                        """
                        INSERT INTO embeddings
                        (sequence_hash, sequence_length, last_accessed, embedder_name, per_sequence, per_residue)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        ON CONFLICT (sequence_hash, embedder_name) DO UPDATE SET last_accessed = EXCLUDED.last_accessed,
                                                                                 per_sequence  = COALESCE(EXCLUDED.per_sequence, embeddings.per_sequence),
                                                                                 per_residue   = COALESCE(EXCLUDED.per_residue, embeddings.per_residue)
                        """,
                        embeddings_data,
                    )
                conn.commit()
            return True
        except Exception as e:
            logger.error(f"Error saving embeddings: {e}")
            return False

    def get_embeddings(
        self, sequences: Dict[str, str], embedder_name: str
    ) -> Dict[str, Dict[str, Any]]:
        try:
            hash_keys = list(sequences.keys())

            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    placeholders = ",".join(["%s"] * len(hash_keys))
                    cur.execute(
                        f"""
                        SELECT sequence_hash, per_sequence, per_residue
                        FROM embeddings
                        WHERE sequence_hash IN ({placeholders}) AND embedder_name = %s
                    """,
                        hash_keys + [embedder_name],
                    )

                    db_results = cur.fetchall()

                    # Update access tracking (async)
                    if db_results:
                        found_hashes = [row[0] for row in db_results]
                        cur.execute(
                            f"""
                                           UPDATE embeddings
                                           SET last_accessed = CURRENT_TIMESTAMP,
                                               access_count = access_count + 1
                                           WHERE sequence_hash IN ({placeholders}) AND embedder_name = %s
                                       """,
                            found_hashes + [embedder_name],
                        )
                    conn.commit()

            results = {}
            for result in db_results:
                hash_key = result[0]
                embedding_data = {
                    "id": hash_key,
                    "per_sequence": self._decompress_embedding(result[1]),
                    "per_residue": self._decompress_embedding(result[2]),
                }
                results[hash_key] = embedding_data

            return results
        except Exception as e:
            logger.error(f"Error retrieving embeddings: {e}")
            return {}

    def filter_existing_embeddings(
        self, sequences: Dict[str, str], embedder_name: str, reduced: bool
    ) -> Tuple[Dict[str, str], Dict[str, str]]:
        """
        Filter the database for existing embeddings.

        :param sequences: Dict of sequence hash to sequence
        :param embedder_name: Name of embedder
        :param reduced: If per-sequence should be filtered
        :return: A tuple containing (existing, non_existing) embeddings
        """
        hash_keys = list(sequences.keys())

        with self._get_connection() as conn:
            with conn.cursor() as cur:
                placeholders = ",".join(["%s"] * len(hash_keys))
                cur.execute(
                    f"""
                    SELECT sequence_hash
                    FROM embeddings
                    WHERE sequence_hash IN ({placeholders})
                    AND embedder_name = %s
                    AND {"per_sequence" if reduced else "per_residue"} IS NOT NULL
                """,
                    hash_keys + [embedder_name],
                )
                fetch_result = cur.fetchall()
                existing_hashes = set(row[0] for row in fetch_result)

        existing = {
            seq_hash: seq
            for seq_hash, seq in sequences.items()
            if seq_hash in existing_hashes
        }
        non_existing = {
            seq_hash: seq
            for seq_hash, seq in sequences.items()
            if seq_hash not in existing
        }

        return existing, non_existing

    def delete_embeddings_by_model(self, embedder_name: str) -> bool:
        """TODO: Deprecated for ONNX in plm_eval, should be removed"""
        try:
            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        DELETE
                        FROM embeddings
                        WHERE embedder_name = %s
                        """,
                        [embedder_name],
                    )
                    deleted_count = cur.rowcount
                    conn.commit()
                logger.info(
                    f"Deleted {deleted_count} embeddings for model {embedder_name}"
                )
                return True
        except Exception as e:
            logger.error(f"Error deleting embeddings for model {embedder_name}: {e}")
            return False

    def cleanup_database(
        self, older_than_days: int = 30, size_threshold: int = 10 * 1024 * 1024 * 1024
    ) -> int:
        """
        Clean up embeddings based on least recently accessed.

        :param older_than_days: Delete entries not accessed in X days, defaults to 30
        :param size_threshold: Only trigger cleanup if database size exceeds X bytes, defaults to 10 GB
        :return: Number of embeddings deleted
        """
        current_db_size = self.get_database_size()

        if current_db_size < size_threshold:
            current_mb = current_db_size / (1024 * 1024)
            size_threshold_mb = size_threshold / (1024 * 1024 * 1024)
            logger.info(
                f"Database size {current_mb:.2f} MB is below threshold {size_threshold_mb:.2f} GB, "
                f"skipping cleanup"
            )
            return 0

        try:
            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    # Delete least recently accessed
                    cur.execute(
                        """
                        DELETE
                        FROM embeddings
                        WHERE last_accessed < CURRENT_TIMESTAMP - make_interval(days => %s)
                        RETURNING sequence_hash
                        """,
                        [older_than_days],
                    )
                    deleted_count = cur.rowcount
                    conn.commit()

                    logger.info(
                        f"Deleted {deleted_count} embeddings older than {older_than_days} days "
                        f"from embeddings_db"
                    )
                    return deleted_count
        except Exception as e:
            logger.error(f"Error during cleanup: {e}")
            return 0

    def get_database_size(self) -> int:
        """
        Get the current size of the database.

        :return: Size in bytes
        """
        try:
            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT pg_database_size(current_database()) as size_bytes
                    """
                    )
                    result = cur.fetchone()
                    size_bytes = result[0]

                    return int(size_bytes)
        except Exception as e:
            logger.error(f"Error retrieving database size: {e}")
            return 0

    def get_database_statistics(self) -> Dict[str, Any]:
        """Get statistics about database."""
        try:
            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("""
                                SELECT COUNT(*)                      as total_embeddings,
                                       COUNT(DISTINCT embedder_name) as unique_models,
                                       MIN(last_accessed)            as oldest_access,
                                       MAX(last_accessed)            as newest_access,
                                       AVG(access_count)             as avg_access_count,
                                       SUM(CASE
                                               WHEN last_accessed < CURRENT_TIMESTAMP - INTERVAL '30 days'
                                                   THEN 1
                                               ELSE 0 END)           as older_than_30_days,
                                       SUM(CASE
                                               WHEN last_accessed < CURRENT_TIMESTAMP - INTERVAL '7 days'
                                                   THEN 1
                                               ELSE 0 END)           as older_than_7_days
                                FROM embeddings
                                """)
                    result = cur.fetchone()

                    return {
                        "total_embeddings": result[0],
                        "unique_models": result[1],
                        "oldest_access": result[2],
                        "newest_access": result[3],
                        "avg_access_count": float(result[4]) if result[4] else 0,
                        "older_than_30_days": result[5],
                        "older_than_7_days": result[6],
                        "database_size_mb": self.get_database_size() / (1024 * 1024),
                    }
        except Exception as e:
            logger.error(f"Error getting cleanup statistics: {e}")
            return {}
