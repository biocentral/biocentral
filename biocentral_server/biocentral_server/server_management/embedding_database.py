import base64
import torch
import blosc2
import hashlib
import logging
import numpy as np

from flask import current_app
from datetime import datetime
from bson.binary import Binary
from flask_pymongo import PyMongo
from collections import namedtuple
from typing import List, Dict, Tuple, Any, Union
from tinydb import TinyDB, Query
from tinydb.storages import JSONStorage
from tinydb.middlewares import CachingMiddleware

logger = logging.getLogger(__name__)

EmbeddingsDatabaseTriple = namedtuple("EmbeddingsDatabaseTriple", ["id", "seq", "embd"])


class DatabaseStrategy:
    def init_app(self, app):
        raise NotImplementedError

    def db_lookup(self, hash_key):
        raise NotImplementedError

    def save_embedding(self, sequence, embedder_name, per_sequence, per_residue):
        raise NotImplementedError

    def get_embedding(self, sequence, embedder_name):
        raise NotImplementedError

    def clear_embeddings(self, sequence=None, model_name=None):
        raise NotImplementedError

    def _update_document(self, document, embedder_name, per_residue, per_sequence):
        update_dict: dict = document["embeddings"].get(embedder_name, {})
        compressed_per_sequence = self._compress_embedding(per_sequence)
        compressed_per_residue = self._compress_embedding(per_residue)
        if compressed_per_sequence:
            update_dict["per_sequence"] = compressed_per_sequence
        if compressed_per_residue:
            update_dict["per_residue"] = compressed_per_residue
        document["embeddings"][embedder_name] = update_dict
        return document

    @staticmethod
    def _sanity_check_embedding_lookup(sequence: str, document):
        seq_len = len(sequence)
        seq_len_lookup = document["metadata"]["sequence_length"]
        if seq_len != seq_len_lookup:
            raise Exception(f"Sequence length mismatch for sequence lookup ({seq_len} != {seq_len_lookup}). "
                            f"This is extremely unlikely to have happened, please report at "
                            f"https://github.com/biocentral/biocentral/issues "
                            f"Sequence causing the issue: {sequence}")

    @staticmethod
    def _compress_embedding(embedding) -> Union[str, bytes, None]:
        raise NotImplementedError

    @staticmethod
    def _decompress_embedding(compressed) -> Union[None, torch.Tensor]:
        raise NotImplementedError

    @staticmethod
    def _generate_sequence_hash(sequence):
        """Generate a hash for the given sequence, with length suffix as additional hash collision safety."""
        suffix = len(sequence)
        sequence = f"{sequence}_{suffix}"
        return hashlib.sha256(sequence.encode()).hexdigest()


class MongoDBStrategy(DatabaseStrategy):
    def __init__(self):
        self.mongo = PyMongo()

    def init_app(self, app):
        self.mongo.init_app(app)

    @staticmethod
    def _compress_embedding(embedding):
        if embedding is None:
            return None
        if torch.is_tensor(embedding):
            embedding = embedding.cpu().numpy()
        elif not isinstance(embedding, np.ndarray):
            embedding = np.array(embedding)
        return Binary(blosc2.pack_array(embedding))

    @staticmethod
    def _decompress_embedding(compressed):
        if not compressed:
            return None
        numpy_array = blosc2.unpack_array(compressed)
        return torch.from_numpy(numpy_array)

    def db_lookup(self, hash_key):
        return self.mongo.db.embeddings.find_one({"_id": hash_key})

    def save_embedding(self, sequence, embedder_name, per_sequence, per_residue):
        try:
            hash_key = self._generate_sequence_hash(sequence)
            document = self.db_lookup(hash_key) or {
                "_id": hash_key,
                "embeddings": {},
                "metadata": {
                    "last_updated": datetime.utcnow(),
                    "sequence_length": len(sequence)
                }
            }

            self._sanity_check_embedding_lookup(sequence, document)

            document = self._update_document(document, embedder_name, per_residue, per_sequence)

            self.mongo.db.embeddings.replace_one({"_id": hash_key}, document, upsert=True)
            return True
        except Exception as e:
            current_app.logger.error(f"Error saving embedding: {e}")
            return False

    def get_embedding(self, sequence, embedder_name):
        try:
            hash_key = self._generate_sequence_hash(sequence)
            document = self.mongo.db.embeddings.find_one({"_id": hash_key})
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
        query = {}
        if sequence:
            query["_id"] = self._generate_sequence_hash(sequence)
        if model_name:
            query[f"embeddings.{model_name}"] = {"$exists": True}

        if sequence and model_name:
            result = self.mongo.db.embeddings.update_one(query, {"$unset": {f"embeddings.{model_name}": ""}})
            return result.modified_count
        else:
            result = self.mongo.db.embeddings.delete_many(query)
            return result.deleted_count


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


class EmbeddingsDatabase:
    def __init__(self):
        self.strategy = None

    def init_app(self, app):
        self.strategy = MongoDBStrategy() if app.config.get('USE_MONGODB', False) else TinyDBStrategy()
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


def init_embeddings_database_instance(app):
    """Initialize the database with the Flask app."""
    embeddings_db_instance = EmbeddingsDatabase()
    embeddings_db_instance.init_app(app)
    return embeddings_db_instance
