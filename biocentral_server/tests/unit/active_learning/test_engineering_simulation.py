"""Unit tests for the engineering simulation driver.

The iteration itself is stubbed, so these cover the simulation's own job: drawing
candidates from the landscape, translating variant descriptors back to landscape ids,
revealing labels and honouring the budget.
"""

import random

import pytest
from pydantic import ValidationError
from biotrainer_core.data_classes import SequenceData

from biocentral_server.active_learning.al_config import (
    ActiveLearningEngineeringCampaignConfig,
    ActiveLearningEngineeringSimulationConfig,
    ActiveLearningModelType,
    ActiveLearningOptimizationMode,
    ActiveLearningStoppingConfig,
)
from biocentral_server.active_learning.al_simulation_task import (
    ActiveLearningEngineeringSimulationTask,
)
from biocentral_server.active_learning.pipelines.protein_engineering.steps.mutation_generation_step import (
    MutationGenerationStep,
)
from biocentral_server.server_management import (
    ActiveLearningIterationResult,
    ActiveLearningResult,
)

WILDTYPE = "ACDEFG"


def _landscape():
    """Wildtype plus every single substitution to V, labelled by position."""
    pool = [SequenceData(seq_id="WT", seq=WILDTYPE, label="0.0")]
    for position, residue in enumerate(WILDTYPE):
        if residue == "V":
            continue
        variant = WILDTYPE[:position] + "V" + WILDTYPE[position + 1 :]
        pool.append(
            SequenceData(
                seq_id=f"{residue}{position + 1}V", seq=variant, label=str(position + 1)
            )
        )
    return pool


def _campaign(**overrides):
    return ActiveLearningEngineeringCampaignConfig(
        **{
            "name": "sim",
            "model_type": ActiveLearningModelType.RANDOM,
            "optimization_mode": ActiveLearningOptimizationMode.MAXIMIZE,
            "embedder_name": "one_hot_encoding",
            "wildtype_sequence": WILDTYPE,
            **overrides,
        }
    )


def _simulation(**overrides):
    return ActiveLearningEngineeringSimulationConfig(
        **{
            "simulation_data": _landscape(),
            "start_ids": ["WT", "A1V"],
            "n_suggestions_per_iteration": 1,
            "n_candidates_per_iteration": 3,
            "stopping_config": ActiveLearningStoppingConfig(max_labels_budget=2),
            **overrides,
        }
    )


def _task(campaign=None, simulation=None):
    return ActiveLearningEngineeringSimulationTask(
        al_campaign_config=campaign or _campaign(),
        al_simulation_config=simulation or _simulation(),
    )


class TestConfig:
    def test_duplicate_sequences_are_rejected(self):
        duplicated = _landscape() + [
            SequenceData(seq_id="copy", seq=WILDTYPE, label="1.0")
        ]
        with pytest.raises(ValidationError, match="duplicate sequences"):
            _simulation(simulation_data=duplicated)

    def test_candidates_must_cover_suggestions(self):
        with pytest.raises(ValidationError, match="n_candidates_per_iteration"):
            _simulation(n_candidates_per_iteration=1, n_suggestions_per_iteration=2)

    def test_engineering_simulation_has_no_target_delta(self):
        assert (
            "hit_target_delta"
            not in ActiveLearningEngineeringSimulationConfig.model_fields
        )


class TestOracle:
    def test_descriptor_maps_back_to_landscape_id(self):
        task = _task()
        assert task._seq_id("C2V") == "C2V"
        assert task._seq_id("A1V") == "A1V"

    def test_variant_outside_the_landscape_is_named(self):
        task = _task()
        # Valid descriptor against the wildtype, but no such landscape member
        with pytest.raises(ValueError, match="A1W"):
            task._seq_id("A1W")

    def test_descriptor_disagreeing_with_the_wildtype_raises(self):
        task = _task()
        with pytest.raises(ValueError):
            task._seq_id("W1V")

    def test_canonicalisation_rewrites_results_and_suggestions(self):
        task = _task()
        recorded = []
        raw = ActiveLearningIterationResult(
            iteration=1,
            results=[
                ActiveLearningResult(
                    entity_id="C2V", prediction="1.0", uncertainty=0.1, score=0.5
                )
            ],
            suggestions=["C2V"],
        )
        canonical = task._canonicalize_iteration_result(raw, recorded.append)

        assert canonical.suggestions == ["C2V"]
        assert [r.entity_id for r in canonical.results] == ["C2V"]
        # The client rebuilds iteration_results from these updates
        assert recorded and recorded[-1].al_iteration_result is canonical


class TestCandidateSampling:
    def test_sample_excludes_and_respects_budget(self):
        pool = ["AAA", "BBB", "CCC", "DDD"]
        sampled = MutationGenerationStep._sample_candidates(
            pool, {"BBB"}, 2, random.Random(0)
        )
        assert len(sampled) == 2
        assert "BBB" not in sampled
        assert set(sampled) <= set(pool)

    def test_sample_returns_what_it_can_when_the_pool_runs_out(self):
        pool = ["AAA", "BBB"]
        sampled = MutationGenerationStep._sample_candidates(
            pool, {"AAA"}, 5, random.Random(0)
        )
        assert sampled == ["BBB"]

    def test_sampling_is_deterministic_for_a_given_stream(self):
        pool = [f"SEQ{i}" for i in range(20)]
        first = MutationGenerationStep._sample_candidates(
            pool, set(), 5, random.Random(7)
        )
        second = MutationGenerationStep._sample_candidates(
            pool, set(), 5, random.Random(7)
        )
        assert first == second


class TestRoundLoop:
    def _run(self, task, suggestions_per_round):
        """Drive the loop with stubbed iterations, recording what each round was given."""
        seen = []

        def fake_iteration(
            iteration_number,
            n_to_suggest,
            coefficient,
            current_training_data,
            update_dto_callback,
        ):
            labelled = [d for d in current_training_data if d.get_set() == "train"]
            seen.append(
                {
                    "iteration": iteration_number,
                    "n_to_suggest": n_to_suggest,
                    "n_labelled": len(labelled),
                }
            )
            suggested = suggestions_per_round[iteration_number - 1]
            return ActiveLearningIterationResult(
                iteration=iteration_number,
                results=[
                    ActiveLearningResult(
                        entity_id=s, prediction="1.0", uncertainty=0.1, score=0.5
                    )
                    for s in suggested
                ],
                suggestions=list(suggested),
            )

        task._run_single_iteration = fake_iteration
        dto = task._run_simulation(lambda _dto: None)
        return seen, dto

    def test_budget_clamps_the_final_round(self):
        task = _task(
            simulation=_simulation(
                n_suggestions_per_iteration=2,
                n_candidates_per_iteration=3,
                stopping_config=ActiveLearningStoppingConfig(max_labels_budget=3),
            )
        )
        seen, dto = self._run(task, [["C2V", "D3V"], ["E4V"]])
        assert [round_["n_to_suggest"] for round_ in seen] == [2, 1]
        assert dto.al_simulation_result.stop_reasons

    def test_suggestions_become_labelled_training_data(self):
        task = _task()
        seen, _ = self._run(task, [["C2V"], ["D3V"]])
        # Two start ids, then one revealed per round
        assert [round_["n_labelled"] for round_ in seen][:2] == [2, 3]

    def test_hits_are_counted_against_landscape_labels(self):
        task = _task()
        _, dto = self._run(task, [["F5V"], ["D3V"]])
        result = dto.al_simulation_result
        assert result.iteration_hits
        # Hits are reported as landscape ids, not descriptors
        for hits in result.iteration_hits:
            assert all(h in {d.seq_id for d in _landscape()} for h in hits)
