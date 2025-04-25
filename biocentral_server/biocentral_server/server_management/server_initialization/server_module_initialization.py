import logging

from abc import ABC, abstractmethod

logger = logging.getLogger(__name__)


class ServerModuleInitializer(ABC):
    @abstractmethod
    def check_one_time_setup_is_done(self) -> bool:
        """Check if the one_time_setup has already been performed"""
        pass

    @abstractmethod
    def one_time_setup(self) -> None:
        """Perform tasks (like downloading) that only need to be run once at first startup"""
        pass

    @abstractmethod
    def initialize(self) -> None:
        """Perform initialization after one_time_setup is done"""
        pass

    def run(self) -> None:
        """Run the initialization and one_time_setup if needed"""
        if not self.check_one_time_setup_is_done():
            logger.info(f"Running one_time_setup: {self.__class__.__name__}")
            self.one_time_setup()

        logger.info(f"Running initializer: {self.__class__.__name__}")
        self.initialize()
