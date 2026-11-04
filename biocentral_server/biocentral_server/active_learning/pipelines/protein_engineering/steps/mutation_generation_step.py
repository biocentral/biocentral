import random

from typing import Dict, List, Optional, Sequence, Set
from junban import PipelineStep
from biotrainer_core.data_classes import Mutation
from biotrainer_core.utils.constants import STANDARD_AAS

from ..engineering_pipeline_context import EngineeringPipelineContext
from .....utils import get_logger

logger = get_logger(__name__)

# A work bound rather than a statistical one: roughly a second of string operations.
# Only reached when the pool rejects nearly every proposal, and the round then proceeds
# with what was found.
MAX_DRAWS = 1_000_000


class MutationGenerationStep(PipelineStep[EngineeringPipelineContext]):
    def _check_entry_assumptions(self, context: EngineeringPipelineContext) -> bool:
        assert len(context.base_sequences) > 0, "No base sequences provided!"
        return True

    def _check_exit_assumptions(self, context: EngineeringPipelineContext) -> bool:
        n_mutations = len(context.mutations or [])
        assert n_mutations >= context.n_suggestions, (
            f"Only {n_mutations} candidates for {context.n_suggestions} suggestions, "
            f"the round cannot fill its budget!"
        )
        return True

    def get_start_message(self) -> str:
        return "Generating mutations..."

    def get_end_message(self) -> str:
        return "Mutations generated."

    @staticmethod
    def _design_space(
        allowed_substitutions: Optional[List[str]], wildtype_sequence: str
    ) -> Dict[int, List[str]]:
        """Residues each position may take, keyed by 0-based index.

        A position's alphabet holds the wildtype residue alongside every residue named for
        it, so reverting to the wildtype is part of the design space. Without an explicit
        set every position takes any standard amino acid, which is what an engineering
        campaign outside a simulation has always done.
        """
        if allowed_substitutions is None:
            return {
                index: sorted(STANDARD_AAS) for index in range(len(wildtype_sequence))
            }

        alphabets: Dict[int, Set[str]] = {}
        for substitution in allowed_substitutions:
            mutation = Mutation.parse(substitution)
            index = mutation.get_pos()
            alphabets.setdefault(index, {wildtype_sequence[index]}).add(mutation.mt)
        return {index: sorted(alphabets[index]) for index in sorted(alphabets)}

    @staticmethod
    def _proposals_per_base(alternatives: Sequence[int], n_substitutions: int) -> int:
        """How many distinct sequences one base admits at exactly n_substitutions.

        Every choice of n_substitutions positions contributes the product of its
        per-position alternative counts, which is what the elementary symmetric polynomial
        of that degree sums over all such choices.
        """
        counts = [0] * (n_substitutions + 1)
        counts[0] = 1
        for alternative_count in alternatives:
            for degree in range(min(n_substitutions, len(alternatives)), 0, -1):
                counts[degree] += counts[degree - 1] * alternative_count
        return counts[n_substitutions]

    @staticmethod
    def _sample_candidates(
        pool: List[str], excluded: Set[str], n_candidates: int, rng: random.Random
    ) -> List[str]:
        """Up to n_candidates distinct pool members outside excluded, in random order."""
        # Permute indices rather than iterate a set, so seeded runs agree across workers
        sampled = {}
        for index in rng.sample(range(len(pool)), len(pool)):
            sequence = pool[index]
            if sequence not in excluded:
                sampled[sequence] = None
                if len(sampled) == n_candidates:
                    break
        return list(sampled)

    @classmethod
    def _generate_candidates(
        cls,
        bases: List[str],
        design_space: Dict[int, List[str]],
        n_substitutions: int,
        excluded: Set[str],
        pool: Optional[Set[str]],
        n_candidates: int,
        rng: random.Random,
    ) -> List[str]:
        """Distinct sequences, each exactly n_substitutions away from one of the bases.

        Substitutions are drawn only from design_space, and when a pool is given only the
        sequences it holds survive, so a simulation can never suggest a variant its
        landscape has no label for.

        The target is capped by how many distinct sequences the bases actually admit: a
        design space smaller than n_candidates is collected as far as it goes instead of
        being drawn against a budget it can never satisfy.
        """
        positions = sorted(design_space)
        if len(positions) < n_substitutions:
            return []

        reachable = len(bases) * cls._proposals_per_base(
            [len(design_space[index]) - 1 for index in positions], n_substitutions
        )
        target = min(n_candidates, reachable)
        generated: Dict[str, None] = {}
        for _ in range(MAX_DRAWS):
            if len(generated) == target:
                break
            base = bases[rng.randrange(len(bases))]
            candidate = list(base)
            for index in rng.sample(positions, n_substitutions):
                choices = [
                    residue for residue in design_space[index] if residue != base[index]
                ]
                if not choices:
                    break
                candidate[index] = rng.choice(choices)
            else:
                sequence = "".join(candidate)
                if sequence in excluded:
                    continue
                if pool is not None and sequence not in pool:
                    continue
                generated[sequence] = None
        return list(generated)

    def _execute(
        self, context: EngineeringPipelineContext
    ) -> EngineeringPipelineContext:
        training_data_sequences = {
            data_point.seq for data_point in context.al_training_data
        }
        # The wildtype cannot be named as a variant of itself
        excluded = training_data_sequences | {context.wildtype_sequence}
        # Every iteration reseeds identically, so mix in the iteration to draw a fresh
        # sample each round instead of replaying the same permutation
        rng = random.Random(random.getrandbits(64) + context.iteration)

        if context.candidate_pool is not None and not context.generate_candidates:
            context.mutations = self._sample_candidates(
                context.candidate_pool, excluded, context.n_mutations, rng
            )
            return context

        # Repeated bases would weight their own neighbourhoods more heavily
        bases = list(dict.fromkeys(context.base_sequences))
        candidates = self._generate_candidates(
            bases=bases,
            design_space=self._design_space(
                context.allowed_substitutions, context.wildtype_sequence
            ),
            n_substitutions=context.n_substitutions,
            excluded=excluded,
            pool=(
                set(context.candidate_pool)
                if context.candidate_pool is not None
                else None
            ),
            n_candidates=context.n_mutations,
            rng=rng,
        )
        if len(candidates) < context.n_mutations:
            logger.info(
                f"Iteration {context.iteration}: generated {len(candidates)} of "
                f"{context.n_mutations} candidates requested, limited by the design space "
                f"reachable from {len(bases)} base sequences."
            )
        context.mutations = candidates

        return context
