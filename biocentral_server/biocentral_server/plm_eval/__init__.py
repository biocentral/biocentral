from flask import current_app

from .plm_eval_endpoint import plm_eval_service_route
from .setup_flip import ensure_flip_is_downloaded, populate_flip_dataset_splits_with_files


def plm_eval_setup(app):
    ensure_flip_is_downloaded()
    flip_dict = populate_flip_dataset_splits_with_files()
    app.config['FLIP_DICT'] = flip_dict


__all__ = [
    'plm_eval_service_route',
    'plm_eval_setup',
]
