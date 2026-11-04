import shutil

from typing import Dict, Set, List, Generator
from biotrainer_core.data_classes import SequenceData
from biotrainer_core.h5_files import get_h5_db_keys, read_h5_db, EmbeddingDatabaseDTO, write_h5_db

from .path_provider import PathProvider

class BiocentralLocalDatabase:
    def __init__(self):
        self._embed_db = LocalEmbeddingsDatabase()

    @staticmethod
    def clear_local_cache():
        cache_dir = PathProvider._get_cache_dir()
        shutil.rmtree(cache_dir)

    def embeddings(self):
        return self._embed_db


class LocalEmbeddingsDatabase:
    def __init__(self):
        self._db_file = PathProvider.get_embeddings_dir() / "biocentral_embeddings.h5"
        if not self._db_file.exists():
            import h5py
            with h5py.File(self._db_file, 'w') as f:
                pass  # Create empty but valid HDF5 file

    def get_existing_keys(self) -> Dict[str, Set[str]]:
        return get_h5_db_keys(self._db_file)

    def load_embeddings(self, embedder_name: str, sequence_data: List[SequenceData]) -> List:
        embd_dtos = [EmbeddingDatabaseDTO.from_sequence_data(sd, embedder_name, reduce=True) for sd in sequence_data]
        ids_to_load = set([embd_dto.database_key() for embd_dto in embd_dtos])
        loaded_dtos = list(read_h5_db(self._db_file, ids_to_load))
        return loaded_dtos

    def save_embeddings(self, sequence_data: List[SequenceData], embedder_name: str, reduce: bool) -> Generator[int, None, None]:
        embd_dtos = [EmbeddingDatabaseDTO.from_sequence_data(sd, embedder_name, reduce=reduce) for sd in sequence_data]
        yield from write_h5_db(self._db_file, embd_dtos)