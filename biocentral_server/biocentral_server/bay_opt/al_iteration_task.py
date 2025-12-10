from biotrainer.utilities import get_device
from typing import Callable, Tuple, List, Optional
from biotrainer.input_files import BiotrainerSequenceRecord

from .al_iteration_pipeline import al_pipeline
from .al_config import ActiveLearningCampaignConfig, ActiveLearningIterationConfig

from ..utils import get_logger
from ..embeddings import LoadEmbeddingsTask
from ..server_management import TaskInterface, TaskDTO, TaskStatus

logger = get_logger(__name__)


class ActiveLearningIterationTask(TaskInterface):
    def __init__(
        self,
        al_campaign_config: ActiveLearningCampaignConfig,
        al_iteration_config: ActiveLearningIterationConfig,
    ):
        super().__init__()
        self.al_campaign_config = al_campaign_config
        self.al_iteration_config = al_iteration_config

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        error_dto, embeddings = self._pre_embed_with_db()
        if error_dto:
            return error_dto
        assert embeddings is not None, (
            "embeddings is None after pre-embedding before active learning iteration!"
        )

        results, suggestions = al_pipeline(
            al_campaign_config=self.al_campaign_config,
            al_iteration_config=self.al_iteration_config,
            embeddings=embeddings,
        )

        logger.info(f"AL - Suggestions: {suggestions}")

        return TaskDTO(status=TaskStatus.FINISHED, bay_opt_results=results)

    def _pre_embed_with_db(
        self,
    ) -> Tuple[Optional[TaskDTO], List[BiotrainerSequenceRecord]]:
        # TODO [Refactoring] Duplicated code in biotrainer(_inference_)task
        iteration_data = [
            data_point.to_biotrainer_seq_record()
            for data_point in self.al_iteration_config.iteration_data
        ]
        embedder_name = self.al_campaign_config.embedder_name

        load_embeddings_task = LoadEmbeddingsTask(
            embedder_name=embedder_name,
            sequence_input=iteration_data,
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
