"""Unit tests for the campaign seed reaching the active learning pipelines."""

from typing import List

import pytest
import torch
from biotrainer_core.data_classes import SequenceData
from biotrainer_core.functions.seeding import seed_all

from biocentral_server.active_learning.al_config import (
    ActiveLearningModelType,
    ActiveLearningOptimizationMode,
    ActiveLearningScreeningCampaignConfig,
    ActiveLearningScreeningIterationConfig,
)
from biocentral_server.active_learning.pipelines.al_shared.al_context import ALContext
from biocentral_server.active_learning.pipelines.al_shared.steps.train_model_step import (
    TrainModelStep,
)
from biocentral_server.active_learning.pipelines.protein_screening.screening_pipeline import (
    al_screening_pipeline,
)

_AMINO_ACIDS = "ACDEFGHIKLMNPQRSTVWY"


def _iteration_data() -> List[SequenceData]:
    # Distinct sequences, since embeddings are matched to data points by sequence hash
    sequences = [f"M{a}{b}" for a in _AMINO_ACIDS for b in _AMINO_ACIDS][:55]
    train = [
        SequenceData(seq_id=f"train{i}", seq=seq, label=str(0.1 * (i + 1)), set="train")
        for i, seq in enumerate(sequences[:5])
    ]
    pool = [
        SequenceData(seq_id=f"pool{i}", seq=seq, set="pred")
        for i, seq in enumerate(sequences[5:])
    ]
    return train + pool


def _suggestions(campaign_seed: int, global_seed: int = 0) -> List[str]:
    iteration_data = _iteration_data()
    seed_all(global_seed)
    result = al_screening_pipeline(
        al_campaign_config=ActiveLearningScreeningCampaignConfig(
            name="seeded",
            embedder_name="one_hot_encoding",
            model_type=ActiveLearningModelType.RANDOM,
            optimization_mode=ActiveLearningOptimizationMode.MAXIMIZE,
            seed=campaign_seed,
        ),
        al_iteration_config=ActiveLearningScreeningIterationConfig(
            iteration=1,
            iteration_data=iteration_data,
            coefficient=0.5,
            n_suggestions=5,
        ),
        embeddings=[
            SequenceData(seq_id=d.seq_id, seq=d.seq, embedding=torch.ones(4))
            for d in iteration_data
        ],
        biotrainer_subtask_wrapper=lambda config, input_data: None,
    )
    return result.suggestions


def test_screening_iteration_follows_the_campaign_seed():
    assert _suggestions(campaign_seed=1510, global_seed=0) == _suggestions(
        campaign_seed=1510, global_seed=99
    )


def test_screening_iteration_changes_with_the_campaign_seed():
    assert _suggestions(campaign_seed=1510) != _suggestions(campaign_seed=2903)


@pytest.mark.parametrize(
    "model_type",
    [ActiveLearningModelType.GAUSSIAN_PROCESS, ActiveLearningModelType.FNN_MCD],
)
def test_training_config_carries_the_campaign_seed(model_type):
    configs = []

    def record_biotrainer_call(config, input_data):
        configs.append(config)

    context = ALContext(
        al_optimization_mode=ActiveLearningOptimizationMode.MAXIMIZE,
        al_model_type=model_type,
        embedder_name="one_hot_encoding",
        biotrainer_subtask_wrapper=record_biotrainer_call,
        iteration=1,
        coefficient=0.5,
        n_suggestions=5,
        seed=1510,
    )
    context.training_data = {
        f"train{i}": SequenceData(
            seq_id=f"train{i}", seq="MKT", label=str(0.1 * i), embedding=torch.ones(4)
        )
        for i in range(10)
    }
    context.inference_data = {
        f"pool{i}": SequenceData(seq_id=f"pool{i}", seq="MKT", embedding=torch.ones(4))
        for i in range(10)
    }

    TrainModelStep()._execute(context)

    assert configs[0]["seed"] == 1510
