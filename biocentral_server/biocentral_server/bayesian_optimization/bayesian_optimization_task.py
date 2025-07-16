from biotrainer.utilities import get_device
from typing import Dict, Callable, Tuple, List
from biotrainer.input_files import BiotrainerSequenceRecord

from .botraining import SUPPORTED_MODELS, pipeline

from ..utils import get_logger
from ..embeddings import LoadEmbeddingsTask
from ..server_management import TaskInterface, TaskDTO

logger = get_logger(__name__)


class BayesTask(TaskInterface):
    SUPPORTED_MODELS = SUPPORTED_MODELS

    def __init__(self, config_dict: Dict):
        super().__init__()
        self.config_dict = config_dict

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        embeddings, error = self._pre_embed_with_db()
        if error and len(error) > 0:
            return TaskDTO.failed(error=error)
        if len(embeddings) == 0:
            return TaskDTO.failed(
                error="Failed to calculate embeddings for BO training!"
            )

        results = pipeline(config_dict=self.config_dict, embeddings=embeddings)

        logger.info(f"bo_results: {results}")

        return TaskDTO.finished(result={"bo_results": results})

    def _pre_embed_with_db(self) -> Tuple[List[BiotrainerSequenceRecord], str]:
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
            return [], "Loading of embeddings failed before training!"

        missing = load_dto.update["missing"]
        embeddings: List[BiotrainerSequenceRecord] = load_dto.update["embeddings"]
        if len(missing) > 0:
            return [], f"Missing number of embeddings before training: {len(missing)}"

        return embeddings, ""
