import time

from tqdm import tqdm
from typing import Generic, TypeVar, Optional, Callable, Any, List

from .dto_handler import DTOHandler

from ..._generated import BiocentralApi, ApiClient, TaskStatusResponse, TaskDTO

T = TypeVar('T')

class BiocentralServerTask(Generic[T]):
    TIMEOUT: int = 2  # seconds
    MAX_TRIES: int = 10000

    def __init__(
            self,
            task_id: str,
            api_client: ApiClient,
            dto_handler: DTOHandler,
    ):
        self.task_id = task_id
        self.api_client = api_client
        self.dto_handler = dto_handler

    def _fetch_task_status(self, api_instance: BiocentralApi) -> TaskStatusResponse:
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
        api_instance = BiocentralApi(self.api_client)
        pbar = tqdm() if progress_callback else None

        try:
            for _ in range(self.MAX_TRIES):
                try:
                    task_status_response = self._fetch_task_status(api_instance)
                    dtos = task_status_response.dtos if task_status_response.dtos is not None else []
                    if progress_callback is not None:
                        progress_callback(dtos, pbar)

                    result = self.dto_handler.handle(dtos)
                    if result is not None:
                        return result

                except Exception as e:
                    print(f"Error fetching task status for task {self.task_id}: {e}")

                time.sleep(self.TIMEOUT)
        finally:
            if pbar is not None:
                pbar.close()

        return None  # timeout

    def run(self) -> Optional[T]:
        """Execute task polling without progress bar."""
        return self._poll_task_status()

    def run_with_progress(self) -> Optional[T]:
        """Execute task polling with progress bar updates."""

        def update_progress(dtos: List[TaskDTO], pbar: Optional[tqdm]) -> None:
            if pbar is not None and len(dtos) > 0:
                updated_pbar = self.dto_handler.update_tqdm(dtos, pbar)
                updated_pbar.refresh()

        return self._poll_task_status(progress_callback=update_progress)
