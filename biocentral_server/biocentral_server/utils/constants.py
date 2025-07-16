import datetime
from pathlib import Path
from typing import Final


class Constants:
    LOGGER_FILE_PATH: Final[str] = str(
        Path(
            f"logs/server_logs-{datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.log"
        ).absolute()
    )
    LOGGER_FORMAT: Final[str] = "%(asctime)s %(levelname)s %(message)s"

    SERVER_CONFIG_FILE = "server_config.txt"
    SERVER_DEFAULT_PORT = 9540
