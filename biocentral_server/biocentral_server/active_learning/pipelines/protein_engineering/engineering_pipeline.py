from junban import Pipeline
from typing import Callable

from ..al_shared import (
    AcquisitionStep,
    BatchSelectionStep,
    TrainModelStep,
    InferenceStep,
    ALContext,
)
from .steps import EmbeddingStep, MutationGenerationStep
from .engineering_pipeline_context import EngineeringPipelineContext
from ...al_config import (
    ActiveLearningEngineeringCampaignConfig,
    ActiveLearningEngineeringIterationConfig,
)
from ....utils import get_logger
from ....server_management import ActiveLearningIterationResult


def al_engineering_pipeline(
    al_campaign_config: ActiveLearningEngineeringCampaignConfig,
    al_iteration_config: ActiveLearningEngineeringIterationConfig,
    embedding_subtask_wrapper: Callable,
    biotrainer_subtask_wrapper: Callable,
) -> ActiveLearningIterationResult:
    pipeline_context = EngineeringPipelineContext(
        al_optimization_mode=al_campaign_config.optimization_mode,
        al_model_type=al_campaign_config.model_type,
        embedder_name=al_campaign_config.embedder_name,
        al_training_data=al_iteration_config.training_data,
        base_sequences=al_iteration_config.base_sequences,
        embedding_subtask_wrapper=embedding_subtask_wrapper,
        biotrainer_subtask_wrapper=biotrainer_subtask_wrapper,
        iteration=al_iteration_config.iteration,
        coefficient=al_iteration_config.coefficient,
        n_suggestions=al_iteration_config.n_suggestions,
        all_labels_in_data=None,
    )
    steps = [
        MutationGenerationStep(),
        EmbeddingStep(),
        TrainModelStep(),
        InferenceStep(),
        AcquisitionStep(),
        BatchSelectionStep(),
    ]
    pipeline: Pipeline[ALContext] = Pipeline(
        steps=steps, name="AL Engineering Pipeline", logger=get_logger(__name__)
    )
    final_context = pipeline.execute(pipeline_context)
    return final_context.collect_iteration_result()
