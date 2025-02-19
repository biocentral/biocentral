# Gunicorn configuration file
import logging

from biocentral_server.server_entrypoint import AppState

# Number of worker processes
workers = 3
worker_class = "gthread"
threads = 2

def on_starting(server):
    """
    Hook that runs before master process is initialized.
    """
    logging.info("Initializing server...")
    app_state = AppState.get_instance()
    app_state.init_app_context()

# Bind address
bind = "0.0.0.0:9540"

# Timeout
timeout = 30

# Access log - records incoming HTTP requests
accesslog = "/var/log/gunicorn.access.log"

# Error log - records Gunicorn server goings-on
errorlog = "/var/log/gunicorn.error.log"

# Whether to send Flask output to the error log
capture_output = True

# How verbose the Gunicorn error logs should be
loglevel = "info"
