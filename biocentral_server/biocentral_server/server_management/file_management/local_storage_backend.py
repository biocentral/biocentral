import os
import shutil
from pathlib import Path
from typing import BinaryIO, Union, List, Dict, Any, Optional

from .storage_backend import StorageBackend, StorageError

from ...utils import get_logger

logger = get_logger(__name__)


class LocalStorageBackend(StorageBackend):
    def __init__(self):
        # Default storage directory in the project root or specified by environment variable
        self.base_dir = Path(os.environ.get("FILES_DATA_DIR", "./storage/files"))
        if not self.base_dir.exists():
            self.base_dir.mkdir(parents=True, exist_ok=True)
        logger.info(f"LocalStorageBackend initialized at {self.base_dir.absolute()}")

    def _get_full_path(self, path: str) -> Path:
        # Remove leading slash to join correctly with base_dir
        clean_path = path.lstrip("/")
        return self.base_dir / clean_path

    def save_file(self, path: str, data: Union[bytes, str, BinaryIO]) -> str:
        """
        Save file to local storage
        Returns: relative path to the saved file
        """
        try:
            full_path = self._get_full_path(path)
            full_path.parent.mkdir(parents=True, exist_ok=True)

            if isinstance(data, str):
                full_path.write_text(data, encoding="utf-8")
            elif isinstance(data, bytes):
                full_path.write_bytes(data)
            elif hasattr(data, "read"):
                with open(full_path, "wb") as f:
                    # If it's a file-like object, read it in chunks or fully
                    # SeaweedFS backend reads it fully: data = data.read()
                    f.write(data.read())
            else:
                raise StorageError(f"Unsupported data type: {type(data)}")

            logger.info(f"Saved file to local storage: {full_path}")
            return path
        except Exception as e:
            raise StorageError(f"Failed to save file to local storage: {str(e)}")

    def get_file(self, path: str) -> bytes:
        """
        Retrieve file from local storage
        Returns: file contents as bytes
        """
        try:
            full_path = self._get_full_path(path)
            if not full_path.exists():
                raise StorageError(f"File not found: {path}")
            return full_path.read_bytes()
        except Exception as e:
            raise StorageError(f"Failed to retrieve file from local storage: {str(e)}")

    def check_file_exists(self, file_path: str) -> bool:
        """Check if a file exists in local storage"""
        try:
            full_path = self._get_full_path(file_path)
            return full_path.exists() and full_path.is_file()
        except Exception:
            return False

    def delete_file(self, path: str) -> bool:
        """
        Delete file from local storage
        Returns: True if successful, False if file doesn't exist
        """
        try:
            full_path = self._get_full_path(path)
            if full_path.exists():
                if full_path.is_file():
                    full_path.unlink()
                elif full_path.is_dir():
                    shutil.rmtree(full_path)
                return True
            return False
        except Exception:
            return False

    def list_files(self, directory: str = "/") -> List[Dict[str, Any]]:
        """
        List files in a directory
        Returns: List of file information dictionaries
        """
        try:
            full_dir_path = self._get_full_path(directory)
            if not full_dir_path.exists() or not full_dir_path.is_dir():
                return []

            entries = []
            for item in full_dir_path.iterdir():
                # Emulate SeaweedFS response format
                # SeaweedFS returns 'FullPath' and 'FileSize' (0 for dirs)
                relative_path = os.path.relpath(item, self.base_dir)
                # Ensure it starts with / if it's supposed to be an absolute path within storage
                full_path_str = "/" + relative_path

                size = item.stat().st_size if item.is_file() else 0
                entries.append(
                    {"FullPath": full_path_str, "FileSize": size, "Name": item.name}
                )
            return entries
        except Exception as e:
            raise StorageError(f"Failed to list files in local storage: {str(e)}")

    def get_disk_usage(self) -> str:
        """Get total size of the storage directory in MB"""
        try:
            total_size = 0
            for dirpath, dirnames, filenames in os.walk(self.base_dir):
                for f in filenames:
                    fp = os.path.join(dirpath, f)
                    total_size += os.path.getsize(fp)
            return "{0:.2f}".format(total_size / 1e6)
        except Exception:
            return "0.00"

    def get_local_path(self, path: str) -> Optional[Path]:
        return self._get_full_path(path)
