import socket
import threading

from flask import Flask
from werkzeug.serving import make_server

from ..utils import Constants


class ServerThread(threading.Thread):
    def __init__(self, app: Flask):
        threading.Thread.__init__(self)
        self.logger = app.logger
        self.app = app
        self.server = self._create_server(app)

    def _create_server(self, app: Flask):
        port = Constants.SERVER_DEFAULT_PORT
        max_attempts = 10  # Maximum number of attempts to find an open port

        for attempt in range(max_attempts):
            try:
                server = make_server('127.0.0.1', port, app)
                self.logger.info(f"Server started on port {port}")
                self._log_config(port=port)
                return server
            except socket.error as e:
                if e.errno == 98:  # Address already in use
                    self.logger.warning(f"Port {port} is already in use. Trying next port.")
                    port += 1
                else:
                    raise  # Re-raise the exception if it's not a "port in use" error

        raise RuntimeError(f"Unable to find an open port after {max_attempts} attempts")

    @staticmethod
    def _log_config(port):
        with open(Constants.SERVER_CONFIG_FILE, "w") as config_file:
            config_file.write("ADDRESS=127.0.0.1\n")
            config_file.write(f"PORT={port}")

    def run(self):
        with self.app.app_context():
            try:
                self.server.serve_forever()
            except Exception as e:
                self.logger.error(f"Server encountered an error: {e}")
            finally:
                self.logger.info(f"Server stopped")

    def shutdown(self):
        self.logger.info('Shutting down server')
        self.server.shutdown()
