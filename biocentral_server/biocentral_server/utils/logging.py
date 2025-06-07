import sys
import logging

from .constants import Constants

logging_setup = False

def get_logger(name):
    global logging_setup
    if not logging_setup:
        _setup_logging()
        logging_setup = True
    return logging.getLogger(name)


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

    # Get the root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)

    # Add handlers
    root_logger.handlers.clear()
    root_logger.addHandler(file_handler)
    root_logger.addHandler(stream_handler)

    # Capture warnings with the logging system
    logging.captureWarnings(True)