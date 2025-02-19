import os
import sys
import logging

from pathlib import Path
from typing import Optional
from flask import Flask, request

from ..utils import Constants
from ..ppi import ppi_service_route
from ..server_management import UserManager
from ..proteins import protein_service_route
from ..plm_eval import plm_eval_service_route, plm_eval_setup
from ..protein_analysis import protein_analysis_route
from ..embeddings import embeddings_service_route, projection_route
from ..biocentral import biocentral_service_route
from ..prediction_models import prediction_models_service_route

logger = logging.getLogger(__name__)

# Global variable to store the initialized app
flask_app: Optional[Flask] = None

def _setup_directories():
    required_directories = ["logs", "storage"]
    for directory in required_directories:
        if not os.path.exists(directory):
            os.makedirs(directory)


def _setup_logging():
    formatter = logging.Formatter(Constants.LOGGER_FORMAT)

    # Create file handler for writing logs to file
    file_handler = logging.FileHandler(Constants.LOGGER_FILE_PATH, encoding='utf8')
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)

    # Create stream handler for console output
    stream_handler = logging.StreamHandler()
    stream_handler.setLevel(logging.INFO)
    stream_handler.setFormatter(formatter)
    stream_handler.setStream(sys.stdout)

    # Get the root logger and add handlers
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.addHandler(file_handler)
    logger.addHandler(stream_handler)

    # Capture warnings with the logging system
    logging.captureWarnings(True)


class AppState:
    """Singleton to manage Flask application state"""
    _instance = None
    app = None
    initialized = False

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def init_app(self):
        """Initialize the Flask application with basic setup"""
        if self.app is not None:
            return self.app

        _setup_logging()
        _setup_directories()

        app = Flask("Biocentral Server")
        app.register_blueprint(biocentral_service_route)
        app.register_blueprint(ppi_service_route)
        app.register_blueprint(protein_service_route)
        app.register_blueprint(prediction_models_service_route)
        app.register_blueprint(embeddings_service_route)
        app.register_blueprint(projection_route)
        app.register_blueprint(protein_analysis_route)
        app.register_blueprint(plm_eval_service_route)

        @app.after_request
        def apply_caching(response):
            # Necessary for flutter in the web
            response.headers["Access-Control-Allow-Origin"] = "*"
            response.headers[
                "Access-Control-Allow-Headers"] = ("Content-Type, "
                                                   "Access-Control-Allow-Headers, Authorization, X-Requested-With")
            return response

        @app.before_request
        def check_user():
            UserManager.check_request(req=request)

        self.app = app

        return app

    def init_app_context(self):
        """Initialize application context and resources"""
        if self.initialized:
            return

        if self.app is None:
            self.init_app()

        # PLM eval setup
        plm_eval_setup(self.app)
        self.initialized = True

        logger.info("Application context initialized")
