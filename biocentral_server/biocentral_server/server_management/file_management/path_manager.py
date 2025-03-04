from pathlib import Path
from typing import Final, List, Optional, Tuple

from .storage_file_type import StorageFileType


class PathManager:
    base_path: Final[Path] = Path("")

    _fasta_files_path: Final[Path] = Path("fasta_files/")
    _embeddings_files_path: Final[Path] = Path("embeddings/")
    _models_files_path: Final[Path] = Path("models/")
    _subdirectories_hash_dir: Final[List[Path]] = [_fasta_files_path, _embeddings_files_path, _models_files_path]

    def __init__(self, user_id: str):
        self.user_id = user_id

    def _base_user_path(self) -> Path:
        return self.base_path / self.user_id

    def get_database_path(self, database_hash: str) -> Path:
        return self._base_user_path() / database_hash

    def get_embeddings_files_path(self, database_hash: str) -> Path:
        return self.get_database_path(database_hash) / self._embeddings_files_path

    def _get_fasta_files_path(self, database_hash: str) -> Path:
        return self.get_database_path(database_hash) / self._fasta_files_path

    def _get_models_files_path(self, database_hash: str) -> Path:
        return self.get_database_path(database_hash) / self._models_files_path

    def get_biotrainer_model_path(self, database_hash: str, model_hash: str) -> Path:
        return self._get_models_files_path(database_hash=database_hash) / model_hash

    @staticmethod
    def _storage_file_type_to_file_name(file_type: StorageFileType, embedder_name: Optional[str] = "") -> str:
        return {StorageFileType.SEQUENCES: "sequences.fasta",
                StorageFileType.LABELS: "labels.fasta",
                StorageFileType.MASKS: "masks.fasta",
                StorageFileType.EMBEDDINGS_PER_RESIDUE: f"embeddings_file_{embedder_name}.h5",
                StorageFileType.EMBEDDINGS_PER_SEQUENCE: f"reduced_embeddings_file_{embedder_name}.h5",
                StorageFileType.BIOTRAINER_CONFIG: "config_file.yaml",
                StorageFileType.BIOTRAINER_LOGGING: "logger_out.log",
                StorageFileType.BIOTRAINER_RESULT: "out.yml"
                }[file_type]

    def _storage_file_type_to_path(self, database_hash: str, file_type: StorageFileType,
                                   model_hash: Optional[str] = "") -> Path:
        return {StorageFileType.SEQUENCES: self._get_fasta_files_path(database_hash),
                StorageFileType.LABELS: self._get_fasta_files_path(database_hash),
                StorageFileType.MASKS: self._get_fasta_files_path(database_hash),
                StorageFileType.EMBEDDINGS_PER_RESIDUE: self.get_embeddings_files_path(database_hash),
                StorageFileType.EMBEDDINGS_PER_SEQUENCE: self.get_embeddings_files_path(database_hash),
                StorageFileType.BIOTRAINER_CONFIG: self._get_models_files_path(database_hash) / Path(model_hash),
                StorageFileType.BIOTRAINER_LOGGING: self._get_models_files_path(database_hash) / Path(model_hash),
                StorageFileType.BIOTRAINER_RESULT: self._get_models_files_path(database_hash) / Path(model_hash),
                StorageFileType.BIOTRAINER_CHECKPOINT: self._get_models_files_path(database_hash) / Path(model_hash)
                # Gets searched for pt file(s)
                }[file_type]

    def get_file_name_and_path(self, database_hash: str, file_type: StorageFileType, model_hash: Optional[str],
                               embedder_name: Optional[str] = "") -> Tuple[str, Path]:
        return (self._storage_file_type_to_file_name(file_type=file_type,
                                                    embedder_name=embedder_name),
                self._storage_file_type_to_path(database_hash=database_hash,
                                                file_type=file_type, model_hash=model_hash))
