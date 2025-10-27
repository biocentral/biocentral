"""Triton repository initializer for server startup.

This module provides a ServerModuleInitializer that initializes the shared
Triton repository during server startup, ensuring it's available throughout
the server lifecycle.
"""


from ..server_initialization.server_module_initialization import ServerModuleInitializer
from .config import TritonClientConfig
from .repository_manager import RepositoryManager
from biocentral_server.utils import get_logger

logger = get_logger(__name__)


class TritonRepositoryInitializer(ServerModuleInitializer):
    """Initializer for Triton repository during server startup.
    
    This initializer ensures that the shared Triton repository is created
    and connected during server startup, eliminating the need for repeated
    connection/disconnection cycles during inference.
    """
    
    def check_one_time_setup_is_done(self) -> bool:
        """Check if the one_time_setup has already been performed.
        
        Returns:
            True - no one-time setup needed for Triton repository
        """
        return True
    
    def one_time_setup(self) -> None:
        """Perform tasks that only need to be run once at first startup.
        
        No one-time setup needed for Triton repository.
        """
        pass
    
    def initialize(self) -> None:
        """Initialize the shared Triton repository.
        
        Creates and connects the shared repository if Triton is enabled.
        Handles graceful degradation if Triton is unavailable.
        """
        try:
            config = TritonClientConfig.from_env()
            
            if not config.is_enabled():
                logger.info("Triton is disabled, skipping repository initialization")
                return
            
            logger.info("Initializing Triton repository...")
            
            # Get the shared repository manager instance
            manager = RepositoryManager.get_instance(config)
            
            # Pre-connect the repository to ensure it's ready
            # This will create the repository and establish connections
            try:
                # Use synchronous method for initialization
                manager.get_repository_sync()
                logger.info(f"Triton repository initialized successfully at {config.triton_grpc_url}")
                
                # Log repository stats
                stats = manager.get_stats()
                logger.info(f"Repository stats: {stats}")
                
            except Exception as e:
                logger.warning(f"Failed to connect to Triton server: {e}")
                logger.info("Triton repository will be initialized on first use")
                
        except Exception as e:
            logger.error(f"Failed to initialize Triton repository: {e}")
            # Don't raise the exception - allow server to start without Triton
            logger.info("Server will continue without Triton support")
    
    def cleanup(self) -> None:
        """Cleanup repository connections.
        
        This method can be called during server shutdown to properly
        disconnect from Triton servers.
        """
        try:
            from .repository_manager import cleanup_repositories
            cleanup_repositories()
            logger.info("Triton repository cleanup completed")
        except Exception as e:
            logger.warning(f"Error during Triton repository cleanup: {e}")
