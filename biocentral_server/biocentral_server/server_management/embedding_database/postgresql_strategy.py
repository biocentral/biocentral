import torch
import blosc2
import logging
import psycopg
import numpy as np

from flask import current_app
from datetime import datetime
from contextlib import contextmanager

from .database_strategy import DatabaseStrategy


logger = logging.getLogger(__name__)


class PostgreSQLStrategy(DatabaseStrategy):
    def __init__(self):
        self.db_config = None

    def init_app(self, app):
        self.db_config = app.config.get('POSTGRESQL_CONFIG')
        with self._get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute('''
                    CREATE TABLE IF NOT EXISTS embeddings (
                        id TEXT PRIMARY KEY,
                        sequence_length INTEGER,
                        last_updated TIMESTAMP,
                        embedder_name TEXT,
                        per_sequence BYTEA,
                        per_residue BYTEA
                    )
                ''')
            conn.commit()

    @contextmanager
    def _get_connection(self):
        conn = psycopg.connect(**self.db_config)
        try:
            yield conn
        finally:
            conn.close()

    @staticmethod
    def _compress_embedding(embedding):
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

    def save_embedding(self, sequence, embedder_name, per_sequence, per_residue):
        try:
            hash_key = self._generate_sequence_hash(sequence)
            compressed_per_sequence = self._compress_embedding(per_sequence)
            compressed_per_residue = self._compress_embedding(per_residue)

            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute('''
                        INSERT INTO embeddings 
                        (id, sequence_length, last_updated, embedder_name, per_sequence, per_residue)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        ON CONFLICT (id) DO UPDATE SET
                        sequence_length = EXCLUDED.sequence_length,
                        last_updated = EXCLUDED.last_updated,
                        embedder_name = EXCLUDED.embedder_name,
                        per_sequence = EXCLUDED.per_sequence,
                        per_residue = EXCLUDED.per_residue
                    ''', (hash_key, len(sequence), datetime.utcnow(), embedder_name,
                          compressed_per_sequence, compressed_per_residue))
                conn.commit()
            return True
        except Exception as e:
            current_app.logger.error(f"Error saving embedding: {e}")
            return False

    def get_embedding(self, sequence, embedder_name):
        try:
            hash_key = self._generate_sequence_hash(sequence)
            with self._get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute('''
                        SELECT per_sequence, per_residue 
                        FROM embeddings 
                        WHERE id = %s AND embedder_name = %s
                    ''', (hash_key, embedder_name))
                    result = cur.fetchone()

                    if result:
                        return {
                            "per_sequence": self._decompress_embedding(result[0]),  # Use index instead of key
                            "per_residue": self._decompress_embedding(result[1])  # Use index instead of key
                        }
            return None
        except Exception as e:
            current_app.logger.error(f"Error retrieving embedding: {e}")
            return None
