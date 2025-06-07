from typing import Callable, Any
from biotrainer.utilities import get_device

from .models import BaseModel
from .single_prediction_task import SinglePredictionTask

from ..utils import get_logger
from ..server_management import TaskInterface, TaskDTO

logger = get_logger(__name__)


class MultiPredictionTask(TaskInterface):
    def __init__(self, models: dict[str, Any], sequence_input, batch_size):
        self.models = models
        self.sequence_input = sequence_input
        self.device = get_device()
        self.batch_size = batch_size

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        predictions = {}
        for model_name, model_class in self.models.items():
            model: BaseModel = model_class(batch_size=self.batch_size)
            single_pred_task = SinglePredictionTask(model=model,
                                                    sequence_input=self.sequence_input,
                                                    device=self.device)
            predict_dto = None
            for dto in self.run_subtask(single_pred_task):
                predict_dto = dto
            if not predict_dto:
                return TaskDTO.failed(error=f"Model prediction with the {model_name} model failed.")
            single_prediction = predict_dto.update["predictions"]
            logger.info(f"{model_name} model prediction: {single_prediction}")
            predictions[model_name] = single_prediction

        return TaskDTO.finished(result={"predictions": predictions})
