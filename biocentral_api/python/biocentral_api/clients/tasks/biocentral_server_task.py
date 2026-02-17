import time

from tqdm.auto import tqdm
from typing import Generic, TypeVar, Optional, Callable, Any, List

from .dto_handler import DTOHandler

from ..._generated import BiocentralServiceApi, ApiClient, TaskStatusResponse, TaskDTO

T = TypeVar('T')


class BiocentralServerTask(Generic[T]):
    TIMEOUT: int = 2  # seconds
    MAX_TRIES: int = 10000
    MAX_CONSECUTIVE_FAILURES: int = 10

    def __init__(
            self,
            task_id: str,
            api_client: ApiClient,
            dto_handler: DTOHandler,
    ):
        self.task_id = task_id
        self.api_client = api_client
        self.dto_handler = dto_handler

    def _fetch_task_status(self, api_instance: BiocentralServiceApi) -> TaskStatusResponse:
        """Fetch task status from the API."""
        return api_instance.task_status_api_v1_biocentral_service_task_status_task_id_get(
            self.task_id
        )

    def _poll_task_status(
            self,
            progress_callback: Optional[Callable[[Any, Optional[tqdm]], None]] = None
    ) -> Optional[T]:
        """
        Poll task status until completion or timeout.
        
        Args:
            progress_callback: Optional callback for progress updates with signature (response, pbar)
        
        Returns:
            Result from dto_handler if task completes, None on timeout
        """
        api_instance = BiocentralServiceApi(self.api_client)
        # Create a stable tqdm progress bar (works in terminals and notebooks)
        # Let handlers adjust total when they know it; keep updates rate-limited to avoid spam
        pbar = (
            tqdm(
                total=None,  # unknown at start; handlers may set
                dynamic_ncols=True,
                leave=False,
                mininterval=0.3,
                smoothing=0.3,
                desc=self.dto_handler.get_tqdm_initial_description()
            )
            if progress_callback
            else None
        )
        error_message = None

        try:
            consecutive_failures = 0
            for _ in range(self.MAX_TRIES):
                try:
                    task_status_response = self._fetch_task_status(api_instance)
                    dtos = task_status_response.dtos if task_status_response.dtos is not None else []

                    # 1. Check progress
                    if progress_callback is not None:
                        progress_callback(dtos, pbar)

                    # 2. Check failure (after progress for tqdm updates)
                    error = self.dto_handler.handle_failure(dtos)

                    if error is not None:
                        error_message = error
                        break

                    # 3. Check for result (success)
                    result = self.dto_handler.handle_result(dtos)
                    if result is not None:
                        return result

                except Exception as e:
                    print(f"Error fetching task status for task {self.task_id}: {e}")
                    consecutive_failures += 1
                    if consecutive_failures >= self.MAX_CONSECUTIVE_FAILURES:
                        error_message = (f"Task failed due to exceeding max consecutive "
                                         f"failures ({self.MAX_CONSECUTIVE_FAILURES})!")
                        break

                time.sleep(self.TIMEOUT)
        finally:
            if pbar is not None:
                pbar.close()

        if error_message is None:
            error_message = f"\nTask {self.task_id} failed due to exceeding max tries!"

        raise Exception(error_message)

    def run(self) -> Optional[T]:
        """Execute task polling without progress bar."""
        return self._poll_task_status()

    def run_with_progress(self) -> Optional[T]:
        """Execute task polling with progress bar updates."""

        def update_progress(dtos: List[TaskDTO], pbar: Optional[tqdm]) -> None:
            if pbar is not None and len(dtos) > 0:
                pbar = self.dto_handler.update_tqdm(dtos, pbar)

        return self._poll_task_status(progress_callback=update_progress)
