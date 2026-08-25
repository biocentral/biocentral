from junban import Pipeline
from typing import Callable, List, Optional, Set
from biotrainer_core.data_classes import SequenceData

from .steps import (
    PrepareDataStep,
)
from .screening_pipeline_context import ScreeningPipelineContext

from ..al_shared import (
    ALContext,
    AcquisitionStep,
    BatchSelectionStep,
    TrainModelStep,
    InferenceStep,
)
from ...al_config import (
    ActiveLearningScreeningCampaignConfig,
    ActiveLearningScreeningIterationConfig,
)

from ....utils import get_logger
from ....server_management import ActiveLearningIterationResult


def al_screening_pipeline(
    al_campaign_config: ActiveLearningScreeningCampaignConfig,
    al_iteration_config: ActiveLearningScreeningIterationConfig,
    embeddings: List[SequenceData],
    biotrainer_subtask_wrapper: Callable,
    all_labels_in_data: Optional[Set[str]] = None,
) -> ActiveLearningIterationResult:
    pipeline_context = ScreeningPipelineContext(
        al_optimization_mode=al_campaign_config.optimization_mode,
        al_model_type=al_campaign_config.model_type,
        embedder_name=al_campaign_config.embedder_name,
        al_iteration_data=al_iteration_config.iteration_data,
        biotrainer_subtask_wrapper=biotrainer_subtask_wrapper,
        embeddings=embeddings,
        iteration=al_iteration_config.iteration,
        coefficient=al_iteration_config.coefficient,
        n_suggestions=al_iteration_config.n_suggestions,
        al_target_value=al_campaign_config.target_value,
        al_target_lb=al_campaign_config.target_lb,
        al_target_ub=al_campaign_config.target_ub,
        al_discrete_targets=al_campaign_config.discrete_targets,
        all_labels_in_data=all_labels_in_data,
    )
    steps = [
        PrepareDataStep(),
        TrainModelStep(),
        InferenceStep(),
        AcquisitionStep(),
        BatchSelectionStep(),
    ]
    pipeline: Pipeline[ALContext] = Pipeline(
        steps=steps, name="AL Screening Pipeline", logger=get_logger(__name__)
    )
    final_context = pipeline.execute(pipeline_context)
    return final_context.collect_iteration_result()
