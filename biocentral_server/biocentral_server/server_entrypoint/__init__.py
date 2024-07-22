from flask import Flask, request

from ..utils import Constants
from ..ppi import ppi_service_route
from ..server_management import UserManager
from ..proteins import protein_service_route
from ..data_analysis import data_analysis_route
from ..embeddings import embeddings_service_route
from ..biocentral import biocentral_service_route
from ..prediction_models import prediction_models_service_route

from .server_thread import ServerThread


def create_server_app():
    app = Flask("Biocentral Server")
    app.register_blueprint(biocentral_service_route)
    app.register_blueprint(ppi_service_route)
    app.register_blueprint(protein_service_route)
    app.register_blueprint(prediction_models_service_route)
    app.register_blueprint(embeddings_service_route)
    app.register_blueprint(data_analysis_route)

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

    return app


def run_server():
    app = create_server_app()
    app.run(host="127.0.0.1", port=Constants.SERVER_DEFAULT_PORT, threaded=True)


__all__ = [
    'run_server',
    'create_server_app',
    'ServerThread'
]
