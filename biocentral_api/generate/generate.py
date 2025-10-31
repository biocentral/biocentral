#!/usr/bin/env python3
"""
OpenAPI Client Generator Script

Generates Python client from OpenAPI spec and moves generated docs to the appropriate directory.
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path


def run_command(command, cwd=None):
    """Run a shell command and handle errors."""
    print(f"Running: {' '.join(command)}")
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            check=True,
            capture_output=True,
            text=True
        )
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")
        if e.stderr:
            print(f"Error output: {e.stderr}")
        return False


def clean_directory(directory):
    """Clean a directory by removing all contents."""
    if directory.exists():
        print(f"Cleaning directory: {directory}")
        shutil.rmtree(directory)
    directory.mkdir(parents=True, exist_ok=True)


def move_generated_docs(source_docs_dir, target_docs_dir, existing_manual_docs):
    """Move generated documentation from source to target directory using rsync."""
    if not source_docs_dir.exists():
        print(f"Source docs directory not found: {source_docs_dir}")
        return False

    # Ensure target directory exists
    target_docs_dir.mkdir(parents=True, exist_ok=True)

    print(f"Syncing generated docs from {source_docs_dir} to {target_docs_dir}")

    try:
        # Use rsync to sync only the files that have changed
        # This preserves git's understanding of file modifications
        rsync_command = [
            "rsync",
            "-av",  # archive mode, verbose
            "--delete",  # delete files in target that don't exist in source
            "--exclude-from=-",  # exclude patterns from stdin
            f"{source_docs_dir}/",  # source (trailing slash important)
            f"{target_docs_dir}/"  # target
        ]

        # Create exclude patterns for manual docs
        exclude_patterns = "\n".join(existing_manual_docs) if existing_manual_docs else ""

        result = subprocess.run(
            rsync_command,
            input=exclude_patterns,
            text=True,
            check=True,
            capture_output=True
        )

        if result.stdout:
            print(result.stdout)

        # Remove generated files
        for file in source_docs_dir.iterdir():
            if file.is_file() and file.name not in existing_manual_docs:
                file.unlink()

        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running rsync: {e}")
        if e.stderr:
            print(f"Error output: {e.stderr}")
        return False
    except Exception as e:
        print(f"Error syncing docs: {e}")
        return False


def main():
    """Main function to generate OpenAPI client and organize documentation."""
    # Define paths
    script_dir = Path(__file__).parent
    openapi_spec = script_dir / "openapi.json"
    output_dir = script_dir.parent / "python"
    temp_docs_dir = output_dir / "docs"
    target_docs_dir = output_dir / "docs" / "_generated"

    # Check if OpenAPI spec exists
    if not openapi_spec.exists():
        print(f"Error: OpenAPI spec not found at {openapi_spec}")
        sys.exit(1)

    if not target_docs_dir.exists():
        target_docs_dir.mkdir(parents=True, exist_ok=True)

    existing_manual_docs = list(os.listdir(temp_docs_dir))

    # Prepare the openapi-generator command
    generator_command = [
        "openapi-generator-cli",
        "generate",
        "-g", "python",
        "--package-name", "biocentral_server_api._generated",
        "-i", str(openapi_spec),
        "-o", str(output_dir)
    ]

    print("Generating OpenAPI client...")

    # Run the generator
    if not run_command(generator_command, cwd=script_dir):
        print("Failed to generate OpenAPI client")
        sys.exit(1)

    print("OpenAPI client generated successfully!")

    # Check if docs were generated and need to be moved
    if temp_docs_dir.exists() and any(temp_docs_dir.iterdir()):
        print("Moving generated documentation...")

        # Ensure target directory exists
        target_docs_dir.parent.mkdir(parents=True, exist_ok=True)

        # Move generated docs
        if move_generated_docs(temp_docs_dir, target_docs_dir, existing_manual_docs):
            print("Documentation moved successfully!")
        else:
            print("Warning: Failed to move documentation")
            sys.exit(1)
    else:
        print("No generated documentation found to move")

    print("\nGeneration complete!")
    print(f"Generated client is in: {output_dir}")
    print(f"Generated docs are in: {target_docs_dir}")


if __name__ == "__main__":
    main()