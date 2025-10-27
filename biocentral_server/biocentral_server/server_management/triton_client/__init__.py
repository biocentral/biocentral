"""Triton Inference Server client module for biocentral_server.

This module provides infrastructure for connecting to Triton Inference Server
for embedding generation and prediction tasks.

Architecture:
- Triton repositories are lazy-initialized in RQ worker processes on first use
- Each worker process maintains long-lived connections
- Cleanup happens automatically via atexit hooks on worker shutdown
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
from .repository_manager import (
    RepositoryManager,
    get_shared_repository,
    cleanup_repositories,
)
# Kept for backward compatibility but does nothing
from .repository_initializer import TritonRepositoryInitializer

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
    "RepositoryManager",
    "get_shared_repository",
    "cleanup_repositories",
    "TritonRepositoryInitializer",  # DEPRECATED: No-op, kept for backward compatibility
]
