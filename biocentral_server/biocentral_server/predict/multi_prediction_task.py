from typing import Callable, Any, Optional
from biotrainer.utilities import get_device

from .models import BaseModel
from .single_prediction_task import SinglePredictionTask
from .model_factory import PredictionModelFactory

from ..utils import get_logger
from ..server_management import TaskInterface, TaskDTO, TaskStatus

logger = get_logger(__name__)


class MultiPredictionTask(TaskInterface):
    def __init__(
        self,
        models: dict[str, Any],
        sequence_input,
        batch_size,
        use_triton: Optional[bool] = None,
    ):
        self.models = models
        self.sequence_input = sequence_input
        self.device = get_device()
        self.batch_size = batch_size
        self.use_triton = use_triton

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        predictions = {}

        for model_name, model_class in self.models.items():
            # Create model via factory (supports both Triton and ONNX backends)
            logger.info(f"Creating model {model_name} via factory")
            model: BaseModel = PredictionModelFactory.create_model(
                model_name=model_name,
                batch_size=self.batch_size,
                use_triton=self.use_triton,
            )

            single_pred_task = SinglePredictionTask(
                model=model, sequence_input=self.sequence_input, device=self.device
            )
            predict_dto = None
            for dto in self.run_subtask(single_pred_task):
                predict_dto = dto
            if not predict_dto:
                return TaskDTO(
                    status=TaskStatus.FAILED,
                    error=f"Model prediction with the {model_name} model failed.",
                )

            single_prediction = predict_dto.predictions
            logger.info(f"{model_name} model prediction: {single_prediction}")
            predictions[model_name] = single_prediction

        return TaskDTO(status=TaskStatus.FINISHED, predictions=predictions)
