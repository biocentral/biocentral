import os

from typing import Dict, Any

from .embedding_database import EmbeddingsDatabase


class EmbeddingDatabaseFactory:
    _instance = None
    _postgres_config: Dict[str, Any] = {}
    _database_instance: EmbeddingsDatabase = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(EmbeddingDatabaseFactory, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self._postgres_config = {
            "host": os.getenv("POSTGRES_HOST"),
            "port": os.getenv("POSTGRES_PORT"),
            "dbname": os.getenv("POSTGRES_DB"),
            "user": os.getenv("POSTGRES_USER"),
            "password": os.getenv("POSTGRES_PASSWORD"),
        }

    def get_embeddings_db(self) -> EmbeddingsDatabase:
        if self._database_instance is None:
            self._database_instance = EmbeddingsDatabase(
                postgres_config=self._postgres_config
            )
        return self._database_instance
