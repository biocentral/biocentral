from typing import Callable, Tuple, List, Optional
from biotrainer.utilities import get_device, seed_all
from biotrainer.input_files import BiotrainerSequenceRecord

from .al_iteration_pipeline import al_pipeline
from .al_config import ActiveLearningCampaignConfig, ActiveLearningIterationConfig

from ..utils import get_logger
from ..embeddings import LoadEmbeddingsTask
from ..custom_models import BiotrainerTempTask
from ..server_management import TaskInterface, TaskDTO, TaskStatus

logger = get_logger(__name__)


class ActiveLearningIterationTask(TaskInterface):
    def __init__(
        self,
        al_campaign_config: ActiveLearningCampaignConfig,
        al_iteration_config: ActiveLearningIterationConfig,
        embeddings: Optional[List[BiotrainerSequenceRecord]] = None,
        all_target_classes: Optional[List[str]] = None,
    ):
        super().__init__()
        self.al_campaign_config = al_campaign_config
        self.al_iteration_config = al_iteration_config
        self.embeddings = embeddings
        self.all_target_classes = all_target_classes

    @staticmethod
    def _biotrainer_subtask_wrapper(
        run_subtask: Callable, update_dto_callback: Callable, config, input_data
    ):
        biotrainer_temp_task = BiotrainerTempTask(
            config_dict=config, training_data_with_embeddings=input_data
        )
        biotrainer_dto: Optional[TaskDTO] = None
        for current_dto in run_subtask(biotrainer_temp_task):
            biotrainer_dto = current_dto
            update_dto_callback(biotrainer_dto)
        if not biotrainer_dto or biotrainer_dto.biotrainer_result is None:
            update_dto_callback(
                TaskDTO(status=TaskStatus.FAILED, error="Biotrainer failed!")
            )
            raise Exception("No biotrainer result received!")
        return biotrainer_dto.biotrainer_result

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        if self.embeddings is not None:
            embeddings = self.embeddings
        else:
            error_dto, embeddings = self._pre_embed_with_db()
            if error_dto:
                return error_dto
        assert embeddings is not None and len(embeddings) > 0, (
            "embeddings is None after pre-embedding before active learning iteration!"
        )
        # Seed all random generators for reproducibility
        seed_all(self.al_campaign_config.seed)

        al_iteration_result = al_pipeline(
            al_campaign_config=self.al_campaign_config,
            al_iteration_config=self.al_iteration_config,
            embeddings=embeddings,
            biotrainer_subtask_wrapper=lambda config,
            input_data: self._biotrainer_subtask_wrapper(
                run_subtask=self.run_subtask,
                update_dto_callback=update_dto_callback,
                config=config,
                input_data=input_data,
            ),
            all_target_classes=self.all_target_classes,
        )

        logger.info(f"AL - Suggestions: {al_iteration_result.suggestions}")

        return TaskDTO(
            status=TaskStatus.FINISHED, al_iteration_result=al_iteration_result
        )

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
