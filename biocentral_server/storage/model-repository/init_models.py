#!/usr/bin/env python3
"""Initialize Triton model repository by downloading ONNX models.

This script is run as an init container before Triton starts.
It downloads ONNX models from configured URLs and places them
in the correct directory structure based on explicit folder:url pairs.
"""

import os
import sys
import logging
import shlex
import tarfile
from pathlib import Path
from typing import List, Tuple

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Model repository base path
MODEL_REPO_PATH = Path(os.getenv("MODEL_REPOSITORY_PATH", "/models"))


def is_archive_url(url: str) -> bool:
    """Check if URL points to an archive file.
    
    Args:
        url: URL to check
        
    Returns:
        True if URL ends with .tar.gz or .tgz, False otherwise
    """
    return url.endswith('.tar.gz') or url.endswith('.tgz')


def parse_folder_spec(folder_spec: str) -> Tuple[str, str]:
    """Parse folder specification into folder name and version.
    
    Examples:
        "tmbed/1" -> ("tmbed", "1")
        "tmbed" -> ("tmbed", "1")
        "_internal_esm2_t33_onnx/2" -> ("_internal_esm2_t33_onnx", "2")
    
    Args:
        folder_spec: Folder specification string
        
    Returns:
        Tuple of (folder_name, version)
    """
    if "/" in folder_spec:
        folder, version = folder_spec.rsplit("/", 1)
        return folder.strip(), version.strip()
    return folder_spec.strip(), "1"


def extract_archive(archive_path: Path, target_dir: Path) -> bool:
    """Extract tar.gz archive to target directory.
    
    Args:
        archive_path: Path to the tar.gz archive
        target_dir: Directory to extract to
        
    Returns:
        True if successful, False otherwise
    """
    try:
        logger.info(f"Extracting {archive_path} to {target_dir}")
        with tarfile.open(archive_path, 'r:gz') as tar:
            tar.extractall(path=target_dir)
        
        # List extracted files for verification
        extracted_files = list(target_dir.rglob("*"))
        logger.info(f"Extracted {len(extracted_files)} files to {target_dir}")
        for file_path in extracted_files:
            if file_path.is_file():
                logger.info(f"  - {file_path.relative_to(target_dir)}")
        
        return True
    except Exception as e:
        logger.error(f"Failed to extract archive {archive_path}: {e}")
        return False


def download_file(url: str, output_path: Path) -> bool:
    """Download a file from a URL with progress tracking.
    
    Args:
        url: URL to download from
        output_path: Local path to save the file
        
    Returns:
        True if successful, False otherwise
    """
    try:
        import httpx
        from tqdm import tqdm
        
        logger.info(f"Downloading {url} to {output_path}")
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with httpx.stream("GET", url, timeout=300.0) as response:
            response.raise_for_status()
            
            total_size = int(response.headers.get("content-length", 0))
            if total_size == 0:
                logger.warning(f"No content-length header for {url}")
            
            with open(output_path, "wb") as f, tqdm(
                desc=output_path.name,
                total=total_size if total_size > 0 else None,
                unit="B",
                unit_scale=True,
                unit_divisor=1024,
            ) as pbar:
                for chunk in response.iter_bytes(chunk_size=8192):
                    f.write(chunk)
                    pbar.update(len(chunk))
        
        logger.info(f"Successfully downloaded {url} to {output_path}")
        return True
        
    except httpx.TimeoutException:
        logger.error(f"Timeout downloading {url}")
        return False
    except httpx.HTTPStatusError as e:
        logger.error(f"HTTP error downloading {url}: {e.response.status_code}")
        return False
    except Exception as e:
        logger.error(f"Failed to download {url}: {e}")
        return False


def parse_model_downloads() -> List[Tuple[str, str]]:
    """Parse MODEL_DOWNLOADS environment variable.
    
    Expected format: "folder1:url1 folder2:url2 folder3:url3"
    
    Returns:
        List of (folder_name, url) tuples
    """
    downloads_str = os.getenv("MODEL_DOWNLOADS", "")
    
    if not downloads_str:
        logger.error("MODEL_DOWNLOADS environment variable must be set")
        logger.error("Example: MODEL_DOWNLOADS='_internal_esm2_t33_onnx:https://example.com/esm2.onnx prott5_sec:https://example.com/sec.onnx'")
        sys.exit(1)
    
    # Parse space-separated "folder:url" pairs
    downloads = []
    for pair in shlex.split(downloads_str):
        if ":" not in pair:
            logger.error(f"Invalid download pair format: {pair}. Expected 'folder:url'")
            sys.exit(1)
        
        folder, url = pair.split(":", 1)
        downloads.append((folder.strip(), url.strip()))
    
    logger.info(f"Configured downloads: {len(downloads)} pairs")
    for folder, url in downloads:
        logger.info(f"  {folder} -> {url}")
    
    return downloads


def validate_onnx_file(file_path: Path) -> bool:
    """Validate that a file is a valid ONNX model.
    
    Args:
        file_path: Path to the ONNX file
        
    Returns:
        True if valid ONNX file, False otherwise
    """
    if not file_path.exists():
        return False
    
    # Check file size (should be at least 1KB for a real model)
    if file_path.stat().st_size < 1024:
        logger.warning(f"ONNX file {file_path} is too small ({file_path.stat().st_size} bytes)")
        return False
    
    # Check ONNX magic bytes
    try:
        with open(file_path, "rb") as f:
            header = f.read(8)
            # ONNX files start with specific magic bytes
            if not header.startswith(b"ONNX"):
                logger.warning(f"File {file_path} does not appear to be a valid ONNX file")
                return False
    except Exception as e:
        logger.error(f"Error reading file {file_path}: {e}")
        return False
    
    return True


def download_model(url: str, output_path: Path) -> bool:
    """Download a model from a URL with progress tracking and validation.
    
    Args:
        url: URL to download from
        output_path: Local path to save the file
        
    Returns:
        True if successful, False otherwise
    """
    try:
        import httpx
        from tqdm import tqdm
        
        logger.info(f"Downloading {url} to {output_path}")
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Download to temporary file first (atomic write)
        temp_path = output_path.with_suffix(output_path.suffix + ".tmp")
        
        with httpx.stream("GET", url, timeout=300.0) as response:
            response.raise_for_status()
            
            total_size = int(response.headers.get("content-length", 0))
            if total_size == 0:
                logger.warning(f"No content-length header for {url}")
            
            with open(temp_path, "wb") as f, tqdm(
                desc=output_path.name,
                total=total_size if total_size > 0 else None,
                unit="B",
                unit_scale=True,
                unit_divisor=1024,
            ) as pbar:
                for chunk in response.iter_bytes(chunk_size=8192):
                    f.write(chunk)
                    pbar.update(len(chunk))
        
        # Validate the downloaded file
        if not validate_onnx_file(temp_path):
            temp_path.unlink(missing_ok=True)
            return False
        
        # Atomic move to final location
        temp_path.rename(output_path)
        logger.info(f"Successfully downloaded {url} to {output_path}")
        return True
        
    except httpx.TimeoutException:
        logger.error(f"Timeout downloading {url}")
        return False
    except httpx.HTTPStatusError as e:
        logger.error(f"HTTP error downloading {url}: {e.response.status_code}")
        return False
    except Exception as e:
        logger.error(f"Failed to download {url}: {e}")
        return False


def download_to_folder(folder_spec: str, url: str) -> bool:
    """Download a model to a specific folder.
    
    Supports:
    - Single ONNX files: downloads to {folder}/{version}/model.onnx
    - tar.gz archives: extracts to {folder}/{version}/
    
    Args:
        folder_spec: Folder specification (e.g., "tmbed/1", "prott5_sec")
        url: URL to download from
        
    Returns:
        True if successful, False otherwise
    """
    folder_name, version = parse_folder_spec(folder_spec)
    target_dir = MODEL_REPO_PATH / folder_name / version
    
    if is_archive_url(url):
        # Download and extract archive
        logger.info(f"Processing archive for {folder_spec} from {url}")
        
        # Check if target directory already has content
        if target_dir.exists() and any(target_dir.iterdir()):
            logger.info(f"Archive already extracted to {target_dir}")
            return True
        
        # Download archive to temporary location
        archive_path = target_dir / "download.tar.gz"
        target_dir.mkdir(parents=True, exist_ok=True)
        
        if not download_file(url, archive_path):
            return False
        
        if not extract_archive(archive_path, target_dir):
            return False
        
        # Clean up archive
        archive_path.unlink()
        logger.info(f"✓ Successfully extracted archive to {target_dir}")
        return True
    else:
        # Download single ONNX file
        model_path = target_dir / "model.onnx"
        
        # Check if already exists and is valid
        if model_path.exists() and validate_onnx_file(model_path):
            logger.info(f"Model {folder_spec} already exists and is valid at {model_path}")
            return True
        
        logger.info(f"Downloading single file for {folder_spec} from {url}")
        return download_model(url, model_path)


def main() -> int:
    """Main initialization function.
    
    Returns:
        Exit code (0 for success, 1 for failure)
    """
    logger.info("Starting Triton model repository initialization...")
    logger.info(f"Model repository path: {MODEL_REPO_PATH}")
    
    # Parse environment variables
    downloads = parse_model_downloads()
    
    # Download each model
    successful_downloads = []
    failed_downloads = []
    
    for folder_spec, url in downloads:
        if download_to_folder(folder_spec, url):
            successful_downloads.append(folder_spec)
            logger.info(f"✓ Successfully processed {folder_spec}")
        else:
            failed_downloads.append(folder_spec)
            logger.error(f"✗ Failed to process {folder_spec}")
    
    # Summary
    logger.info("\n" + "="*60)
    logger.info("DOWNLOAD SUMMARY")
    logger.info("="*60)
    logger.info(f"Successfully downloaded: {len(successful_downloads)}/{len(downloads)}")
    
    if successful_downloads:
        logger.info("Successful downloads:")
        for folder_spec in successful_downloads:
            logger.info(f"  ✓ {folder_spec}")
    
    if failed_downloads:
        logger.error("Failed downloads:")
        for folder_spec in failed_downloads:
            logger.error(f"  ✗ {folder_spec}")
        logger.error("Model download failed!")
        return 1
    
    logger.info("Model download successful!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
