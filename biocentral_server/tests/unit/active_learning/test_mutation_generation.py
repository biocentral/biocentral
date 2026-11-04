"""Unit tests for the engineering candidate generator.

The generator has to stay inside a landscape's design space, mutate every base it is
given rather than only the first, and -- in a simulation -- never propose a variant the
landscape has no label for.
"""

import json
import os
import random
import subprocess
import sys
import types

from biotrainer_core.utils.constants import STANDARD_AAS

from biocentral_server.active_learning.pipelines.protein_engineering.steps import (
    mutation_generation_step,
)
from biocentral_server.active_learning.pipelines.protein_engineering.steps.mutation_generation_step import (
    MutationGenerationStep,
)

WILDTYPE = "ACDEFG"
# Position 1 may hold A or M, position 3 may hold D, K or W. Three single substitutions
# and two doubles are reachable from the wildtype, which is small enough to enumerate.
ALLOWED = ["A1M", "D3K", "D3W"]
SINGLES = {"MCDEFG", "ACKEFG", "ACWEFG"}
DOUBLES = {"MCKEFG", "MCWEFG"}


def _generate(bases, n_substitutions=1, excluded=frozenset(), pool=None, n=100, seed=0):
    return MutationGenerationStep._generate_candidates(
        bases=list(bases),
        design_space=MutationGenerationStep._design_space(ALLOWED, WILDTYPE),
        n_substitutions=n_substitutions,
        excluded=set(excluded),
        pool=pool,
        n_candidates=n,
        rng=random.Random(seed),
    )


class TestDesignSpace:
    def test_alphabet_includes_the_wildtype_residue(self):
        # Reverting to the wildtype is part of a design space, so it must be drawable
        assert MutationGenerationStep._design_space(ALLOWED, WILDTYPE) == {
            0: ["A", "M"],
            2: ["D", "K", "W"],
        }

    def test_without_a_design_space_every_position_takes_any_residue(self):
        space = MutationGenerationStep._design_space(None, "AC")
        assert space == {0: sorted(STANDARD_AAS), 1: sorted(STANDARD_AAS)}

    def test_proposals_per_base_sums_over_position_subsets(self):
        # Alternatives [1, 2]: three singles, and one double of 1 * 2
        assert MutationGenerationStep._proposals_per_base([1, 2], 1) == 3
        assert MutationGenerationStep._proposals_per_base([1, 2], 2) == 2


class TestGeneration:
    def test_candidates_stay_inside_the_design_space(self):
        assert set(_generate([WILDTYPE])) == SINGLES

    def test_candidates_differ_from_their_base_at_exactly_n_substitutions(self):
        for candidate in _generate([WILDTYPE], n_substitutions=2):
            differing = sum(a != b for a, b in zip(WILDTYPE, candidate))
            assert differing == 2
        assert set(_generate([WILDTYPE], n_substitutions=2)) == DOUBLES

    def test_every_base_is_mutated_not_just_the_first(self):
        # MCKEFG is only one substitution away from the second base
        candidates = set(_generate([WILDTYPE, "MCDEFG"], n=6))
        assert "MCKEFG" in candidates
        assert candidates == SINGLES | {"ACDEFG", "MCKEFG", "MCWEFG"}

    def test_a_pool_restricts_candidates_to_sequences_it_holds(self):
        candidates = _generate([WILDTYPE], pool={"ACKEFG"})
        assert candidates == ["ACKEFG"]

    def test_excluded_sequences_never_come_back(self):
        assert set(_generate([WILDTYPE], excluded={"ACKEFG"})) == SINGLES - {"ACKEFG"}

    def test_target_is_capped_by_what_the_design_space_admits(self):
        # Asking for 100 from a space holding 3 collects the 3 instead of drawing on
        assert len(_generate([WILDTYPE], n=100)) == 3

    def test_more_substitutions_than_positions_yields_nothing(self):
        assert _generate([WILDTYPE], n_substitutions=3) == []

    def test_drawing_stops_at_the_work_bound(self, monkeypatch):
        monkeypatch.setattr(mutation_generation_step, "MAX_DRAWS", 50)
        # Nothing is reachable, so only the work bound can end the loop
        assert _generate([WILDTYPE], pool=set()) == []


class TestExecute:
    def _context(self, iteration, **overrides):
        context = types.SimpleNamespace(
            al_training_data=[],
            wildtype_sequence=WILDTYPE,
            base_sequences=[WILDTYPE],
            candidate_pool=None,
            generate_candidates=True,
            allowed_substitutions=None,
            n_mutations=5,
            n_substitutions=1,
            n_suggestions=1,
            iteration=iteration,
            mutations=None,
        )
        for key, value in overrides.items():
            setattr(context, key, value)
        return context

    def _run(self, iteration, campaign_seed=42, **overrides):
        # The iteration task reseeds the global stream per round before the pipeline runs
        random.seed(campaign_seed)
        context = self._context(iteration, **overrides)
        return MutationGenerationStep()._execute(context).mutations

    def test_the_same_round_reproduces_under_the_same_campaign_seed(self):
        assert self._run(1) == self._run(1)

    def test_consecutive_rounds_draw_different_candidates(self):
        # The campaign seed is identical each round, so only the iteration can differ them
        assert self._run(1) != self._run(2)

    def test_the_wildtype_is_never_proposed_as_its_own_variant(self):
        candidates = self._run(1, allowed_substitutions=ALLOWED, n_mutations=100)
        assert WILDTYPE not in candidates

    def test_a_pool_alone_still_samples_rather_than_generates(self):
        candidates = self._run(
            1,
            generate_candidates=False,
            candidate_pool=["ACKEFG", "ACWEFG"],
            n_mutations=2,
        )
        assert sorted(candidates) == ["ACKEFG", "ACWEFG"]


GENERATE = (
    "import json, random\n"
    "from biocentral_server.active_learning.pipelines.protein_engineering.steps"
    ".mutation_generation_step import MutationGenerationStep\n"
    "wildtype = 'MKTAYIAKQRQISFVKSHFSRQ'\n"
    "print(json.dumps(MutationGenerationStep._generate_candidates("
    "bases=[wildtype],"
    "design_space=MutationGenerationStep._design_space(None, wildtype),"
    "n_substitutions=1, excluded=set(), pool=None, n_candidates=50,"
    "rng=random.Random(42))))"
)


def _generate_in_process_with_hash_seed(hash_seed: str) -> list:
    """Each RQ work horse has its own string hash seed; mimic that per subprocess."""
    completed = subprocess.run(
        [sys.executable, "-c", GENERATE],
        env={**os.environ, "PYTHONHASHSEED": hash_seed},
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(completed.stdout.strip().splitlines()[-1])


def test_order_does_not_depend_on_the_process_hash_seed():
    first = _generate_in_process_with_hash_seed("1")
    second = _generate_in_process_with_hash_seed("2")

    assert len(first) == 50
    assert first == second
