import logging

from ..server_management import ServerModuleInitializer, FileContextManager, FileManager

from .model_utils import MODEL_BASE_PATH

logger = logging.getLogger(__name__)


class PredictInitializer(ServerModuleInitializer):

    DOWNLOAD_URLS = ["https://nextcloud.in.tum.de/index.php/s/kxJ64RcRi7g6p6r/download"]

    def __init__(self):
        self.predict_server_path = MODEL_BASE_PATH
        self.file_context_manager = FileContextManager()
        self.file_manager = FileManager(user_id=self.predict_server_path)

    def check_one_time_setup_is_done(self) -> bool:
        return self.file_manager.check_base_dir_exists()

    def one_time_setup(self) -> None:
        with self.file_context_manager.storage_write(self.predict_server_path) as predict_path:
            logger.info("PREDICTion models not found. Downloading...")
            self._download_data(urls=self.DOWNLOAD_URLS, data_dir=predict_path)
            logger.info("PREDICTion models downloaded!")

    def initialize(self) -> None:
        pass