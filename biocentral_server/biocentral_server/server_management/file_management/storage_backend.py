import os
import shutil
import logging
import requests
import tempfile

from pathlib import Path
from typing import Dict, List, Any
from abc import ABC, abstractmethod
from typing import Union, BinaryIO

logger = logging.getLogger(__name__)


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
    def __init__(self, storage_backend: StorageBackend, file_path: Union[str, Path], suffix: str = None, ):
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

    def __init__(self, storage_backend: StorageBackend, directory_path: Union[str, Path]):
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
        remote_dir = remote_path if remote_path.endswith('/') else f"{remote_path}/"

        # Get directory listing
        entries = self.storage_backend.list_files(remote_dir)

        for entry in entries:
            entry_name = entry.get('FullPath', '').split('/')[-1]
            if not entry_name:
                continue

            remote_entry_path = f"{remote_dir}{entry_name}"
            local_entry_path = local_dir / entry_name

            # Check if this is a directory
            if entry.get('FileSize', 0) == 0:
                # Create local directory
                local_entry_path.mkdir(exist_ok=True)
                # Recursively download contents
                self._download_directory(
                    remote_entry_path,
                    local_entry_path
                )
            else:
                # Download file
                try:
                    content = self.storage_backend.get_file(remote_entry_path)
                    with open(local_entry_path, 'wb') as f:
                        f.write(content)
                except Exception as e:
                    logger.warning(f"Error downloading {remote_entry_path}: {e}")


class StorageFileWriter:
    def __init__(self, storage_backend: StorageBackend, file_path: Union[str, Path]):
        self.storage_backend = storage_backend
        self.file_path = str(file_path)
        self.temp_dir = None

    def __enter__(self) -> Path:
        # Create a temporary directory
        self.temp_dir = Path(tempfile.mkdtemp())
        return self.temp_dir

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is None:  # Only sync if no exception occurred and saving is enabled
            # Sync all files in temp directory to SeaweedFS
            for file_path in self.temp_dir.rglob('*'):
                if file_path.is_file():
                    relative_path = file_path.relative_to(self.temp_dir)
                    target_path = Path(self.file_path) / relative_path
                    with open(file_path, 'rb') as f:
                        self.storage_backend.save_file(str(target_path), f)

        # Clean up temporary directory
        shutil.rmtree(self.temp_dir)


class SeaweedFSStorageBackend(StorageBackend):
    def __init__(self):
        filer_host = os.environ.get("SEAWEEDFS_FILER_HOST", "seaweedfs-filer")
        filer_port = os.environ.get("SEAWEEDFS_FILER_PORT", 8888)
        self.filer_url: str = f"http://{filer_host}:{filer_port}/"

    def save_file(self, path: str, data: Union[bytes, str, BinaryIO]) -> str:
        """
        Save file to SeaweedFS
        Returns: full path to the saved file
        """
        try:
            # Prepare data
            if isinstance(data, str):
                data = data.encode('utf-8')
            elif isinstance(data, BinaryIO):
                data = data.read()

            filename = Path(path).name
            files = {
                'file': (filename, data, 'application/octet-stream')
            }

            path = path.replace("\\", "")  # Windows compatibility
            response = requests.post(
                f"{self.filer_url}{path}",
                files=files
            )
            logger.info(f"Saved file to SeaweedFS: {response.content}")
            response.raise_for_status()

            return path
        except Exception as e:
            raise StorageError(f"Failed to save file to SeaweedFS: {str(e)}")

    def get_file(self, path: str) -> bytes:
        """
        Retrieve file from SeaweedFS
        Returns: file contents as bytes
        """
        try:
            response = requests.get(f"{self.filer_url}{path}")
            response.raise_for_status()
            return response.content
        except Exception as e:
            raise StorageError(f"Failed to retrieve file from SeaweedFS: {str(e)}")

    def check_file_exists(self, file_path: str) -> bool:
        """Check if a file exists in SeaweedFS"""
        try:
            response = requests.head(f"{self.filer_url}{file_path}")
            return response.status_code < 400
        except Exception:
            return False

    def delete_file(self, path: str) -> bool:
        """
        Delete file from SeaweedFS
        Returns: True if successful, False if file doesn't exist
        """
        try:
            response = requests.delete(f"{self.filer_url}{path}")
            return response.status_code in (200, 204, 404)
        except Exception:
            return False

    def list_files(self, directory: str = "/") -> List[Dict[str, Any]]:
        """
        List files in a directory
        Returns: List of file information dictionaries
        """
        try:
            # Request JSON explicitly with correct headers
            headers = {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }

            # Use the correct API endpoint for JSON responses
            response = requests.get(
                f"{self.filer_url}{directory}?listing=true",
                headers=headers
            )

            if response.status_code == 404:
                return []

            response.raise_for_status()

            # Check if we actually received JSON
            if 'application/json' in response.headers.get('Content-Type', ''):
                return response.json().get('Entries', [])

            raise StorageError(f"Did not receive file listing as JSON: {response.url}")
        except Exception as e:
            raise StorageError(f"Failed to list files in SeaweedFS: {str(e)}")

    def get_disk_usage(self) -> str:
        # Get disk usage from SeaweedFS system stats
        try:
            response = requests.get(f"{self.filer_url}/dir/status")
            stats = response.json()
            return '{0:.2f}'.format(stats.get('TotalSize', 0) / 1e6)
        except Exception:
            return '0.00'


class StorageError(Exception):
    """Custom exception for storage-related errors"""
    pass
