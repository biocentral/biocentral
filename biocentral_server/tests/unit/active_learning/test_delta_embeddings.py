"""Unit tests for delta embeddings in active learning engineering campaigns."""

from collections import Counter

import pytest
import torch
from pydantic import ValidationError
from biotrainer_core.data_classes import SequenceData

from biocentral_server.active_learning.al_config import (
    ActiveLearningEngineeringCampaignConfig,
    ActiveLearningModelType,
    ActiveLearningOptimizationMode,
)
from biocentral_server.active_learning.delta_embeddings import (
    is_baseline_embedder,
    with_delta_embeddings,
)
from biocentral_server.server_management import TaskDTO

WILDTYPE = "MKTAYIAK"
MUTANT_A = "MKTAYIAR"
MUTANT_B = "AKTAYIAK"

# Hand-picked so every expected delta can be checked by eye
EMBEDDINGS = {
    WILDTYPE: torch.tensor([1.0, 2.0]),
    MUTANT_A: torch.tensor([1.5, 1.0]),
    MUTANT_B: torch.tensor([0.0, 2.0]),
}


class RecordingEmbedder:
    """Stands in for the embeddings database: returns EMBEDDINGS and records each request."""

    def __init__(self):
        self.requests = []

    def __call__(self, sequence_input):
        self.requests.append(Counter(data_point.seq for data_point in sequence_input))
        return None, [
            data_point.copy_with_embedding(EMBEDDINGS[data_point.seq])
            for data_point in sequence_input
        ]


def _embed(sequences, embedder=None):
    embedder = embedder or RecordingEmbedder()
    error_dto, embedded = with_delta_embeddings(embedder, WILDTYPE)(sequences)
    assert error_dto is None
    return {data_point.seq_id: data_point for data_point in embedded}


class TestDeltaEmbeddings:
    """The wrapped embedder returns sequence embedding minus wildtype embedding."""

    def test_mutants_get_their_difference_to_the_wildtype(self):
        embedded = _embed(
            [
                SequenceData(seq_id="a", seq=MUTANT_A),
                SequenceData(seq_id="b", seq=MUTANT_B),
            ]
        )

        assert set(embedded) == {"a", "b"}
        torch.testing.assert_close(embedded["a"].embedding, torch.tensor([0.5, -1.0]))
        torch.testing.assert_close(embedded["b"].embedding, torch.tensor([-1.0, 0.0]))

    def test_wildtype_among_inputs_becomes_zero_vector(self):
        embedded = _embed(
            [
                SequenceData(seq_id="wt", seq=WILDTYPE),
                SequenceData(seq_id="a", seq=MUTANT_A),
            ]
        )

        torch.testing.assert_close(embedded["wt"].embedding, torch.tensor([0.0, 0.0]))
        torch.testing.assert_close(embedded["a"].embedding, torch.tensor([0.5, -1.0]))

    def test_wildtype_is_requested_once_when_not_an_input(self):
        embedder = RecordingEmbedder()
        _embed([SequenceData(seq_id="a", seq=MUTANT_A)], embedder)

        assert embedder.requests == [Counter({MUTANT_A: 1, WILDTYPE: 1})]

    def test_wildtype_is_not_requested_twice_when_already_an_input(self):
        embedder = RecordingEmbedder()
        _embed(
            [
                SequenceData(seq_id="wt", seq=WILDTYPE),
                SequenceData(seq_id="a", seq=MUTANT_A),
            ],
            embedder,
        )

        assert embedder.requests == [Counter({WILDTYPE: 1, MUTANT_A: 1})]

    def test_labels_survive_the_subtraction(self):
        embedded = _embed([SequenceData(seq_id="a", seq=MUTANT_A, label="1.5")])

        assert embedded["a"].label == "1.5"

    def test_embedding_error_is_passed_through(self):
        error = TaskDTO.errored("Could not compute embeddings!")

        def failing_embedder(sequence_input):
            return error, []

        error_dto, embedded = with_delta_embeddings(failing_embedder, WILDTYPE)(
            [SequenceData(seq_id="a", seq=MUTANT_A)]
        )

        assert error_dto is error
        assert embedded == []

    def test_missing_wildtype_embedding_is_an_error(self):
        def embedder_dropping_the_wildtype(sequence_input):
            return None, [
                data_point.copy_with_embedding(EMBEDDINGS[data_point.seq])
                for data_point in sequence_input
                if data_point.seq != WILDTYPE
            ]

        error_dto, embedded = with_delta_embeddings(
            embedder_dropping_the_wildtype, WILDTYPE
        )([SequenceData(seq_id="a", seq=MUTANT_A)])

        assert error_dto is not None
        assert embedded == []


def _engineering_config(**overrides) -> ActiveLearningEngineeringCampaignConfig:
    return ActiveLearningEngineeringCampaignConfig(
        **{
            "name": "delta",
            "model_type": ActiveLearningModelType.GAUSSIAN_PROCESS,
            "optimization_mode": ActiveLearningOptimizationMode.MAXIMIZE,
            "embedder_name": "facebook/esm2_t6_8M_UR50D",
            "wildtype_sequence": WILDTYPE,
            **overrides,
        }
    )


class TestEngineeringCampaignConfig:
    """Delta embeddings are opt-in and restricted to protein language models."""

    def test_delta_embeddings_are_off_by_default(self):
        assert _engineering_config().use_delta_embeddings is False

    def test_accepts_delta_embeddings_with_a_plm(self):
        assert _engineering_config(use_delta_embeddings=True).use_delta_embeddings

    @pytest.mark.parametrize(
        "embedder_name",
        ["one_hot_encoding", "blosum62", "length_embedder", "random_embedder"],
    )
    def test_rejects_delta_embeddings_with_a_baseline_embedder(self, embedder_name):
        with pytest.raises(ValidationError, match="(?i)delta embeddings"):
            _engineering_config(embedder_name=embedder_name, use_delta_embeddings=True)


class TestIsBaselineEmbedder:
    @pytest.mark.parametrize(
        "embedder_name, expected",
        [
            ("one_hot_encoding", True),
            ("ONE_HOT_ENCODING", True),
            ("aaontology", True),
            ("facebook/esm2_t6_8M_UR50D", False),
            ("Rostlab/prot_t5_xl_uniref50", False),
        ],
    )
    def test_matches_baseline_names_case_insensitively(self, embedder_name, expected):
        assert is_baseline_embedder(embedder_name) is expected
