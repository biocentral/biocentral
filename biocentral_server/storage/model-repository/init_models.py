#!/usr/bin/env python3
"""Initialize Triton model repository by downloading ONNX models.

This script is run as an init container before Triton starts.
It downloads required ONNX models from configured URLs and places them
in the correct directory structure.
"""

import os
import sys
import logging
import shlex
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import tempfile

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Model repository base path
MODEL_REPO_PATH = Path(os.getenv("MODEL_REPOSITORY_PATH", "/models"))

# Model configuration mapping
# Maps Triton model names to their internal structure
MODEL_CONFIGS = {
    # Embedding models
    "prot_t5_pipeline": {
        "internal_models": ["_internal_prott5_tokenizer", "_internal_prott5_onnx"],
        "description": "ProtT5 embedding pipeline",
    },
    "esm2_t33_pipeline": {
        "internal_models": ["_internal_esm2_tokenizer", "_internal_esm2_t33_onnx"],
        "description": "ESM2-t33 embedding pipeline",
    },
    "esm2_t36_pipeline": {
        "internal_models": ["_internal_esm2_tokenizer", "_internal_esm2_t36_onnx"],
        "description": "ESM2-t36 embedding pipeline",
    },
    # Prediction models
    "prott5_sec": {
        "internal_models": ["prott5_sec"],
        "description": "ProtT5 secondary structure prediction",
    },
    "prott5_cons": {
        "internal_models": ["prott5_cons"],
        "description": "ProtT5 conservation prediction",
    },
    "bind_embed": {
        "internal_models": ["_bind_embed_cv0", "_bind_embed_cv1", "_bind_embed_cv2", "_bind_embed_cv3", "_bind_embed_cv4"],
        "description": "Binding sites prediction ensemble",
    },
    "seth": {
        "internal_models": ["seth"],
        "description": "SETH disorder prediction",
    },
    "tmbed": {
        "internal_models": ["tmbed"],
        "description": "TMbed membrane localization",
    },
    "light_attention_subcell": {
        "internal_models": ["light_attention_subcell"],
        "description": "Light attention subcellular localization",
    },
    "light_attention_membrane": {
        "internal_models": ["light_attention_membrane"],
        "description": "Light attention membrane localization",
    },
    "vespag": {
        "internal_models": ["vespag"],
        "description": "VespaG variant effect prediction",
    },
}


def parse_environment_arrays() -> Tuple[List[str], List[str]]:
    """Parse MODEL_NAMES and MODEL_URLS from environment variables.
    
    Returns:
        Tuple of (model_names, model_urls) lists
    """
    model_names_str = os.getenv("MODEL_NAMES", "")
    model_urls_str = os.getenv("MODEL_URLS", "")
    
    if not model_names_str or not model_urls_str:
        logger.error("Both MODEL_NAMES and MODEL_URLS environment variables must be set")
        logger.error("Example: MODEL_NAMES='esm2_t33_pipeline prott5_sec' MODEL_URLS='https://... https://...'")
        sys.exit(1)
    
    # Parse bash array format (space-separated values)
    model_names = shlex.split(model_names_str)
    model_urls = shlex.split(model_urls_str)
    
    if len(model_names) != len(model_urls):
        logger.error(f"MODEL_NAMES and MODEL_URLS must have the same length: {len(model_names)} vs {len(model_urls)}")
        sys.exit(1)
    
    logger.info(f"Configured models: {model_names}")
    logger.info(f"Configured URLs: {model_urls}")
    
    return model_names, model_urls


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


def initialize_model(model_name: str, url: str) -> bool:
    """Initialize a single model by downloading its ONNX file.
    
    Args:
        model_name: Triton model name
        url: URL to download the model from
        
    Returns:
        True if successful, False otherwise
    """
    if model_name not in MODEL_CONFIGS:
        logger.error(f"Unknown model: {model_name}")
        return False
    
    config = MODEL_CONFIGS[model_name]
    internal_models = config["internal_models"]
    description = config["description"]
    
    logger.info(f"Initializing {model_name} ({description})")
    
    # For most models, we download a single ONNX file
    # For bind_embed, we need to handle the ensemble structure
    if model_name == "bind_embed":
        # For bind_embed, we expect 5 separate ONNX files for the CV models
        success = True
        for i, internal_model in enumerate(internal_models):
            model_path = MODEL_REPO_PATH / internal_model / "1" / "model.onnx"
            
            # Check if already exists and is valid
            if model_path.exists() and validate_onnx_file(model_path):
                logger.info(f"Model {internal_model} already exists and is valid")
                continue
            
            # For bind_embed, we need separate URLs for each CV model
            # For now, we'll use the same URL and let the user provide separate files
            if not download_model(url, model_path):
                logger.error(f"Failed to download {internal_model}")
                success = False
        return success
    else:
        # Single model download
        internal_model = internal_models[0]  # Most models have one internal model
        model_path = MODEL_REPO_PATH / internal_model / "1" / "model.onnx"
        
        # Check if already exists and is valid
        if model_path.exists() and validate_onnx_file(model_path):
            logger.info(f"Model {internal_model} already exists and is valid")
            return True
        
        return download_model(url, model_path)


def write_success_state(initialized_models: List[str]) -> None:
    """Write the list of successfully initialized models to a file.
    
    Args:
        initialized_models: List of model names that were successfully initialized
    """
    success_file = MODEL_REPO_PATH / ".initialized_models"
    success_file.write_text("\n".join(initialized_models) + "\n")
    logger.info(f"Wrote success state to {success_file}")


def main() -> int:
    """Main initialization function.
    
    Returns:
        Exit code (0 for success, 1 for failure)
    """
    logger.info("Starting Triton model repository initialization...")
    logger.info(f"Model repository path: {MODEL_REPO_PATH}")
    
    # Parse environment variables
    model_names, model_urls = parse_environment_arrays()
    
    # Initialize each model
    initialized_models = []
    failed_models = []
    
    for model_name, url in zip(model_names, model_urls):
        if initialize_model(model_name, url):
            initialized_models.append(model_name)
            logger.info(f"✓ Successfully initialized {model_name}")
        else:
            failed_models.append(model_name)
            logger.error(f"✗ Failed to initialize {model_name}")
    
    # Write success state
    write_success_state(initialized_models)
    
    # Summary
    logger.info("\n" + "="*60)
    logger.info("INITIALIZATION SUMMARY")
    logger.info("="*60)
    logger.info(f"Successfully initialized: {len(initialized_models)}/{len(model_names)}")
    
    if initialized_models:
        logger.info("Initialized models:")
        for model in initialized_models:
            logger.info(f"  ✓ {model}")
    
    if failed_models:
        logger.error("Failed models:")
        for model in failed_models:
            logger.error(f"  ✗ {model}")
        logger.error("Model initialization failed!")
        return 1
    
    logger.info("Model initialization successful!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
