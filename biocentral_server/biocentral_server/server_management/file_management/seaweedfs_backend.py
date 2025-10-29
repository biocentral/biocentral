import os
import requests

from pathlib import Path
from typing import BinaryIO, Union, List, Dict, Any

from .storage_backend import StorageBackend, StorageError

from ...utils import get_logger

logger = get_logger(__name__)


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
                data = data.encode("utf-8")
            elif isinstance(data, BinaryIO):
                data = data.read()

            filename = Path(path).name
            files = {"file": (filename, data, "application/octet-stream")}

            path = path.replace("\\", "")  # Windows compatibility
            response = requests.post(f"{self.filer_url}{path}", files=files)
            response.raise_for_status()
            logger.info(f"Saved file to SeaweedFS: {response.content}")

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
            headers = {"Accept": "application/json", "Content-Type": "application/json"}

            # Use the correct API endpoint for JSON responses
            response = requests.get(
                f"{self.filer_url}{directory}?listing=true", headers=headers
            )

            if response.status_code == 404:
                return []

            response.raise_for_status()

            # Check if we actually received JSON
            if "application/json" in response.headers.get("Content-Type", ""):
                return response.json().get("Entries", [])

            raise StorageError(f"Did not receive file listing as JSON: {response.url}")
        except Exception as e:
            raise StorageError(f"Failed to list files in SeaweedFS: {str(e)}")

    def get_disk_usage(self) -> str:
        # Get disk usage from SeaweedFS system stats
        try:
            response = requests.get(f"{self.filer_url}/dir/status")
            stats = response.json()
            return "{0:.2f}".format(stats.get("TotalSize", 0) / 1e6)
        except Exception:
            return "0.00"

    def _list_files_recursive(self, directory: str) -> List[Dict[str, Any]]:
        """
        Recursively list all files in a directory and its subdirectories
        Returns: List of all file information dictionaries
        """
        all_files = []

        try:
            # Get entries in current directory
            entries = self.list_files(directory)

            for entry in entries:
                full_path = entry.get("FullPath", "")
                file_size = entry.get("FileSize", 0)

                if file_size == 0:  # This is a subdirectory
                    # Recursively get files from subdirectory
                    subdirectory = (
                        full_path if full_path.endswith("/") else f"{full_path}/"
                    )
                    subdirectory_files = self._list_files_recursive(subdirectory)
                    all_files.extend(subdirectory_files)
                else:
                    # This is a file
                    all_files.append(entry)

        except Exception as e:
            logger.error(f"Error listing files in directory {directory}: {str(e)}")

        return all_files
