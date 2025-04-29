import logging

from pathlib import Path

from .flip_data_handler import FLIPDataHandler

from ..server_management import FileManager, FileContextManager, ServerModuleInitializer

logger = logging.getLogger(__name__)


class FlipInitializer(ServerModuleInitializer):
    def __init__(self, app):
        self.app = app
        self.flip_server_path = "FLIP"
        self.file_context_manager = FileContextManager()
        self.file_manager = FileManager(user_id=self.flip_server_path)

    def check_one_time_setup_is_done(self) -> bool:
        return self.file_manager.check_base_dir_exists()

    def one_time_setup(self) -> None:
        with self.file_context_manager.storage_write(self.flip_server_path) as flip_path:
            logger.info("FLIP data not found. Downloading...")
            self._download_data(urls=FLIPDataHandler.DOWNLOAD_URLS, data_dir=flip_path)
            logger.info("FLIP data downloaded. Preprocessing...")
            FLIPDataHandler.preprocess(flip_path)

    def _check_file_exists(self, path) -> bool:
        return self.file_context_manager.storage_backend.check_file_exists(file_path=path)

    def initialize(self) -> None:
        flip_dict = FLIPDataHandler.get_dataset_paths(flip_path=Path(self.flip_server_path),
                                                      check_path_exists_function=self._check_file_exists)

        self.app.config['FLIP_DICT'] = flip_dict
