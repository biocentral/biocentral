#!/usr/bin/env python3
"""Initialize Triton model repository by downloading ONNX models.

This script is run as an init container before Triton starts.
It downloads required ONNX models from HuggingFace or other sources
and places them in the correct directory structure.
"""

import os
import sys
import logging
from pathlib import Path
from typing import Dict, List, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Model repository base path
MODEL_REPO_PATH = Path("/models")

# Model download configuration
# Format: {model_dir: {version: url_or_huggingface_path}}
MODEL_DOWNLOADS = {
    "_internal_esm2_t33_onnx": {
        "version": 1,
        "source_type": "placeholder",  # "huggingface", "url", or "placeholder"
        "source": None,
        "filename": "model.onnx",
        "description": "ESM-2 T33 650M ONNX model",
    },
    "_internal_esm2_t36_onnx": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "ESM-2 T36 3B ONNX model",
    },
    "_internal_prott5_onnx": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "ProtT5 ONNX model",
    },
    "prott5_sec": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "ProtT5 secondary structure prediction model",
    },
    "prott5_cons": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "ProtT5 conservation prediction model",
    },
    "bind_embed": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "Binding sites prediction model",
    },
    "seth": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "SETH disorder prediction model",
    },
    "tmbed": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "TMbed membrane localization model",
    },
    "light_attention_subcell": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "Light attention subcellular localization model",
    },
    "light_attention_membrane": {
        "version": 1,
        "source_type": "placeholder",
        "source": None,
        "filename": "model.onnx",
        "description": "Light attention membrane model",
    },
}


def create_placeholder_model(model_path: Path, description: str) -> None:
    """Create a placeholder file for models that need to be provided.

    Args:
        model_path: Path where the model file should be
        description: Description of the model
    """
    placeholder_content = f"""
# Placeholder for {description}

This is a placeholder file. Replace it with the actual ONNX model file.

To add the real model:
1. Download or export the ONNX model
2. Replace this file with the actual model.onnx file
3. Ensure the file permissions are correct (readable by Triton)

Model path: {model_path}
"""
    model_path.parent.mkdir(parents=True, exist_ok=True)
    model_path.write_text(placeholder_content)
    logger.info(f"Created placeholder at {model_path}")


def download_from_huggingface(repo_id: str, filename: str, output_path: Path) -> bool:
    """Download a model from HuggingFace Hub.

    Args:
        repo_id: HuggingFace repository ID
        filename: Filename in the repository
        output_path: Local path to save the file

    Returns:
        True if successful, False otherwise
    """
    try:
        from huggingface_hub import hf_hub_download

        output_path.parent.mkdir(parents=True, exist_ok=True)
        downloaded_path = hf_hub_download(
            repo_id=repo_id,
            filename=filename,
            cache_dir=str(output_path.parent),
        )
        # Move to final location
        import shutil
        shutil.move(downloaded_path, output_path)
        logger.info(f"Downloaded {repo_id}/{filename} to {output_path}")
        return True
    except Exception as e:
        logger.error(f"Failed to download from HuggingFace: {e}")
        return False


def download_from_url(url: str, output_path: Path) -> bool:
    """Download a model from a URL.

    Args:
        url: URL to download from
        output_path: Local path to save the file

    Returns:
        True if successful, False otherwise
    """
    try:
        import httpx
        from tqdm import tqdm

        output_path.parent.mkdir(parents=True, exist_ok=True)

        with httpx.stream("GET", url) as response:
            response.raise_for_status()
            
            total_size = int(response.headers.get("content-length", 0))

            with open(output_path, "wb") as f, tqdm(
                desc=output_path.name,
                total=total_size,
                unit="B",
                unit_scale=True,
            ) as pbar:
                for chunk in response.iter_bytes(chunk_size=8192):
                    f.write(chunk)
                    pbar.update(len(chunk))

        logger.info(f"Downloaded {url} to {output_path}")
        return True
    except Exception as e:
        logger.error(f"Failed to download from URL: {e}")
        return False


def initialize_model(model_dir: str, config: Dict) -> bool:
    """Initialize a single model.

    Args:
        model_dir: Model directory name
        config: Model configuration

    Returns:
        True if successful, False otherwise
    """
    version = config["version"]
    source_type = config["source_type"]
    source = config["source"]
    filename = config["filename"]
    description = config["description"]

    model_path = MODEL_REPO_PATH / model_dir / str(version) / filename

    # Check if model already exists
    if model_path.exists() and model_path.stat().st_size > 1000:
        logger.info(f"Model {model_dir} already exists at {model_path}")
        return True

    logger.info(f"Initializing model {model_dir}...")

    if source_type == "placeholder":
        create_placeholder_model(model_path, description)
        return True

    elif source_type == "huggingface" and source:
        repo_id, hf_filename = source.split(":", 1)
        return download_from_huggingface(repo_id, hf_filename, model_path)

    elif source_type == "url" and source:
        return download_from_url(source, model_path)

    else:
        logger.warning(f"Unknown source type for {model_dir}: {source_type}")
        create_placeholder_model(model_path, description)
        return True


def verify_model_structure() -> bool:
    """Verify that all required models exist.

    Returns:
        True if all models exist, False otherwise
    """
    all_exist = True

    for model_dir, config in MODEL_DOWNLOADS.items():
        version = config["version"]
        filename = config["filename"]
        model_path = MODEL_REPO_PATH / model_dir / str(version) / filename

        if not model_path.exists():
            logger.error(f"Model file missing: {model_path}")
            all_exist = False
        else:
            size = model_path.stat().st_size
            logger.info(f"Model {model_dir}: {model_path} ({size} bytes)")

    return all_exist


def main() -> int:
    """Main initialization function.

    Returns:
        Exit code (0 for success, 1 for failure)
    """
    logger.info("Starting Triton model repository initialization...")
    logger.info(f"Model repository path: {MODEL_REPO_PATH}")

    # Get list of models to initialize from environment
    models_to_init = os.getenv("MODELS_TO_INITIALIZE", "").split(",")
    if models_to_init == [""]:
        models_to_init = list(MODEL_DOWNLOADS.keys())
    else:
        logger.info(f"Initializing specific models: {models_to_init}")

    # Initialize each model
    success_count = 0
    failed_models = []

    for model_dir in models_to_init:
        if model_dir not in MODEL_DOWNLOADS:
            logger.warning(f"Unknown model: {model_dir}, skipping...")
            continue

        config = MODEL_DOWNLOADS[model_dir]
        if initialize_model(model_dir, config):
            success_count += 1
        else:
            failed_models.append(model_dir)

    # Verify structure
    logger.info("\nVerifying model repository structure...")
    if verify_model_structure():
        logger.info("Model repository structure verified successfully!")
    else:
        logger.warning("Some model files are missing or incomplete")

    # Summary
    logger.info("\nInitialization complete:")
    logger.info(f"  - Successfully initialized: {success_count}/{len(models_to_init)}")
    if failed_models:
        logger.warning(f"  - Failed models: {', '.join(failed_models)}")

    # In development, placeholders are acceptable
    # In production, you might want to fail if models are missing
    skip_validation = os.getenv("SKIP_MODEL_VALIDATION", "false").lower() == "true"

    if failed_models and not skip_validation:
        logger.error("Model initialization failed!")
        return 1

    logger.info("Model initialization successful!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
