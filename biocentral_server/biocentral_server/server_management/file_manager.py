import os
import base64

from enum import Enum
from typing import Final, List, Optional, Tuple, Union, Any, Dict
from pathlib import Path

from biotrainer.protocols import Protocol


class StorageFileType(Enum):
    SEQUENCES = 1,
    LABELS = 2,
    MASKS = 3,
    EMBEDDINGS_PER_RESIDUE = 4,
    EMBEDDINGS_PER_SEQUENCE = 5,
    BIOTRAINER_CONFIG = 6,
    BIOTRAINER_LOGGING = 7,
    BIOTRAINER_RESULT = 8,
    BIOTRAINER_CHECKPOINT = 9


class FileManager:
    base_path: Final[Path] = Path("storage/")

    _fasta_files_path: Final[Path] = Path("fasta_files/")
    _embeddings_files_path: Final[Path] = Path("embeddings/")
    _models_files_path: Final[Path] = Path("models/")
    _subdirectories_hash_dir: Final[List[Path]] = [_fasta_files_path, _embeddings_files_path, _models_files_path]

    def __init__(self, user_id: str):
        self.user_id = user_id
        os.makedirs(self._base_user_path(), exist_ok=True)

    def _base_user_path(self) -> Path:
        return self.base_path / self.user_id

    def get_fasta_files_path(self, database_hash: str) -> Path:
        return self._base_user_path() / database_hash / self._fasta_files_path

    def get_embeddings_files_path(self, database_hash: str) -> Path:
        return self._base_user_path() / database_hash / self._embeddings_files_path

    def get_models_files_path(self, database_hash: str) -> Path:
        return self._base_user_path() / database_hash / self._models_files_path

    @staticmethod
    def get_disk_usage() -> str:
        return '{0:.2f}'.format(sum(file.stat().st_size for file in FileManager.base_path.rglob('*')) / 1e6)

    @staticmethod
    def _list_dir_absolute(path: Path) -> List[Path]:
        return [path / Path(file_or_dir) for file_or_dir in os.listdir(path=path)]

    @staticmethod
    def convert_file_type_str_to_enum(file_type: str) -> StorageFileType:
        return {f.name: f for f in StorageFileType}[file_type.upper()]

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
        return {StorageFileType.SEQUENCES: self.get_fasta_files_path(database_hash),
                StorageFileType.LABELS: self.get_fasta_files_path(database_hash),
                StorageFileType.MASKS: self.get_fasta_files_path(database_hash),
                StorageFileType.EMBEDDINGS_PER_RESIDUE: self.get_embeddings_files_path(database_hash),
                StorageFileType.EMBEDDINGS_PER_SEQUENCE: self.get_embeddings_files_path(database_hash),
                StorageFileType.BIOTRAINER_CONFIG: self.get_models_files_path(database_hash) / Path(model_hash),
                StorageFileType.BIOTRAINER_LOGGING: self.get_models_files_path(database_hash) / Path(model_hash),
                StorageFileType.BIOTRAINER_RESULT: self.get_models_files_path(database_hash) / Path(model_hash),
                StorageFileType.BIOTRAINER_CHECKPOINT: self.get_models_files_path(database_hash) / Path(model_hash)
                # Gets searched for pt file(s)
                }[file_type]

    def create_hash_dir_structure_if_necessary(self, database_hash: str):
        database_path = Path(self._base_user_path() / database_hash)
        if not os.path.exists(database_path):
            os.makedirs(database_path, exist_ok=True)
            for subdir_path in self._subdirectories_hash_dir:
                os.makedirs(database_path / subdir_path, exist_ok=True)

    def check_file_exists(self, database_hash: str, file_type: StorageFileType,
                          embedder_name: Optional[str] = "",
                          model_hash: Optional[str] = "") -> bool:
        file_name = self._storage_file_type_to_file_name(file_type=file_type, embedder_name=embedder_name)
        file_path = self._storage_file_type_to_path(database_hash=database_hash, file_type=file_type,
                                                    model_hash=model_hash)
        return os.path.exists(file_path / file_name)

    def save_file(self, database_hash: str, file_type: StorageFileType, file_content: str,
                  embedder_name: Optional[str] = "",
                  model_hash: Optional[str] = ""
                  ) -> Path:
        file_name = self._storage_file_type_to_file_name(file_type=file_type, embedder_name=embedder_name)
        file_path = self._storage_file_type_to_path(database_hash=database_hash, file_type=file_type,
                                                    model_hash=model_hash)
        os.makedirs(file_path, exist_ok=True)
        with open(file_path / file_name, "w") as file_to_save:
            file_to_save.write(file_content)
        return file_path / file_name

    def get_file_path(self, database_hash: str, file_type: StorageFileType,
                      embedder_name: Optional[str] = "",
                      model_hash: Optional[str] = "",
                      check_exists: Optional[bool] = True,
                      ) -> Path:
        if check_exists and not self.check_file_exists(database_hash=database_hash, file_type=file_type,
                                                       embedder_name=embedder_name, model_hash=model_hash):
            raise FileNotFoundError("Database Hash does not exist!")
        file_name = self._storage_file_type_to_file_name(file_type=file_type, embedder_name=embedder_name)
        file_path = self._storage_file_type_to_path(database_hash=database_hash, file_type=file_type,
                                                    model_hash=model_hash)
        return file_path / file_name

    def get_file_paths_for_biotrainer(self, database_hash: str,
                                      embedder_name: str, protocol: Protocol) -> Tuple[str, str, str, str]:
        # TODO: Try to replace absolute paths
        sequence_file = self.get_file_path(database_hash=database_hash, file_type=StorageFileType.SEQUENCES).absolute()
        labels_file = ""
        mask_file = ""
        if protocol in Protocol.per_residue_protocols():
            labels_file = self.get_file_path(database_hash=database_hash, file_type=StorageFileType.LABELS).absolute()
            try:
                mask_file = self.get_file_path(database_hash=database_hash, file_type=StorageFileType.MASKS).absolute()
            except FileNotFoundError as e:
                mask_file = ""
        try:
            embeddings_type = StorageFileType.EMBEDDINGS_PER_RESIDUE if protocol in Protocol.per_residue_protocols() \
                else StorageFileType.EMBEDDINGS_PER_SEQUENCE
            embeddings_file = self.get_file_path(database_hash=database_hash, file_type=embeddings_type,
                                                 embedder_name=embedder_name).absolute()
        except FileNotFoundError as e:
            embeddings_file = ""
        return str(sequence_file), str(labels_file), str(mask_file), str(embeddings_file)

    def get_biotrainer_model_path(self, database_hash: str, model_hash: str) -> Path:
        return self.get_models_files_path(database_hash=database_hash) / model_hash

    def get_biotrainer_result_files(self, database_hash: str, model_hash: str) -> Dict[str, Any]:
        try:
            result_file = self.get_file_content(database_hash=database_hash,
                                                file_type=StorageFileType.BIOTRAINER_RESULT, model_hash=model_hash)
        except FileNotFoundError as e:
            result_file = ""
        try:
            logging_file = self.get_file_content(database_hash=database_hash,
                                                 file_type=StorageFileType.BIOTRAINER_LOGGING, model_hash=model_hash)
        except FileNotFoundError as e:
            logging_file = ""
        checkpoint_files = {}
        try:
            # Find checkpoint files within model directory
            checkpoint_base_dir = self._storage_file_type_to_path(database_hash=database_hash,
                                                                  file_type=StorageFileType.BIOTRAINER_CHECKPOINT,
                                                                  model_hash=model_hash)
            for subdir, dirs, files in os.walk(checkpoint_base_dir):
                for file_name in files:
                    if ".pt" in file_name:
                        with open(Path(subdir) / file_name, "rb") as file_to_open:
                            checkpoint_bytes = file_to_open.read()
                            checkpoint_decoded = base64.b64encode(checkpoint_bytes).decode('ascii')
                            checkpoint_files[file_name] = checkpoint_decoded
        except Exception as e:
            checkpoint_files = {}
        return {
            StorageFileType.BIOTRAINER_RESULT.name: result_file,
            StorageFileType.BIOTRAINER_LOGGING.name: logging_file,
            StorageFileType.BIOTRAINER_CHECKPOINT.name: checkpoint_files
        }

    def get_file_content(self, database_hash: str, file_type: StorageFileType, embedder_name: Optional[str] = "",
                         model_hash: Optional[str] = "") -> Union[str, bytes]:
        read_mode = "rb" if file_type in [StorageFileType.BIOTRAINER_CHECKPOINT] else "r"
        with open(self.get_file_path(database_hash=database_hash, file_type=file_type, embedder_name=embedder_name,
                                     model_hash=model_hash), read_mode) as file_to_open:
            content = file_to_open.read()
            return content
