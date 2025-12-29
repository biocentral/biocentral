from abc import ABC
from tqdm import tqdm
from time import sleep
from typing import Callable

from .._generated import StartTaskResponse, ApiException


class ClientInterface(ABC):
    @staticmethod
    def _submit_task(endpoint_caller: Callable) -> str:
        max_retries = 2
        for retry in range(max_retries):
            try:
                start_task_response: StartTaskResponse = endpoint_caller()
                if start_task_response.task_id is None:
                    raise Exception("No task id returned from server!")
                return start_task_response.task_id
            except ApiException as e:
                retry_after = e.headers.get("retry-after", None)
                if retry_after is None:
                    raise e
                wait_seconds = int(retry_after) + 1

                # Progress bar
                print(f"Rate limit exceeded (attempt {retry + 1}/{max_retries})")
                for _ in tqdm(range(wait_seconds),
                              desc="Waiting",
                              bar_format='{desc}: {bar} {remaining}s',
                              ncols=60):
                    sleep(1)

            except Exception as e:
                raise e
        raise Exception(f"Max retries ({max_retries}) exceeded - Failed to start task!")
