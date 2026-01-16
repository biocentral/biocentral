from tqdm import tqdm
from typing import List

from .tasks import BiocentralServerTask, DTOHandler
from .client_interface import ClientInterface

from .._generated import ApiClient, ActiveLearningCampaignConfig, ActiveLearningIterationConfig, ActiveLearningApi, \
    TaskDTO, TaskStatus, ActiveLearningIterationRequest, ActiveLearningSimulationConfig, \
    ActiveLearningSimulationRequest, ActiveLearningSimulationResult, ActiveLearningIterationResult


class _ActiveLearningIterationDTOHandler(DTOHandler):

    def handle_result(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                # TODO Error handling
                return dto.al_iteration_result
        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.RUNNING:
                pbar.set_description(f"Running active learning iteration..")
            if status == TaskStatus.FINISHED:
                pbar.set_description(f"Finished active learning iteration!")
                pbar.close()
                break
            if status == TaskStatus.FAILED:
                pbar.set_description(f"Active learning iteration failed!")
                pbar.close()
                break
        return pbar


class _ActiveLearningSimulationDTOHandler(DTOHandler):
    _iteration_results = {}  # Use dict to preserve order of results

    def __init__(self, simulation_config: ActiveLearningSimulationConfig):
        self._n_max_iterations = self._approximate_n_max_iterations(simulation_config)
        self._set_max_iterations_tqdm = False

    @staticmethod
    def _approximate_n_max_iterations(simulation_config: ActiveLearningSimulationConfig):
        max_labels_budget = simulation_config.convergence_config.max_labels_budget
        if max_labels_budget is not None:
            return  max_labels_budget // simulation_config.n_suggestions_per_iteration
        n_start_data = simulation_config.n_start if simulation_config.n_start else len(simulation_config.start_ids)
        return (len(simulation_config.simulation_data) - n_start_data) // simulation_config.n_suggestions_per_iteration

    def handle_result(self, dtos: List[TaskDTO]):
        for dto in dtos:
            if dto.al_iteration_result is not None:
                iteration_idx = dto.al_iteration_result.iteration
                self._iteration_results[iteration_idx] = dto.al_iteration_result
            status = dto.status
            if status == TaskStatus.FINISHED:
                # TODO Error handling
                al_simulation_result = dto.al_simulation_result
                al_simulation_result.iteration_results = sorted(self._iteration_results.values(),
                                                                key=lambda x: x.iteration)
                return al_simulation_result
        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        if not self._set_max_iterations_tqdm:
            tqdm.total = self._n_max_iterations
            self._set_max_iterations_tqdm = True

        for dto in dtos:
            status = dto.status
            if status == TaskStatus.RUNNING:
                pbar.set_description(f"Running active learning simulation (max: {self._n_max_iterations})..")
                if dto.al_iteration_result is not None:
                    pbar.update(1)
            if status == TaskStatus.FINISHED:
                pbar.set_description(f"Finished active learning simulation!")
                pbar.close()
                break
            if status == TaskStatus.FAILED:
                pbar.set_description(f"Active learning simulation failed!")
                pbar.close()
                break
        return pbar


class ActiveLearningClient(ClientInterface):
    def al_iteration(self, api_client: ApiClient,
                           campaign_config: ActiveLearningCampaignConfig,
                           iteration_config: ActiveLearningIterationConfig) -> BiocentralServerTask[
        ActiveLearningIterationResult]:
        al_api = ActiveLearningApi(api_client)

        al_iteration_dto_handler = _ActiveLearningIterationDTOHandler()

        al_iteration_request = ActiveLearningIterationRequest(campaign_config=campaign_config,
                                                              iteration_config=iteration_config)
        task_id = self._submit_task(
            endpoint_caller=lambda: al_api.active_learning_iteration_api_v1_active_learning_service_iteration_post(
                al_iteration_request)
        )
        return BiocentralServerTask(task_id=task_id, api_client=api_client, dto_handler=al_iteration_dto_handler)

    def al_simulation(self, api_client: ApiClient,
                            campaign_config: ActiveLearningCampaignConfig,
                            simulation_config: ActiveLearningSimulationConfig) -> BiocentralServerTask[
        ActiveLearningSimulationResult]:
        al_api = ActiveLearningApi(api_client)

        al_simulation_dto_handler = _ActiveLearningSimulationDTOHandler(simulation_config=simulation_config)

        al_simulation_request = ActiveLearningSimulationRequest(campaign_config=campaign_config,
                                                                simulation_config=simulation_config)
        task_id = self._submit_task(
            endpoint_caller=lambda: al_api.active_learning_simulation_api_v1_active_learning_service_simulation_post(
                al_simulation_request)
        )
        return BiocentralServerTask(task_id=task_id, api_client=api_client, dto_handler=al_simulation_dto_handler)
