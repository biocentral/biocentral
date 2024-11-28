import torch
import base64
import blosc2
import logging
import numpy as np

from flask import current_app
from datetime import datetime
from tinydb import TinyDB, Query
from tinydb.storages import JSONStorage
from tinydb.middlewares import CachingMiddleware

from .database_strategy import DatabaseStrategy


logger = logging.getLogger(__name__)


class TinyDBStrategy(DatabaseStrategy):
    def __init__(self):
        self.db = None

    def init_app(self, app):
        db_path = app.config.get('TINYDB_PATH')
        self.db = TinyDB(db_path, storage=CachingMiddleware(JSONStorage))

    @staticmethod
    def _compress_embedding(embedding):
        if embedding is None:
            return None
        if torch.is_tensor(embedding):
            embedding = embedding.cpu().numpy()
        elif not isinstance(embedding, np.ndarray):
            embedding = np.array(embedding)
        compressed = blosc2.pack_array(embedding)
        return base64.b64encode(compressed).decode('utf-8')

    @staticmethod
    def _decompress_embedding(compressed):
        if not compressed:
            return None
        decoded = base64.b64decode(compressed.encode('utf-8'))
        numpy_array = blosc2.unpack_array(decoded)
        return torch.from_numpy(numpy_array)

    def db_lookup(self, hash_key):
        embedding = Query()
        logger.info(f"Looking up: {hash_key}")
        return self.db.get(embedding._id == hash_key)

    def save_embedding(self, sequence, embedder_name, per_sequence, per_residue):
        try:
            hash_key = self._generate_sequence_hash(sequence)
            document = self.db_lookup(hash_key) or {
                "_id": hash_key,
                "embeddings": {},
                "metadata": {
                    "last_updated": datetime.utcnow().isoformat(),
                    "sequence_length": len(sequence)
                }
            }

            self._sanity_check_embedding_lookup(sequence, document)

            document = self._update_document(document, embedder_name, per_residue, per_sequence)

            embedding = Query()
            self.db.upsert(document, embedding._id == hash_key)
            return True
        except Exception as e:
            current_app.logger.error(f"Error saving embedding: {e}")
            return False

    def get_embedding(self, sequence, embedder_name):
        try:
            hash_key = self._generate_sequence_hash(sequence)
            embedding = Query()
            document = self.db.get(embedding._id == hash_key)
            if document and embedder_name in document["embeddings"]:
                embeddings = document["embeddings"][embedder_name]
                return {
                    "per_sequence": self._decompress_embedding(embeddings.get("per_sequence", None)),
                    "per_residue": self._decompress_embedding(embeddings.get("per_residue", None))
                }
            return None
        except Exception as e:
            current_app.logger.error(f"Error retrieving embedding: {e}")
            return None

    def clear_embeddings(self, sequence=None, model_name=None):
        embedding = Query()
        if sequence and model_name:
            hash_key = self._generate_sequence_hash(sequence)
            doc = self.db.get(embedding._id == hash_key)
            if doc and model_name in doc['embeddings']:
                del doc['embeddings'][model_name]
                self.db.update(doc, embedding._id == hash_key)
                return 1
            return 0
        elif sequence:
            hash_key = self._generate_sequence_hash(sequence)
            return self.db.remove(embedding._id == hash_key)
        elif model_name:
            def remove_model(doc):
                if model_name in doc['embeddings']:
                    del doc['embeddings'][model_name]
                return doc

            return self.db.update(remove_model)
        else:
            return self.db.truncate()
