import torch
import random

from junban import PipelineStep
from typing import List, Literal
from biotrainer_core.data_classes import SequenceData, Protocol, BiotrainerModelResult

from ....al_config import ActiveLearningOptimizationMode, ActiveLearningModelType

from ..screening_pipeline_context import ScreeningPipelineContext


class TrainModelStep(PipelineStep[ScreeningPipelineContext]):
    def _check_entry_assumptions(self, context: ScreeningPipelineContext) -> bool:
        assert len(context.training_data) > 0
        if context.uses_biotrainer():
            assert context.biotrainer_subtask_wrapper is not None
        return True

    def _check_exit_assumptions(self, context: ScreeningPipelineContext) -> bool:
        if context.uses_biotrainer():
            assert context.biotrainer_result is not None
        return True

    def get_start_message(self) -> str:
        return "Training model..."

    def get_end_message(self) -> str:
        return "Model trained on training data."

    @staticmethod
    def _prepare_biotrainer_config(
        context: ScreeningPipelineContext,
        task_type: Literal["classification", "regression"],
    ) -> dict:
        model_choice = None
        match context.al_campaign_config.model_type:
            case ActiveLearningModelType.GAUSSIAN_PROCESS:
                model_choice = "GP"
            case ActiveLearningModelType.FNN_MCD:
                model_choice = "FNN"
        protocol = None
        match context.al_campaign_config.optimization_mode:
            case ActiveLearningOptimizationMode.DISCRETE:
                protocol = Protocol.sequence_to_class.value
            case _:
                protocol = Protocol.sequence_to_value.value
        # Set default epochs based on task type
        num_epochs = 200 if task_type == "classification" else 120
        patience = (
            120
            if context.al_campaign_config.model_type
            == ActiveLearningModelType.GAUSSIAN_PROCESS
            else 50
        )
        return {
            "model_choice": model_choice,
            "protocol": protocol,
            "num_epochs": num_epochs,
            "patience": patience,
        }

    def _train_and_inference_biotrainer(
        self,
        context: ScreeningPipelineContext,
        task_type: Literal["classification", "regression"],
    ) -> BiotrainerModelResult:
        """
        Unified training and inference for GP models.

        Args:
            context: ScreeningPipelineContext
            task_type: 'classification' or 'regression'

        Returns:
            scores: tensor of shape (n_inference_data)
            means: predicted means
            uncertainties: predicted uncertainties
        """

        # Create dummy test set
        # TODO Improve in biotrainer to not need a test set strictly
        first_embedding = next(iter(context.training_data.values())).embedding
        if (
            context.al_campaign_config.optimization_mode
            == ActiveLearningOptimizationMode.DISCRETE
        ):
            assert context.all_labels_in_data is not None, (
                "all_target_classes must be provided for discrete optimization"
            )
            test_data = [
                SequenceData(
                    seq_id=f"DummyTestSeq{idx}",
                    seq="DUMMY" * idx,
                    embedding=torch.zeros_like(first_embedding),
                    attributes={"set": "test", "target": target},
                )
                for idx, target in enumerate(context.all_labels_in_data)
            ]
        else:  # a single sequence is sufficient for regression
            test_data = [
                SequenceData(
                    seq_id="DummyTestSeq",
                    seq="DUMMY",
                    embedding=torch.zeros_like(first_embedding),
                    attributes={"set": "test", "target": "0"},
                )
            ]

        # Create validation set: Assign random seqs from train to validation
        val_data_k = max(1, len(context.training_data) // 10)
        val_data: List[SequenceData] = random.sample(
            list(context.training_data.values()), k=val_data_k
        )
        val_data = [
            SequenceData(
                seq_id=data_point.seq_id,
                seq=data_point.seq,
                attributes={
                    k: v if str(k).lower() != "set" else "val"
                    for k, v in data_point.attributes.items()
                },
                embedding=data_point.embedding,
            )
            for data_point in val_data
        ]
        val_data_ids = set([data_point.seq_id for data_point in val_data])
        train_data = [
            data_point
            for data_point in context.training_data.values()
            if data_point.seq_id not in val_data_ids
        ]

        # Prepare config
        config = self._prepare_biotrainer_config(context, task_type)

        input_data = [
            *train_data,
            *val_data,
            *test_data,
            *context.inference_data.values(),
        ]

        # Run biotrainer
        result = context.biotrainer_subtask_wrapper(config, input_data)

        return result

    def _execute(self, context: ScreeningPipelineContext) -> ScreeningPipelineContext:
        mode = context.al_campaign_config.optimization_mode
        task_type = (
            "classification"
            if mode == ActiveLearningOptimizationMode.DISCRETE
            else "regression"
        )
        model_type = context.al_campaign_config.model_type
        match model_type:
            case (
                ActiveLearningModelType.GAUSSIAN_PROCESS
                | ActiveLearningModelType.FNN_MCD
            ):
                result = self._train_and_inference_biotrainer(
                    context=context,
                    task_type=task_type,
                )
                context.biotrainer_result = result
            case ActiveLearningModelType.RANDOM:
                pass

        return context
