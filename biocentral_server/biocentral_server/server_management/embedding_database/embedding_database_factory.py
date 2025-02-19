import os

from pathlib import Path
from typing import Dict, Any

from .embedding_database import EmbeddingsDatabase

class EmbeddingDatabaseFactory:
    _instance = None
    _config: Dict[str, Any] = {}
    _database_instance: EmbeddingsDatabase = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(EmbeddingDatabaseFactory, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self._config['POSTGRESQL_CONFIG'] = {
                'USE_POSTGRESQL': True,
                'POSTGRES_HOST': 'embeddings-db',
                'POSTGRES_DB': os.getenv('POSTGRES_DB'),
                'POSTGRES_USER': os.getenv('POSTGRES_USER'),
                'POSTGRES_PASSWORD': os.getenv('POSTGRES_PASSWORD'),
                'POSTGRES_PORT': os.getenv('POSTGRES_PORT'),
            }
        self._config['TINYDB_PATH'] = str(Path("storage/embeddings.json"))

    def get_embeddings_db(self) -> EmbeddingsDatabase:
        if self._database_instance is None:
            self._database_instance = EmbeddingsDatabase(config=self._config)
        return self._database_instance