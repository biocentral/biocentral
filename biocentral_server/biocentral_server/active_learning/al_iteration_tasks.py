from typing import Callable, List, Optional, Set
from biotrainer_core.functions.seeding import seed_all
from biotrainer_core.data_classes import SequenceData, BiotrainerModelResult

from .pipelines import al_screening_pipeline, al_engineering_pipeline
from .al_config import (
    ActiveLearningScreeningCampaignConfig,
    ActiveLearningScreeningIterationConfig,
    ActiveLearningEngineeringCampaignConfig,
    ActiveLearningEngineeringIterationConfig,
)

from ..utils import get_logger
from ..custom_models import BiotrainerTempTask
from ..server_management import TaskInterface, TaskDTO, TaskStatus, PreEmbedMixin

logger = get_logger(__name__)


def _biotrainer_subtask_wrapper(
    run_subtask: Callable, update_dto_callback: Callable, config, input_data
) -> BiotrainerModelResult:
    biotrainer_temp_task = BiotrainerTempTask(
        config_dict=config, training_data_with_embeddings=input_data
    )
    biotrainer_dto: Optional[TaskDTO] = None
    for current_dto in run_subtask(biotrainer_temp_task):
        biotrainer_dto = current_dto
    if not biotrainer_dto or biotrainer_dto.biotrainer_result is None:
        update_dto_callback(TaskDTO.errored("Biotrainer failed!"))
        raise Exception("No biotrainer result received!")
    return biotrainer_dto.biotrainer_result


class ActiveLearningScreeningIterationTask(TaskInterface, PreEmbedMixin):
    def __init__(
        self,
        al_campaign_config: ActiveLearningScreeningCampaignConfig,
        al_iteration_config: ActiveLearningScreeningIterationConfig,
        embeddings: Optional[List[SequenceData]] = None,
        all_labels_in_data: Optional[Set[str]] = None,
    ):
        super().__init__()
        self.al_campaign_config = al_campaign_config
        self.al_iteration_config = al_iteration_config
        self.embeddings = embeddings
        self.all_labels_in_data = all_labels_in_data

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        if self.embeddings is not None:
            embeddings = self.embeddings
        else:
            iteration_data = self.al_iteration_config.iteration_data
            embedder_name = self.al_campaign_config.embedder_name
            error_dto, embeddings = self._pre_embed_with_db(
                embedder_name=embedder_name,
                sequence_input=iteration_data,
                reduced=True,
                update_dto_callback=update_dto_callback,
            )
            if error_dto:
                return error_dto
        assert embeddings is not None and len(embeddings) > 0, (
            "embeddings is None after pre-embedding before active learning iteration!"
        )
        # Seed all random generators for reproducibility
        seed_all(self.al_campaign_config.seed)

        al_iteration_result = al_screening_pipeline(
            al_campaign_config=self.al_campaign_config,
            al_iteration_config=self.al_iteration_config,
            embeddings=embeddings,
            biotrainer_subtask_wrapper=lambda config,
            input_data: _biotrainer_subtask_wrapper(
                run_subtask=self.run_subtask,
                update_dto_callback=update_dto_callback,
                config=config,
                input_data=input_data,
            ),
            all_labels_in_data=self.all_labels_in_data,
        )

        logger.info(f"AL Screening - Suggestions: {al_iteration_result.suggestions}")

        return TaskDTO(
            status=TaskStatus.FINISHED, al_iteration_result=al_iteration_result
        )


class ActiveLearningEngineeringIterationTask(TaskInterface, PreEmbedMixin):
    def __init__(
        self,
        al_campaign_config: ActiveLearningEngineeringCampaignConfig,
        al_iteration_config: ActiveLearningEngineeringIterationConfig,
    ):
        super().__init__()
        self.al_campaign_config = al_campaign_config
        self.al_iteration_config = al_iteration_config

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        # Seed all random generators for reproducibility
        seed_all(self.al_campaign_config.seed)

        al_iteration_result = al_engineering_pipeline(
            al_campaign_config=self.al_campaign_config,
            al_iteration_config=self.al_iteration_config,
            embedding_subtask_wrapper=lambda sequence_input: self._pre_embed_with_db(
                embedder_name=self.al_campaign_config.embedder_name,
                sequence_input=sequence_input,
                reduced=True,
                update_dto_callback=update_dto_callback,
                custom_tokenizer_config=None,
            ),
            biotrainer_subtask_wrapper=lambda config,
            input_data: _biotrainer_subtask_wrapper(
                run_subtask=self.run_subtask,
                update_dto_callback=update_dto_callback,
                config=config,
                input_data=input_data,
            ),
        )

        logger.info(f"AL Engineering - Suggestions: {al_iteration_result.suggestions}")

        return TaskDTO(
            status=TaskStatus.FINISHED, al_iteration_result=al_iteration_result
        )
