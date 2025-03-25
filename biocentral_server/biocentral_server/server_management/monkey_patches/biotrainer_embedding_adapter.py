import torch

from pathlib import Path
from numpy import ndarray
from abc import abstractmethod, ABC
from typing import Dict, Any, Union, Optional
from biotrainer.embedders import EmbeddingService, EmbedderInterface, _get_embedder

from ..embedding_database import EmbeddingsDatabase, EmbeddingsDatabaseTriple


class EmbeddingStorageStrategy(ABC):
    @abstractmethod
    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        pass

    @abstractmethod
    def load_embeddings(self, path: str) -> Dict[str, Any]:
        pass


class H5EmbeddingStorage(EmbeddingStorageStrategy):
    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        # Original H5 implementation from EmbeddingService
        return EmbeddingService._save_embeddings(save_id, embeddings, path)

    def load_embeddings(self, path: str) -> Dict[str, Any]:
        return EmbeddingService.load_embeddings(path)


class DatabaseEmbeddingStorage(EmbeddingStorageStrategy):
    def __init__(self, embedder_name: str, seq_dict: Dict[str, str], embeddings_db: EmbeddingsDatabase, reduced: bool):
        self.embedder_name = embedder_name
        self.seq_dict = seq_dict
        self.embeddings_db = embeddings_db
        self.reduced = reduced

    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        embedding_triples = [EmbeddingsDatabaseTriple(id=seq_id, seq=self.seq_dict[seq_id], embd=emb) for
                             seq_id, emb in embeddings.items()]
        self.embeddings_db.save_embeddings(embedding_triples, embedder_name=self.embedder_name, reduced=True)
        return save_id + len(embeddings)

    def load_embeddings(self, path: str) -> Dict[str, Any]:
        # Implement database loading logic
        triples = self.embeddings_db.get_embeddings(sequences=self.seq_dict, embedder_name=self.embedder_name,
                                                    reduced=self.reduced)
        return {triple.id: triple.embd for triple in triples}


class OHEMemoryStorage(EmbeddingStorageStrategy):
    def __init__(self):
        """ Store one hot encodings in memory because they are usually very small
        and saving them to disk is a lot of overhead """
        self.embeddings_dict = {}

    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        # Original H5 implementation from EmbeddingService
        self.embeddings_dict.update(embeddings)
        return save_id + len(embeddings)

    def load_embeddings(self, path: str) -> Dict[str, Any]:
        return self.embeddings_dict


class BiotrainerEmbeddingServiceAdapter(EmbeddingService):

    def __init__(self, embedder: EmbedderInterface = None, use_half_precision: bool = False,
                 storage_strategy: EmbeddingStorageStrategy = None):
        super().__init__(embedder=embedder, use_half_precision=use_half_precision)
        self.storage_strategy = storage_strategy

    def _save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], embeddings_file_path: Path) -> int:
        """
        Overwrites the static method (possible in python) from EmbeddingService and uses the storage strategy.
        """
        return self.storage_strategy.save_embeddings(save_id, embeddings, embeddings_file_path)

    def load_embeddings(self, path: str) -> Dict[str, Any]:
        return self.storage_strategy.load_embeddings(path)


def get_adapter_embedding_service(embeddings_file_path: Union[str, None], embedder_name: Union[str, None],
                                  use_half_precision: Optional[bool] = False,
                                  device: Optional[Union[str, torch.device]] = None,
                                  embeddings_db: Optional[EmbeddingsDatabase] = None,
                                  sequence_dict: Dict[str, str] = None,
                                  reduced: bool = False) -> EmbeddingService:
    storage_strategy: EmbeddingStorageStrategy
    if embedder_name == "one_hot_encoding":
        storage_strategy = OHEMemoryStorage()
    elif embeddings_db is not None and sequence_dict is not None:
        storage_strategy = DatabaseEmbeddingStorage(embedder_name=embedder_name, seq_dict=sequence_dict,
                                                    embeddings_db=embeddings_db, reduced=reduced)
    else:
        storage_strategy = H5EmbeddingStorage()

    if embeddings_file_path is not None:
        # Only for loading
        return BiotrainerEmbeddingServiceAdapter(storage_strategy=storage_strategy)

    embedder: EmbedderInterface = _get_embedder(embedder_name=embedder_name, use_half_precision=use_half_precision,
                                                device=device)
    return BiotrainerEmbeddingServiceAdapter(embedder=embedder, use_half_precision=use_half_precision,
                                             storage_strategy=storage_strategy)
