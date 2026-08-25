from __future__ import annotations

from enum import Enum


class StorageFileType(Enum):
    INPUT = (1,)
    BIOTRAINER_CONFIG = (2,)
    BIOTRAINER_LOGGING = (3,)
    BIOTRAINER_RESULT = (4,)
    BIOTRAINER_CHECKPOINT = 5
    ONNX_MODEL = 6
    TOKENIZER_CONFIG = 7

    @staticmethod
    def from_string(file_type: str) -> StorageFileType:
        return {f.name: f for f in StorageFileType}[file_type.upper()]
