import h5py
import re
import shutil

from pathlib import Path
from typing import Dict, Set, List, Generator, Tuple
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
    MAX_KEYS_PER_FILE: int = 200_000

    def __init__(self, max_keys_per_file: int = MAX_KEYS_PER_FILE):
        self._max_keys_per_file = max_keys_per_file
        self._ensure_initial_file()

    def _get_part_files_with_indices(self) -> List[Tuple[int, Path]]:
        embeddings_dir = PathProvider.get_embeddings_dir()
        part_files = []
        pattern = re.compile(r"^biocentral_embeddings_part_(\d+)\.h5$")
        if embeddings_dir.exists():
            for file in embeddings_dir.iterdir():
                if file.is_file():
                    match = pattern.match(file.name)
                    if match:
                        idx = int(match.group(1))
                        part_files.append((idx, file))
        part_files.sort(key=lambda x: x[0])
        return part_files

    def _get_part_files(self) -> List[Path]:
        return [file for _, file in self._get_part_files_with_indices()]

    def _get_part_file_path(self, idx: int) -> Path:
        return PathProvider.get_embeddings_dir() / f"biocentral_embeddings_part_{idx}.h5"

    @staticmethod
    def _create_empty_h5_file(file_path: Path):
        if not file_path.exists():
            with h5py.File(file_path, "w") as f:
                pass

    def _ensure_initial_file(self):
        parts = self._get_part_files()
        if not parts:
            self._create_empty_h5_file(self._get_part_file_path(0))

    @staticmethod
    def _get_file_key_count(file_path: Path) -> int:
        with h5py.File(file_path, "r") as f:
            return len(f.keys())

    def _get_latest_part_file_info(self) -> Tuple[int, Path]:
        parts = self._get_part_files_with_indices()
        if not parts:
            part_0 = self._get_part_file_path(0)
            self._create_empty_h5_file(part_0)
            return 0, part_0
        return parts[-1]

    def get_existing_keys(self) -> Dict[str, Set[str]]:
        result_dict: Dict[str, Set[str]] = {}
        for part_file in self._get_part_files():
            part_keys = get_h5_db_keys(part_file)
            for embedder_name, hash_keys in part_keys.items():
                if embedder_name not in result_dict:
                    result_dict[embedder_name] = set()
                result_dict[embedder_name].update(hash_keys)
        return result_dict

    def load_embeddings(self, embedder_name: str, sequence_data: List[SequenceData]) -> List:
        embd_dtos = [EmbeddingDatabaseDTO.from_sequence_data(sd, embedder_name, reduce=True) for sd in sequence_data]
        ids_to_load = set([embd_dto.database_key() for embd_dto in embd_dtos])
        if not ids_to_load:
            return []

        loaded_dtos = []
        remaining_ids = set(ids_to_load)
        for part_file in self._get_part_files():
            if not remaining_ids:
                break
            part_loaded = list(read_h5_db(part_file, remaining_ids))
            for dto in part_loaded:
                loaded_dtos.append(dto)
                remaining_ids.discard(dto.database_key())
        return loaded_dtos

    def save_embeddings(self, sequence_data: List[SequenceData], embedder_name: str, reduce: bool) -> Generator[int, None, None]:
        embd_dtos = [EmbeddingDatabaseDTO.from_sequence_data(sd, embedder_name, reduce=reduce) for sd in sequence_data]
        if not embd_dtos:
            yield 0
            return

        total_written = 0
        yield total_written

        remaining_dtos = embd_dtos
        while remaining_dtos:
            latest_idx, latest_file = self._get_latest_part_file_info()
            current_keys = self._get_file_key_count(latest_file)
            capacity = self._max_keys_per_file - current_keys
            if capacity <= 0:
                next_idx = latest_idx + 1
                next_file = self._get_part_file_path(next_idx)
                self._create_empty_h5_file(next_file)
                latest_file = next_file
                capacity = self._max_keys_per_file

            chunk_size = min(len(remaining_dtos), capacity)
            chunk = remaining_dtos[:chunk_size]
            remaining_dtos = remaining_dtos[chunk_size:]

            for progress in write_h5_db(latest_file, chunk):
                if progress > 0:
                    yield total_written + progress
            total_written += len(chunk)