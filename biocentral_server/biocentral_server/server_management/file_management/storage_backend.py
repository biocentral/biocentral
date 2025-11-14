from __future__ import annotations

import shutil
import tempfile

from pathlib import Path
from typing import Dict, List, Any, Optional
from typing import Union, BinaryIO
from abc import ABC, abstractmethod

from ...utils import get_logger

logger = get_logger(__name__)


class StorageBackend(ABC):
    @abstractmethod
    def save_file(self, path: str, data: Union[bytes, str, BinaryIO]) -> str:
        raise NotImplementedError

    @abstractmethod
    def get_file(self, path: str) -> bytes:
        raise NotImplementedError

    @abstractmethod
    def check_file_exists(self, path: str) -> bool:
        raise NotImplementedError

    @abstractmethod
    def delete_file(self, path: str) -> bool:
        raise NotImplementedError

    @abstractmethod
    def list_files(self, path: str) -> List[Dict[str, Any]]:
        raise NotImplementedError

    @abstractmethod
    def get_disk_usage(self) -> str:
        raise NotImplementedError


class StorageFileReader:
    def __init__(
        self,
        storage_backend: StorageBackend,
        file_path: Union[str, Path],
        suffix: str = None,
    ):
        self.storage_backend = storage_backend
        self.file_path = str(file_path)
        self.suffix = suffix
        self.temp_file = None

    def __enter__(self) -> Path:
        # Create a temporary file
        self.temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=self.suffix)
        # Get content from SeaweedFS
        content = self.storage_backend.get_file(self.file_path)
        # Write content to temporary file
        self.temp_file.write(content)
        self.temp_file.flush()
        return Path(self.temp_file.name)

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.temp_file:
            self.temp_file.close()
            Path(self.temp_file.name).unlink()  # Delete the temporary file


class StorageDirectoryReader:
    """Context manager for downloading entire directories from storage backend to local temp directory"""

    def __init__(
        self, storage_backend: StorageBackend, directory_path: Union[str, Path]
    ):
        self.storage_backend = storage_backend
        self.directory_path = str(directory_path)
        self.temp_dir = None

    def __enter__(self) -> Path:
        """
        Downloads the entire directory from storage and returns the local temp directory path
        """
        # Create temporary directory
        self.temp_dir = Path(tempfile.mkdtemp())

        # Download the directory contents recursively
        self._download_directory(self.directory_path, self.temp_dir)

        return self.temp_dir

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Clean up the temporary directory when exiting context"""
        if self.temp_dir and self.temp_dir.exists():
            shutil.rmtree(self.temp_dir)

    def _download_directory(self, remote_path: str, local_dir: Path) -> None:
        """
        Recursively download a directory and its contents

        Args:
            remote_path: Path in storage backend
            local_dir: Local directory to save files to
        """
        # Ensure trailing slash for directory listing
        remote_dir = remote_path if remote_path.endswith("/") else f"{remote_path}/"

        # Get directory listing
        entries = self.storage_backend.list_files(remote_dir)

        for entry in entries:
            entry_name = entry.get("FullPath", "").split("/")[-1]
            if not entry_name:
                continue

            remote_entry_path = f"{remote_dir}{entry_name}"
            local_entry_path = local_dir / entry_name

            # Check if this is a directory
            if entry.get("FileSize", 0) == 0:
                # Create local directory
                local_entry_path.mkdir(exist_ok=True)
                # Recursively download contents
                self._download_directory(remote_entry_path, local_entry_path)
            else:
                # Download file
                try:
                    content = self.storage_backend.get_file(remote_entry_path)
                    with open(local_entry_path, "wb") as f:
                        f.write(content)
                except Exception as e:
                    logger.warning(f"Error downloading {remote_entry_path}: {e}")


class StorageFileWriter:
    def __init__(
        self, storage_backend: StorageBackend, file_path: Union[str, Path, None]
    ):
        self.storage_backend = storage_backend
        self.file_path: Optional[str] = str(file_path) if file_path else None
        self.temp_dir = None

    def __enter__(self) -> StorageFileWriter:
        # Create a temporary directory
        self.temp_dir = Path(tempfile.mkdtemp())
        return self

    def set_file_path(self, file_path: Union[str, Path]):
        if self.file_path:
            logger.warning("File path already set in StorageFileWriter. Overwriting.")
        self.file_path = str(file_path)

    def _cleanup(self):
        # Clean up temporary directory
        shutil.rmtree(self.temp_dir)

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is None:  # Only sync if no exception occurred and saving is enabled
            if self.file_path is None:
                self._cleanup()
                raise StorageError("File path not set in StorageFileWriter!")
            # Sync all files in temp directory to SeaweedFS
            for file_path in self.temp_dir.rglob("*"):
                if file_path.is_file():
                    relative_path = file_path.relative_to(self.temp_dir)
                    target_path = Path(self.file_path) / relative_path
                    with open(file_path, "rb") as f:
                        self.storage_backend.save_file(str(target_path), f)

        self._cleanup()


class StorageError(Exception):
    """Custom exception for storage-related errors"""

    pass
