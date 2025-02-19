import torch
import hashlib

from typing import Union, Dict, Tuple, List, Any


class DatabaseStrategy:
    def init_db(self, config):
        raise NotImplementedError

    def db_lookup(self, hash_key):
        raise NotImplementedError

    def save_embeddings(self, embeddings_data: List[Tuple]):
        raise NotImplementedError

    def get_embeddings(self, sequences: Dict[str, str], embedder_name: str) -> Dict[str, Dict[str, Any]]:
        raise NotImplementedError

    def clear_embeddings(self, sequence=None, model_name=None):
        raise NotImplementedError

    def filter_existing_embeddings(self, sequences: Dict[str, str],
                                   embedder_name: str,
                                   reduced: bool) -> Tuple[Dict[str, str], Dict[str, str]]:
        raise NotImplementedError

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
    def compress_embedding(embedding) -> Union[str, bytes, None]:
        raise NotImplementedError

    @staticmethod
    def _decompress_embedding(compressed) -> Union[None, torch.Tensor]:
        raise NotImplementedError

    @staticmethod
    def generate_sequence_hash(sequence):
        """Generate a hash for the given sequence, with length suffix as additional hash collision safety."""
        suffix = len(sequence)
        sequence = f"{sequence}_{suffix}"
        return hashlib.sha256(sequence.encode()).hexdigest()