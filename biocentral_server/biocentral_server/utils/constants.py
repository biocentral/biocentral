import datetime

from pathlib import Path
from typing import Final


class Constants:
    LOGGER_FILE_PATH: Final[str] = str(
        Path(__file__).parent.parent.parent
        / "logs"
        / f"server_logs-{datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.log"
    )
    LOGGER_FORMAT: Final[str] = "%(asctime)s %(levelname)s %(message)s"

    SERVER_DEFAULT_PORT = 9540
