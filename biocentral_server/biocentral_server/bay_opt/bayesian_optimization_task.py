from biotrainer.utilities import get_device
from typing import Dict, Callable, Tuple, List, Optional
from biotrainer.input_files import BiotrainerSequenceRecord

from .botraining import SUPPORTED_MODELS, pipeline

from ..utils import get_logger
from ..embeddings import LoadEmbeddingsTask
from ..server_management import TaskInterface, TaskDTO, TaskStatus

logger = get_logger(__name__)


class BayesTask(TaskInterface):
    SUPPORTED_MODELS = SUPPORTED_MODELS

    def __init__(self, config_dict: Dict):
        super().__init__()
        self.config_dict = config_dict

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        error_dto, embeddings = self._pre_embed_with_db()
        if error_dto:
            return error_dto

        results = pipeline(config_dict=self.config_dict, embeddings=embeddings)

        logger.info(f"bo_results: {results}")

        return TaskDTO(status=TaskStatus.FINISHED, bay_opt_results=results)

    def _pre_embed_with_db(
        self,
    ) -> Tuple[Optional[TaskDTO], List[BiotrainerSequenceRecord]]:
        # TODO [Refactoring] Duplicated code in biotrainer(_inference_)task
        input_file_path = self.config_dict["input_file"]
        embedder_name = self.config_dict["embedder_name"]

        load_embeddings_task = LoadEmbeddingsTask(
            embedder_name=embedder_name,
            sequence_input=input_file_path,
            reduced=True,
            use_half_precision=False,
            device=get_device(),
            custom_tokenizer_config=None,
        )
        load_dto = None
        for dto in self.run_subtask(load_embeddings_task):
            load_dto = dto

        if not load_dto:
            return TaskDTO(
                status=TaskStatus.FAILED, error="Could not compute embeddings!"
            ), []

        embeddings: List[BiotrainerSequenceRecord] = load_dto.embeddings
        if len(embeddings) == 0:
            return TaskDTO(
                status=TaskStatus.FAILED,
                error="Did not receive embeddings for training!",
            ), []

        return None, embeddings
