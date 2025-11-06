import io
import h5py
import base64
import numpy as np

from tqdm import tqdm
from typing import Dict, List

from .tasks import BiocentralServerTask, DTOHandler

from ..utils import calculate_sequence_hash
from .._generated import ApiClient, PredictionRequest, PredictionApi, StartTaskResponse, TaskStatus, \
    TaskDTO


class _PredictDTOHandler(DTOHandler):
    def __init__(self, hash2id: Dict[str, str]):
        self.hash2id = hash2id

    def handle(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                return dto.predictions

        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            match status:
                case TaskStatus.PENDING:
                    pbar.set_description(f"Waiting for prediction task to start..")
                case TaskStatus.RUNNING:
                    pbar.set_description(f"Predicting..")
                case TaskStatus.FINISHED:
                    pbar.set_description(f"Finished predictions!")
                    pbar.close()
                    break
                case TaskStatus.FAILED:
                    pbar.set_description(f"Predictions failed!")
                    pbar.close()
                    break
        return pbar


class PredictClient:
    def predict(self, api_client: ApiClient, model_names: List[str],
                sequence_data: Dict[str, str]) -> BiocentralServerTask:
        assert len(sequence_data) > 0, "No sequences provided"
        assert len(sequence_data.values()) == len(set(sequence_data.values())), "Duplicate sequences provided"

        hash2id = {calculate_sequence_hash(seq): seq_id for seq_id, seq in sequence_data.items()}

        prediction_request = PredictionRequest(model_names=model_names, sequence_input=sequence_data)
        api_instance = PredictionApi(api_client)
        start_task_response: StartTaskResponse = api_instance.predict_api_v1_prediction_service_predict_post(
            prediction_request)
        if start_task_response.task_id is None:
            raise Exception("Failed to start prediction task")

        predict_dto_handler = _PredictDTOHandler(hash2id)
        biocentral_server_task = BiocentralServerTask(task_id=start_task_response.task_id,
                                                      api_client=api_client,
                                                      dto_handler=predict_dto_handler)
        return biocentral_server_task
