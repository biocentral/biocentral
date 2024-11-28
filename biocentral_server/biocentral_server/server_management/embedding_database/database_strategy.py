import torch
import hashlib

from typing import Union


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