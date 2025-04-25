import logging
from typing import List

from .server_module_initialization import ServerModuleInitializer

logger = logging.getLogger(__name__)


class ServerInitializationManager:
    def __init__(self):
        self.initializers: List[ServerModuleInitializer] = []

    def register_initializer(self, initializer: ServerModuleInitializer) -> None:
        self.initializers.append(initializer)

    def run_all(self) -> None:
        for initializer in self.initializers:
            try:
                initializer.run()
            except Exception as e:
                logger.error(f"Initialization failed for {initializer.__class__.__name__}: {str(e)}")
                raise