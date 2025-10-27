"""Repository manager for shared Triton inference repository instances.

This module provides a singleton pattern to ensure only one Triton repository
instance is created and shared across the application, preventing unnecessary
connection pool creation and resource waste.

Architecture Note:
- The Flask server process does NOT perform inference - RQ workers do
- Repository is lazy-initialized in worker processes on first use
- Connections are long-lived per worker process
- Cleanup happens on worker shutdown via atexit hooks
"""

import threading
from typing import Optional

from .config import TritonClientConfig
from .repository import TritonInferenceRepository, create_triton_repository
from ...utils import get_logger

logger = get_logger(__name__)


class RepositoryManager:
    """Singleton manager for Triton repository instances.
    
    Manages a single shared repository instance per process. Thread-safe and
    handles connection lifecycle.
    
    Note: Each RQ worker process creates its own singleton instance. The
    singleton pattern ensures multiple threads within a worker share one
    connection pool, but different worker processes have separate pools.
    """
    
    _instance: Optional['RepositoryManager'] = None
    _lock = threading.Lock()
    
    def __init__(self):
        """Initialize the repository manager.
        
        Use get_instance() instead of calling this directly.
        """
        self._repository: Optional[TritonInferenceRepository] = None
        self._connection_lock = threading.Lock()
        self._config: Optional[TritonClientConfig] = None
        
        logger.debug("RepositoryManager singleton created")
    
    @classmethod
    def get_instance(cls) -> 'RepositoryManager':
        """Get the singleton repository manager instance.
        
        Returns:
            RepositoryManager instance
        """
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = cls()
        return cls._instance
    
    def get_repository(self, config: Optional[TritonClientConfig] = None) -> TritonInferenceRepository:
        """Get the shared repository instance, creating it if necessary.
        
        Args:
            config: Optional configuration. If None, uses environment variables.
        
        Returns:
            TritonInferenceRepository instance
        """
        if self._repository is None:
            with self._connection_lock:
                if self._repository is None:
                    if config is None:
                        config = TritonClientConfig.from_env()
                    self._config = config
                    
                    logger.info(f"Creating Triton repository for worker (PID: {threading.get_ident()})")
                    self._repository = create_triton_repository(config)
                    self._repository.connect()
                    logger.info(f"Triton repository connected at {config.triton_grpc_url}")
        return self._repository
    
    def disconnect(self) -> None:
        """Disconnect the repository if it exists."""
        if self._repository is not None:
            with self._connection_lock:
                if self._repository is not None:
                    logger.info("Disconnecting Triton repository")
                    self._repository.disconnect()
                    self._repository = None
    
    @classmethod
    def cleanup_all(cls) -> None:
        """Cleanup all repository instances.
        
        This should be called during worker shutdown (registered via atexit).
        """
        if cls._instance is not None:
            with cls._lock:
                if cls._instance is not None:
                    try:
                        cls._instance.disconnect()
                        logger.info("Triton repository cleanup completed")
                    except Exception as e:
                        logger.warning(f"Error during repository cleanup: {e}")
                    finally:
                        cls._instance = None


# Convenience functions
def get_shared_repository(config: Optional[TritonClientConfig] = None) -> TritonInferenceRepository:
    """Get shared repository instance.
    
    This is the primary entry point for getting a Triton repository in worker
    processes. The repository will be lazy-initialized on first call.
    
    Args:
        config: Optional configuration. If None, uses environment variables.
        
    Returns:
        TritonInferenceRepository instance
    """
    manager = RepositoryManager.get_instance()
    return manager.get_repository(config)


def cleanup_repositories() -> None:
    """Cleanup all repository instances.
    
    Call this during worker shutdown (automatically registered via atexit).
    """
    RepositoryManager.cleanup_all()
