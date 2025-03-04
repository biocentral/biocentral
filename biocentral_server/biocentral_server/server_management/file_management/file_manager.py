import base64
import contextlib

from pathlib import Path
from biotrainer.protocols import Protocol
from typing import Optional, Tuple, Union, Any, Dict, Generator

from .path_manager import PathManager
from .storage_file_type import StorageFileType
from .storage_backend import StorageBackend, StorageFileReader, StorageFileWriter, SeaweedFSStorageBackend, \
    StorageError, StorageDirectoryReader


class FileManager:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.path_manager = PathManager(user_id)
        self.storage_backend: StorageBackend = SeaweedFSStorageBackend()

    def get_disk_usage(self) -> str:
        return self.storage_backend.get_disk_usage()

    def check_base_dir_exists(self) -> bool:
        return len(self.storage_backend.list_files(self.user_id)) > 0

    def check_file_exists(self, database_hash: str, file_type: StorageFileType,
                          embedder_name: Optional[str] = "",
                          model_hash: Optional[str] = "") -> bool:
        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash
        )
        try:
            self.storage_backend.get_file(str(file_path / file_name))
            return True
        except StorageError:
            return False

    def save_file(self, database_hash: str, file_type: StorageFileType, file_content: str,
                  embedder_name: Optional[str] = "",
                  model_hash: Optional[str] = "") -> Path:
        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash
        )
        full_path = file_path / file_name
        self.storage_backend.save_file(str(full_path), file_content)
        return full_path

    def get_file_path(self, database_hash: str, file_type: StorageFileType,
                      embedder_name: Optional[str] = "",
                      model_hash: Optional[str] = "",
                      check_exists: Optional[bool] = True) -> Path:
        if check_exists and not self.check_file_exists(
                database_hash=database_hash,
                file_type=file_type,
                embedder_name=embedder_name,
                model_hash=model_hash
        ):
            raise FileNotFoundError("Database Hash does not exist!")

        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash
        )
        return file_path / file_name

    def get_embeddings_path(self, database_hash: str):
        return self.path_manager.get_embeddings_files_path(database_hash=database_hash)

    def get_biotrainer_model_path(self, database_hash: str, model_hash: str) -> Path:
        return self.path_manager.get_biotrainer_model_path(database_hash=database_hash, model_hash=model_hash)

    def get_file_paths_for_biotrainer(self, database_hash: str,
                                      embedder_name: str, protocol: Protocol) -> Tuple[str, str, str, str]:
        sequence_file = self.get_file_path(database_hash=database_hash, file_type=StorageFileType.SEQUENCES)
        labels_file = ""
        mask_file = ""
        if protocol in Protocol.per_residue_protocols():
            labels_file = self.get_file_path(database_hash=database_hash, file_type=StorageFileType.LABELS)
            try:
                mask_file = self.get_file_path(database_hash=database_hash, file_type=StorageFileType.MASKS)
            except FileNotFoundError as e:
                mask_file = ""
        try:
            embeddings_type = StorageFileType.EMBEDDINGS_PER_RESIDUE if protocol in Protocol.per_residue_protocols() \
                else StorageFileType.EMBEDDINGS_PER_SEQUENCE
            embeddings_file = self.get_file_path(database_hash=database_hash, file_type=embeddings_type,
                                                 embedder_name=embedder_name)
        except FileNotFoundError as e:
            embeddings_file = ""
        return str(sequence_file), str(labels_file), str(mask_file), str(embeddings_file)

    def get_biotrainer_result_files(self, database_hash: str, model_hash: str) -> Dict[str, Any]:
        result = {}

        # Get result file
        try:
            result_file = self._get_file_content(
                database_hash=database_hash,
                file_type=StorageFileType.BIOTRAINER_RESULT,
                model_hash=model_hash
            )
            result[StorageFileType.BIOTRAINER_RESULT.name] = result_file
        except FileNotFoundError:
            result[StorageFileType.BIOTRAINER_RESULT.name] = ""

        # Get logging file
        try:
            logging_file = self._get_file_content(
                database_hash=database_hash,
                file_type=StorageFileType.BIOTRAINER_LOGGING,
                model_hash=model_hash
            )
            result[StorageFileType.BIOTRAINER_LOGGING.name] = logging_file
        except FileNotFoundError:
            result[StorageFileType.BIOTRAINER_LOGGING.name] = ""

        # Get checkpoint files
        checkpoint_files = {}
        try:
            _, checkpoint_base_dir = self.path_manager.get_file_name_and_path(
                database_hash=database_hash,
                file_type=StorageFileType.BIOTRAINER_CHECKPOINT,
                model_hash=model_hash
            )

            # List all files in checkpoint directory
            checkpoint_files_list = self.storage_backend.list_files(str(checkpoint_base_dir))
            for file_info in checkpoint_files_list:
                if ".pt" in file_info['name']:
                    file_path = checkpoint_base_dir / file_info['name']
                    checkpoint_bytes = self.storage_backend.get_file(str(file_path))
                    checkpoint_decoded = base64.b64encode(checkpoint_bytes).decode('ascii')
                    checkpoint_files[file_info['name']] = checkpoint_decoded
        except Exception:
            pass

        result[StorageFileType.BIOTRAINER_CHECKPOINT.name] = checkpoint_files
        return result

    def _get_file_content(self, database_hash: str, file_type: StorageFileType,
                          embedder_name: Optional[str] = "",
                          model_hash: Optional[str] = "") -> Union[str, bytes]:
        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash
        )

        content = self.storage_backend.get_file(str(file_path / file_name))

        # Convert to string if not a binary file type
        if file_type not in [StorageFileType.BIOTRAINER_CHECKPOINT]:
            content = content.decode('utf-8')

        return content

class FileContextManager:
    def __init__(self):
        self.storage_backend = SeaweedFSStorageBackend()

    def save_file_temporarily(self, temp_path: Union[str, Path], file_path: Union[str, Path]):
        file_content = self.storage_backend.get_file(str(file_path))
        with open(temp_path, 'wb') as temp_file:
            temp_file.write(file_content)

    @contextlib.contextmanager
    def storage_read(self, file_path: Union[str, Path]) -> Generator[Path, None, None]:
        """Convenience context manager for reading files from the storage backend"""
        with StorageFileReader(self.storage_backend, file_path) as temp_path:
            yield temp_path

    @contextlib.contextmanager
    def storage_dir_read(self, dir_path: Union[str, Path]) -> Generator[Path, None, None]:
        """Convenience context manager for reading entire directories from the storage backend"""
        with StorageDirectoryReader(self.storage_backend, dir_path) as temp_dir:
            yield temp_dir

    @contextlib.contextmanager
    def storage_write(self, file_path: Union[str, Path]) -> Generator[Path, None, None]:
        """Convenience context manager for writing files to the storage backend"""
        with StorageFileWriter(self.storage_backend, file_path) as temp_dir:
            yield temp_dir

