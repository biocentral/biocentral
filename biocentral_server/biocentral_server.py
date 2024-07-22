import os
import logging
import argparse

from biocentral_server.utils import Constants
from biocentral_server.server_frontend import run_frontend
from biocentral_server.server_entrypoint import run_server


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

    # Get the root logger and add handlers
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.addHandler(file_handler)
    logger.addHandler(stream_handler)

    # Capture warnings with the logging system
    logging.captureWarnings(True)


def main():
    parser = argparse.ArgumentParser(
        description='Biocentral server with control panel server_frontend')

    parser.add_argument("--headless", default=False,
                        action="store_true", help="Activate headless mode without gui")

    args = parser.parse_args()

    headless: bool = args.headless

    _setup_directories()
    _setup_logging()

    if headless:
        run_server()
    else:
        run_frontend()


if __name__ == '__main__':
    main()
