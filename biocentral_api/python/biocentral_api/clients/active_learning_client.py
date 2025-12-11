from tqdm import tqdm
from typing import Dict, Any, List

from .tasks import BiocentralServerTask, DTOHandler

from .._generated import ApiClient, ActiveLearningCampaignConfig, ActiveLearningIterationConfig, ActiveLearningApi, \
    TaskDTO, TaskStatus, ActiveLearningIterationRequest, ActiveLearningSimulationConfig, ActiveLearningSimulationRequest


class _ActiveLearningIterationDTOHandler(DTOHandler):

    def handle(self, dtos: List[TaskDTO]):
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
    _iteration_results = []

    def __init__(self, simulation_config: ActiveLearningSimulationConfig):
        self._n_max_iterations = simulation_config.n_max_iterations
        self._set_max_iterations_tqdm = False

    def handle(self, dtos: List[TaskDTO]):
        for dto in dtos:
            if dto.al_iteration_result is not None:
                self._iteration_results.append(dto.al_iteration_result)
            status = dto.status
            if status == TaskStatus.FINISHED:
                # TODO Error handling
                return self._iteration_results
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


class ActiveLearningClient:
    def al_iteration(self, api_client: ApiClient,
                     campaign_config: ActiveLearningCampaignConfig,
                     iteration_config: ActiveLearningIterationConfig) -> BiocentralServerTask:
        al_api = ActiveLearningApi(api_client)

        al_iteration_dto_handler = _ActiveLearningIterationDTOHandler()

        al_iteration_request = ActiveLearningIterationRequest(campaign_config=campaign_config,
                                                              iteration_config=iteration_config)
        task_id = al_api.active_learning_iteration_api_v1_active_learning_service_iteration_post(
            al_iteration_request).task_id
        return BiocentralServerTask(task_id=task_id, api_client=api_client, dto_handler=al_iteration_dto_handler)

    def al_simulation(self, api_client: ApiClient,
                      campaign_config: ActiveLearningCampaignConfig,
                      simulation_config: ActiveLearningSimulationConfig) -> BiocentralServerTask:
        al_api = ActiveLearningApi(api_client)

        al_simulation_dto_handler = _ActiveLearningSimulationDTOHandler(simulation_config=simulation_config)

        al_simulation_request = ActiveLearningSimulationRequest(campaign_config=campaign_config,
                                                                simulation_config=simulation_config)
        task_id = al_api.active_learning_simulation_api_v1_active_learning_service_simulation_post(
            al_simulation_request).task_id
        return BiocentralServerTask(task_id=task_id, api_client=api_client, dto_handler=al_simulation_dto_handler)
