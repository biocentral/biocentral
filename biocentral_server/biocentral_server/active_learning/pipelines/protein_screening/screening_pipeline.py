from junban import Pipeline
from typing import Callable, List, Optional
from biotrainer_core.data_classes import SequenceData

from .steps import (
    AcquisitionStep,
    BatchSelectionStep,
    TrainModelStep,
    InferenceStep,
    PrepareDataStep,
)
from .screening_pipeline_context import ScreeningPipelineContext
from ...al_config import ActiveLearningCampaignConfig, ActiveLearningIterationConfig
from ....utils import get_logger
from ....server_management import ActiveLearningIterationResult


def al_screening_pipeline(
    al_campaign_config: ActiveLearningCampaignConfig,
    al_iteration_config: ActiveLearningIterationConfig,
    embeddings: List[SequenceData],
    biotrainer_subtask_wrapper: Callable,
    all_target_classes: Optional[List[str]] = None,
) -> ActiveLearningIterationResult:
    pipeline_context = ScreeningPipelineContext(
        al_campaign_config,
        al_iteration_config,
        embeddings,
        biotrainer_subtask_wrapper,
        all_target_classes,
    )
    steps = [
        PrepareDataStep(),
        TrainModelStep(),
        InferenceStep(),
        AcquisitionStep(),
        BatchSelectionStep(),
    ]
    pipeline: Pipeline[ScreeningPipelineContext] = Pipeline(
        steps=steps, name="AL Screening Pipeline", logger=get_logger(__name__)
    )
    final_context = pipeline.execute(pipeline_context)
    return final_context.collect_iteration_result()
