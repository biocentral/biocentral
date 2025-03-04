import logging

from pathlib import Path

from .plm_eval_endpoint import plm_eval_service_route
from .flip_data_handler import FLIPDataHandler

from ..server_management import FileContextManager, FileManager

logger = logging.getLogger(__name__)


def plm_eval_setup(app):
    flip_server_path = "FLIP"
    file_context_manager = FileContextManager()
    file_manager = FileManager(user_id=flip_server_path)

    with file_context_manager.storage_write(flip_server_path) as flip_path:
        if file_manager.check_base_dir_exists():
            logger.info("FLIP data already present on the file storage system!")
        else:
            logger.info("FLIP data not found. Downloading and preprocessing...")
            FLIPDataHandler.download_and_preprocess(flip_path)

    flip_dict = FLIPDataHandler.get_dataset_paths(flip_path=Path(flip_server_path),
                                                  check_path_exists_function=lambda
                                                      path: file_context_manager.storage_backend.check_file_exists(
                                                      file_path=path))

    app.config['FLIP_DICT'] = flip_dict


__all__ = [
    'plm_eval_service_route',
    'plm_eval_setup',
]
