import logging

from pathlib import Path

from flask import Flask, request

from ..utils import Constants
from ..ppi import ppi_service_route
from ..server_management import UserManager, init_embeddings_database_instance
from ..proteins import protein_service_route
from ..plm_eval import plm_eval_service_route, plm_eval_setup
from ..protein_analysis import protein_analysis_route
from ..embeddings import embeddings_service_route
from ..biocentral import biocentral_service_route
from ..prediction_models import prediction_models_service_route

from .server_thread import ServerThread

logger = logging.getLogger(__name__)


def create_server_app(mongodb_user="embeddingsUser", mongodb_pwd="embeddingsPassword"):
    app = Flask("Biocentral Server")
    app.register_blueprint(biocentral_service_route)
    app.register_blueprint(ppi_service_route)
    app.register_blueprint(protein_service_route)
    app.register_blueprint(prediction_models_service_route)
    app.register_blueprint(embeddings_service_route)
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

    # Setup embeddings database
    app.config['USE_MONGODB'] = False

    if app.config['USE_MONGODB']:
        app.config["MONGO_URI"] = f"mongodb://{mongodb_user}:{mongodb_pwd}@localhost:27017/embeddings_db"
    else:
        app.config['TINYDB_PATH'] = str(Path("storage/embeddings.json"))

    app.config["EMBEDDINGS_DATABASE"] = init_embeddings_database_instance(app)
    logger.info(f"Using database: {'MongoDB' if app.config['USE_MONGODB'] else 'TinyDB'}")

    # Setup services if required
    plm_eval_setup(app)

    return app


def run_server():
    app = create_server_app()
    app.run(host="127.0.0.1", port=Constants.SERVER_DEFAULT_PORT, threaded=True)


__all__ = [
    'run_server',
    'create_server_app',
    'ServerThread'
]
