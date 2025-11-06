from tqdm import tqdm
from typing import Dict, Any, List

from .tasks import BiocentralServerTask, DTOHandler

from .._generated import ApiClient, StartTrainingRequest, ConfigVerificationRequest, CustomModelsApi, \
    SequenceTrainingData, TaskDTO, TaskStatus, StartInferenceRequest


class _TrainingDTOHandler(DTOHandler):

    def handle(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                # TODO Error handling
                return dto.biotrainer_result
        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.RUNNING and dto.biotrainer_update is not None:
                training_iteration = dto.biotrainer_update.training_iteration
                if training_iteration is not None:
                    epoch = training_iteration[1]['epoch']
                    pbar.set_description(f"Training epoch {epoch}")
                    pbar.update(1)  # TODO Improve handling of progress bar updates
            if status == TaskStatus.FINISHED:
                pbar.set_description(f"Finished training")
                pbar.close()
                break
            if status == TaskStatus.FAILED:
                pbar.set_description(f"Training failed")
                pbar.close()
                break
        return pbar


class _InferenceDTOHandler(DTOHandler):

    def handle(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                # TODO Error handling
                return dto.predictions
        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            match status:
                case TaskStatus.PENDING:
                    pbar.set_description(f"Waiting for inference to start..")
                case TaskStatus.RUNNING:
                    pbar.set_description(f"Running inference..")
                case TaskStatus.FINISHED:
                    pbar.set_description(f"Finished inference!")
                    pbar.close()
                    break
                case TaskStatus.FAILED:
                    pbar.set_description(f"Inference failed!")
                    pbar.close()
                    break
        return pbar


class CustomModelsClient:
    def train(self, api_client: ApiClient, config: Dict[str, Any],
              training_data: List[SequenceTrainingData]) -> BiocentralServerTask:
        custom_models_api = CustomModelsApi(api_client)
        config_verification_request = ConfigVerificationRequest(config_dict=config)

        try:
            config_verification_response = custom_models_api.verify_config_api_v1_custom_models_service_verify_config_post(
                config_verification_request
            )
            config_error = config_verification_response.error
            if config_error:
                raise Exception(f"Config verification failed: {config_error}")
        except Exception as e:
            raise e

        training_dto_handler = _TrainingDTOHandler()

        start_training_request = StartTrainingRequest(config_dict=config, training_data=training_data)
        task_id = custom_models_api.start_training_api_v1_custom_models_service_start_training_post(
            start_training_request).task_id
        return BiocentralServerTask(task_id=task_id, api_client=api_client, dto_handler=training_dto_handler)

    def inference(self, api_client: ApiClient, model_hash: str, inference_data: Dict[str, str]):
        custom_models_api = CustomModelsApi(api_client)
        start_inference_request = StartInferenceRequest(model_hash=model_hash, sequence_data=inference_data)
        task_id = custom_models_api.start_inference_api_v1_custom_models_service_start_inference_post(
            start_inference_request).task_id
        return BiocentralServerTask(task_id=task_id, api_client=api_client, dto_handler=_InferenceDTOHandler())