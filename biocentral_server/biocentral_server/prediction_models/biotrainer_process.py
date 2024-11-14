import os.path
import asyncio

from pathlib import Path
from typing import Dict, Any
import torch.multiprocessing as torch_mp

from biotrainer.utilities.cli import headless_main

from ..server_management import TaskInterface, TaskStatus


class BiotrainerProcess(TaskInterface):
    process: torch_mp.Process = None

    def __init__(self, config_path: Path, log_path: Path):
        self.config_path = config_path
        self.log_path = log_path
        self._last_read_position_in_log_file = 0

    async def start(self):
        self.process = torch_mp.Process(target=headless_main, args=(str(self.config_path),))
        self.process.start()

    def get_task_status(self) -> TaskStatus:
        if self.process.is_alive():
            return TaskStatus.RUNNING
        else:
            return TaskStatus.FINISHED

    def update(self) -> Dict[str, Any]:
        result = {"log_file": "", "status": self.get_task_status().name}
        if os.path.exists(self.log_path):
            with open(self.log_path, "r") as log_file:
                log_file.seek(self._last_read_position_in_log_file)
                new_content = log_file.read()
                self._last_read_position_in_log_file = log_file.tell()
                result["log_file"] = new_content
        return result
