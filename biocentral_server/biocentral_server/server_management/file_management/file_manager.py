import base64
import contextlib

from pathlib import Path
from typing import Optional, Union, Any, Dict, Generator

from .path_manager import PathManager
from .storage_file_type import StorageFileType
from .storage_backend import (
    StorageBackend,
    StorageFileReader,
    StorageFileWriter,
    StorageError,
    StorageDirectoryReader,
)

from .seaweedfs_backend import SeaweedFSStorageBackend


class FileManager:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.path_manager = PathManager(user_id)
        self.storage_backend: StorageBackend = SeaweedFSStorageBackend()

    def get_disk_usage(self) -> str:
        return self.storage_backend.get_disk_usage()

    def check_base_dir_exists(self) -> bool:
        return len(self.storage_backend.list_files(self.user_id)) > 0

    def check_file_exists(
        self,
        file_type: StorageFileType,
        database_hash: Optional[str] = "",
        embedder_name: Optional[str] = "",
        model_hash: Optional[str] = "",
    ) -> bool:
        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash,
        )
        try:
            self.storage_backend.get_file(str(file_path / file_name))
            return True
        except StorageError:
            return False

    def save_file(
        self,
        file_type: StorageFileType,
        database_hash: Optional[str] = "",
        file_content: Optional[Union[bytes, str]] = None,
        embedder_name: Optional[str] = "",
        model_hash: Optional[str] = "",
    ) -> Path:
        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash,
        )
        full_path = file_path / file_name
        self.storage_backend.save_file(str(full_path), file_content)
        return full_path

    def get_file_path(
        self,
        file_type: StorageFileType,
        database_hash: Optional[str] = "",
        embedder_name: Optional[str] = "",
        model_hash: Optional[str] = "",
        check_exists: Optional[bool] = True,
    ) -> Path:
        if check_exists and not self.check_file_exists(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash,
        ):
            raise FileNotFoundError("Database Hash does not exist!")

        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash,
        )
        return file_path / file_name

    def delete_file(
        self,
        file_type: StorageFileType,
        database_hash: Optional[str] = "",
        embedder_name: Optional[str] = "",
        model_hash: Optional[str] = "",
    ):
        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash,
        )
        full_path = file_path / file_name
        return self.storage_backend.delete_file(str(full_path))

    def get_embeddings_path(self, database_hash: str):
        return self.path_manager.get_embeddings_files_path(database_hash=database_hash)

    def get_biotrainer_model_path(self, model_hash: str) -> Path:
        return self.path_manager.get_biotrainer_model_path(model_hash=model_hash)

    def get_autoeval_path(self, embedder_name: str) -> Path:
        return self.path_manager.base_path / "autoeval" / embedder_name

    def get_file_path_for_training(self, database_hash: str) -> Path:
        input_file = self.get_file_path(
            file_type=StorageFileType.INPUT, database_hash=database_hash
        )
        return input_file

    def get_biotrainer_result_files(self, model_hash: str) -> Dict[str, Any]:
        result = {}

        # Get result file
        try:
            result_file = self._get_file_content(
                file_type=StorageFileType.BIOTRAINER_RESULT, model_hash=model_hash
            )
            result[StorageFileType.BIOTRAINER_RESULT.name] = result_file
        except FileNotFoundError:
            result[StorageFileType.BIOTRAINER_RESULT.name] = ""

        # Get logging file
        try:
            logging_file = self._get_file_content(
                file_type=StorageFileType.BIOTRAINER_LOGGING, model_hash=model_hash
            )
            result[StorageFileType.BIOTRAINER_LOGGING.name] = logging_file
        except FileNotFoundError:
            result[StorageFileType.BIOTRAINER_LOGGING.name] = ""

        # Get checkpoint files
        checkpoint_files = {}
        try:
            _, checkpoint_base_dir = self.path_manager.get_file_name_and_path(
                file_type=StorageFileType.BIOTRAINER_CHECKPOINT, model_hash=model_hash
            )

            # List all files in checkpoint directory
            checkpoint_files_list = self.storage_backend.list_files(
                str(checkpoint_base_dir)
            )
            for file_info in checkpoint_files_list:
                if ".pt" in file_info["name"]:
                    file_path = checkpoint_base_dir / file_info["name"]
                    checkpoint_bytes = self.storage_backend.get_file(str(file_path))
                    checkpoint_decoded = base64.b64encode(checkpoint_bytes).decode(
                        "ascii"
                    )
                    checkpoint_files[file_info["name"]] = checkpoint_decoded
        except Exception:
            pass

        result[StorageFileType.BIOTRAINER_CHECKPOINT.name] = checkpoint_files
        return result

    def _get_file_content(
        self,
        file_type: StorageFileType,
        database_hash: Optional[str] = "",
        embedder_name: Optional[str] = "",
        model_hash: Optional[str] = "",
    ) -> Union[str, bytes]:
        file_name, file_path = self.path_manager.get_file_name_and_path(
            database_hash=database_hash,
            file_type=file_type,
            embedder_name=embedder_name,
            model_hash=model_hash,
        )

        content = self.storage_backend.get_file(str(file_path / file_name))

        # Convert to string if not a binary file type
        if file_type not in [StorageFileType.BIOTRAINER_CHECKPOINT]:
            content = content.decode("utf-8")

        return content


class FileContextManager:
    def __init__(self):
        self.storage_backend = SeaweedFSStorageBackend()

    def save_file_temporarily(
        self, temp_path: Union[str, Path], file_path: Union[str, Path]
    ):
        file_content = self.storage_backend.get_file(str(file_path))
        with open(temp_path, "wb") as temp_file:
            temp_file.write(file_content)

    def rename_directory(
        self, old_path: Union[str, Path], new_path: Union[str, Path]
    ) -> bool:
        return self.storage_backend.rename_directory(old_path, new_path)

    @contextlib.contextmanager
    def storage_read(
        self, file_path: Union[str, Path], suffix: str = None
    ) -> Generator[Path, None, None]:
        """Convenience context manager for reading files from the storage backend"""
        with StorageFileReader(self.storage_backend, file_path, suffix) as temp_path:
            yield temp_path

    @contextlib.contextmanager
    def storage_dir_read(
        self, dir_path: Union[str, Path]
    ) -> Generator[Path, None, None]:
        """Convenience context manager for reading entire directories from the storage backend"""
        with StorageDirectoryReader(self.storage_backend, dir_path) as temp_dir:
            yield temp_dir

    @contextlib.contextmanager
    def storage_write(self, file_path: Union[str, Path]) -> Generator[Path, None, None]:
        """Convenience context manager for writing files to the storage backend"""
        with StorageFileWriter(self.storage_backend, file_path) as writer:
            yield writer.temp_dir

    @contextlib.contextmanager
    def storage_write_dynamic(self) -> Generator[StorageFileWriter, None, None]:
        """Convenience context manager for writing files to the storage backend dynamically (initial save path unknown)"""
        with StorageFileWriter(self.storage_backend, file_path=None) as writer:
            yield writer
