"""Triton Inference Server client module for biocentral_server.

This module provides infrastructure for connecting to Triton Inference Server
for embedding generation and prediction tasks.
"""

from .config import TritonClientConfig
from .exceptions import (
    TritonError,
    TritonConnectionError,
    TritonTimeoutError,
    TritonModelError,
    TritonInferenceError,
    TritonResourceExhaustionError,
)
from .repository import (
    InferenceRepository,
    TritonInferenceRepository,
    create_triton_repository,
)
from .model_router import TritonModelRouter

__all__ = [
    "TritonClientConfig",
    "TritonError",
    "TritonConnectionError",
    "TritonTimeoutError",
    "TritonModelError",
    "TritonInferenceError",
    "TritonResourceExhaustionError",
    "InferenceRepository",
    "TritonInferenceRepository",
    "create_triton_repository",
    "TritonModelRouter",
]
