import time
import threading

from typing import Generator


def run_subtask_util(subtask) -> Generator:
    updates = []
    task_result = []

    def callback(dto):
        updates.append(dto)

    def _run_task():
        result = subtask.run_task(callback)
        task_result.append(result)

    # Run in thread to avoid blocking
    thread = threading.Thread(target=lambda: _run_task(), daemon=True)
    thread.start()

    # TODO Add TTL for thread
    last_update_count = 0
    while thread.is_alive():
        if len(updates) > last_update_count:
            for i in range(last_update_count, len(updates)):
                yield updates[i]
            last_update_count = len(updates)
        time.sleep(1)

    # Get final result if not already yielded
    if len(updates) > last_update_count:
        for i in range(last_update_count, len(updates)):
            yield updates[i]

    # Make sure thread is done
    thread.join(timeout=0.5)

    if len(task_result) == 1 and task_result[0] is not None:
        yield task_result[0]
