import os
import torch
import base64
import blosc2
import logging
import numpy as np

from tinydb import TinyDB, Query
from tinydb.storages import JSONStorage
from tinydb.middlewares import CachingMiddleware
from typing import Dict, Tuple, List, Any

from .database_strategy import DatabaseStrategy

logger = logging.getLogger(__name__)


class TinyDBStrategy(DatabaseStrategy):
    def __init__(self):
        self.db = None

    def init_db(self, config):
        db_path = config.get('TINYDB_PATH')
        if not os.path.exists(db_path):
            os.makedirs(db_path, exist_ok=True)
        self.db = TinyDB(db_path, storage=CachingMiddleware(JSONStorage))

    @staticmethod
    def compress_embedding(embedding):
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

    def save_embeddings(self, embeddings_data: List[Tuple]):
        try:
            for data in embeddings_data:
                hash_key, seq_length, last_updated, embedder_name, per_sequence, per_residue = data
                document = self.db.get(Query()._id == hash_key) or {
                    "_id": hash_key,
                    "embeddings": {},
                    "metadata": {
                        "sequence_length": seq_length
                    }
                }

                document["metadata"]["last_updated"] = last_updated.isoformat()
                document["embeddings"].setdefault(embedder_name, {})

                if per_sequence is not None:
                    document["embeddings"][embedder_name]["per_sequence"] = per_sequence
                if per_residue is not None:
                    document["embeddings"][embedder_name]["per_residue"] = per_residue

                self.db.upsert(document, Query()._id == hash_key)
            return True
        except Exception as e:
            logger.error(f"Error saving embeddings: {e}")
            return False

    def get_embeddings(self, sequences: Dict[str, str], embedder_name: str) -> Dict[str, Dict[str, Any]]:
        try:
            results = {}
            for seq_id, seq in sequences.items():
                hash_key = self.generate_sequence_hash(seq)
                document = self.db.get(Query()._id == hash_key)
                if document and embedder_name in document["embeddings"]:
                    embeddings = document["embeddings"][embedder_name]
                    results[seq_id] = {
                        "id": hash_key,
                        "per_sequence": self._decompress_embedding(embeddings.get("per_sequence", None)),
                        "per_residue": self._decompress_embedding(embeddings.get("per_residue", None))
                    }
            return results
        except Exception as e:
            logger.error(f"Error retrieving embeddings: {e}")
            return {}

    def clear_embeddings(self, sequence=None, model_name=None):
        embedding = Query()
        if sequence and model_name:
            hash_key = self.generate_sequence_hash(sequence)
            doc = self.db.get(embedding._id == hash_key)
            if doc and model_name in doc['embeddings']:
                del doc['embeddings'][model_name]
                self.db.update(doc, embedding._id == hash_key)
                return 1
            return 0
        elif sequence:
            hash_key = self.generate_sequence_hash(sequence)
            return self.db.remove(embedding._id == hash_key)
        elif model_name:
            def remove_model(doc):
                if model_name in doc['embeddings']:
                    del doc['embeddings'][model_name]
                return doc

            return self.db.update(remove_model)
        else:
            return self.db.truncate()

    def filter_existing_embeddings(self, sequences: Dict[str, str],
                                   embedder_name: str,
                                   reduced: bool) -> Tuple[Dict[str, str], Dict[str, str]]:
        existing = {}
        non_existing = {}
        for seq_id, seq in sequences.items():
            hash_key = self.generate_sequence_hash(seq)
            document = self.db.get(Query()._id == hash_key)
            if document and embedder_name in document["embeddings"]:
                embeddings = document["embeddings"][embedder_name]
                if reduced and embeddings.get("per_sequence") is not None:
                    existing[seq_id] = seq
                elif not reduced and embeddings.get("per_residue") is not None:
                    existing[seq_id] = seq
                else:
                    non_existing[seq_id] = seq
            else:
                non_existing[seq_id] = seq
        return existing, non_existing
