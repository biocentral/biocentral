import torch

from pathlib import Path
from numpy import ndarray
from abc import abstractmethod, ABC
from typing import Dict, Any, Union, Optional
from biotrainer.embedders import EmbeddingService, EmbedderInterface, _get_embedder

from .. import FileContextManager
from ..embedding_database import EmbeddingsDatabase, EmbeddingsDatabaseTriple


class EmbeddingStorageStrategy(ABC):
    @abstractmethod
    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        pass

    @abstractmethod
    def load_embeddings(self, embeddings_file_path: str) -> Dict[str, Any]:
        pass


class H5EmbeddingStorage(EmbeddingStorageStrategy):
    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        # Original H5 implementation from EmbeddingService
        return EmbeddingService._save_embeddings(save_id, embeddings, path)

    def load_embeddings(self, embeddings_file_path: str) -> Dict[str, Any]:
        return EmbeddingService.load_embeddings(embeddings_file_path)


class DatabaseEmbeddingStorage(EmbeddingStorageStrategy):
    def __init__(self, embedder_name: str, seq_dict: Dict[str, str], embeddings_db: EmbeddingsDatabase, reduced: bool):
        self.embedder_name = embedder_name
        self.seq_dict = seq_dict
        self.embeddings_db = embeddings_db
        self.reduced = reduced

    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        embedding_triples = [EmbeddingsDatabaseTriple(id=seq_id, seq=self.seq_dict[seq_id], embd=emb) for
                             seq_id, emb in embeddings.items()]
        self.embeddings_db.save_embeddings(embedding_triples, embedder_name=self.embedder_name, reduced=self.reduced)
        return save_id + len(embeddings)

    def load_embeddings(self, embeddings_file_path: str) -> Dict[str, Any]:
        # Implement database loading logic
        triples = self.embeddings_db.get_embeddings(sequences=self.seq_dict, embedder_name=self.embedder_name,
                                                    reduced=self.reduced)
        return {triple.id: torch.tensor(triple.embd) for triple in triples}


class OHEMemoryStorage(EmbeddingStorageStrategy):
    def __init__(self):
        """ Store one hot encodings in memory because they are usually very small
        and saving them to disk is a lot of overhead """
        self.embeddings_dict = {}

    def save_embeddings(self, save_id: int, embeddings: Dict[str, ndarray], path: Path) -> int:
        # Original H5 implementation from EmbeddingService
        self.embeddings_dict.update(embeddings)
        return save_id + len(embeddings)

    def load_embeddings(self, embeddings_file_path: str) -> Dict[str, Any]:
        return {idx: torch.tensor(embd) for idx, embd in self.embeddings_dict.items()}


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

    def load_embeddings(self, embeddings_file_path: str) -> Dict[str, Any]:
        return self.storage_strategy.load_embeddings(embeddings_file_path)


class ONNXEmbeddingAdapter(EmbedderInterface):
    """ Small mock adapter only used to load the pre-calculated onnx embeddings from the database"""

    def __init__(self, hashed_name, device):
        self.name = hashed_name
        self.device = device

    def _embed_single(self, sequence: str) -> ndarray:
        raise NotImplementedError


def get_adapter_embedding_service(embeddings_file_path: Optional[str],
                                  embedder_name: Optional[str],
                                  custom_tokenizer_config: Optional[str] = None,
                                  use_half_precision: Optional[bool] = False,
                                  device: Optional[Union[str, torch.device]] = None,
                                  embeddings_db: Optional[EmbeddingsDatabase] = None,
                                  sequence_dict: Dict[str, str] = None,
                                  reduced: bool = False,
                                  only_loading: bool = False) -> EmbeddingService:
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

    if ".onnx" in embedder_name or "onnx/" in embedder_name:
        if only_loading:
            embedder: EmbedderInterface = ONNXEmbeddingAdapter(hashed_name=embedder_name,
                                                               device=device)
            return BiotrainerEmbeddingServiceAdapter(embedder=embedder,
                                                     use_half_precision=use_half_precision,
                                                     storage_strategy=storage_strategy)

        file_context_manager = FileContextManager()
        with file_context_manager.storage_read(embedder_name, suffix=".onnx") as onnx_file_path:
            with file_context_manager.storage_read(custom_tokenizer_config,
                                                   suffix=".json") as custom_tokenizer_config_path:
                embedder: EmbedderInterface = _get_embedder(embedder_name=str(onnx_file_path),
                                                            custom_tokenizer_config=str(custom_tokenizer_config_path),
                                                            use_half_precision=use_half_precision,
                                                            device=device)
                return BiotrainerEmbeddingServiceAdapter(embedder=embedder, use_half_precision=use_half_precision,
                                                         storage_strategy=storage_strategy)

    embedder: EmbedderInterface = _get_embedder(embedder_name=embedder_name,
                                                custom_tokenizer_config=custom_tokenizer_config,
                                                use_half_precision=use_half_precision,
                                                device=device)
    return BiotrainerEmbeddingServiceAdapter(embedder=embedder, use_half_precision=use_half_precision,
                                             storage_strategy=storage_strategy)
