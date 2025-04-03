from __future__ import annotations

from enum import Enum

class StorageFileType(Enum):
    SEQUENCES = 1,
    LABELS = 2,
    MASKS = 3,
    EMBEDDINGS_PER_RESIDUE = 4,
    EMBEDDINGS_PER_SEQUENCE = 5,
    BIOTRAINER_CONFIG = 6,
    BIOTRAINER_LOGGING = 7,
    BIOTRAINER_RESULT = 8,
    BIOTRAINER_CHECKPOINT = 9
    ONNX_MODEL = 10
    TOKENIZER_CONFIG = 11

    @staticmethod
    def from_string(file_type: str) -> StorageFileType:
        return {f.name: f for f in StorageFileType}[file_type.upper()]