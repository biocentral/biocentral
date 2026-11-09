import random

from typing import Dict, List, Optional, Sequence, Set
from junban import PipelineStep
from biotrainer_core.data_classes import Mutation
from biotrainer_core.utils.constants import STANDARD_AAS

from ..engineering_pipeline_context import EngineeringPipelineContext
from .....utils import get_logger

logger = get_logger(__name__)

MAX_DRAWS = 1_000_000  # rule-of-thumb


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
        wildtype_sequence: str, allowed_substitutions: Optional[List[str]]
    ) -> Dict[int, List[str]]:
        """Residues each position may take, keyed by 0-based index.

        Notes:
            Defaults to all standard amino acids for each position.

            Includes wildtype residue at each position.
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
    def _num_reachable_sequences(num_alternatives: Sequence[int], n_substitutions: int) -> int:
        """Counts how many unique sequences are reachable at n_substitutions from a base sequence in n_substitutions.

        Args:
            num_alternatives: Number of alternative residues allowed for each position.
            n_substitutions: Number of positions to mutate.
        """
        counts = [0] * (n_substitutions + 1)
        counts[0] = 1
        for alternative_count in num_alternatives:
            for degree in range(min(n_substitutions, len(num_alternatives)), 0, -1):
                counts[degree] += counts[degree - 1] * alternative_count
        return counts[n_substitutions]

    @staticmethod
    def _sample_candidates(
        pool: List[str], excluded: Set[str], n_candidates: int, rng: random.Random
    ) -> List[str]:
        """Sample up to n_candidates distinct pool members in random order."""
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
    def _randomly_generate_candidates(
        cls,
        base_sequences: List[str],
        design_space: Dict[int, List[str]],
        n_substitutions: int,
        excluded: Set[str],
        pool: Optional[Set[str]],
        n_candidates: int,
        rng: random.Random,
    ) -> List[str]:
        """Randomly draw distinct candidates by substituting residues in the bases.

        Args:
            base_sequences: Sequences to mutate; each draw picks one uniformly.
            design_space: Residues allowed at each 0-based position.
            n_substitutions: Number of positions substituted per candidate.
            excluded: Sequences that aren't allowed to be returned.
            pool: If given, only sequences in it are returned.
            n_candidates: Number of candidates to draw.
            rng: Source of all randomness, so seeded runs are reproducible.

        Returns:
            Up to n_candidates sequences, each exactly n_substitutions away from the
            base it was drawn from.

        Notes:
            Returns fewer than n_candidates if the bases admit fewer valid sequences
            or MAX_DRAWS is reached first.

            Sequences are ordered by draw.
        """
        positions = sorted(design_space)
        if len(positions) < n_substitutions:
            return []

        reachable = len(base_sequences) * cls._num_reachable_sequences(
            [len(design_space[index]) - 1 for index in positions], n_substitutions
        )
        target = min(n_candidates, reachable)
        generated: Dict[str, None] = {}
        for _ in range(MAX_DRAWS):
            if len(generated) == target:
                break
            base = base_sequences[rng.randrange(len(base_sequences))]
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
        candidates = self._randomly_generate_candidates(
            base_sequences=bases,
            design_space=self._design_space(
                context.wildtype_sequence, context.allowed_substitutions
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
