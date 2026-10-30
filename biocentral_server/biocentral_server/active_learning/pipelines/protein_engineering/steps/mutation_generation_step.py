import random

from typing import List, Set
from junban import PipelineStep
from biotrainer_core.utils.constants import STANDARD_AAS

from ..engineering_pipeline_context import EngineeringPipelineContext


class MutationGenerationStep(PipelineStep[EngineeringPipelineContext]):
    def _check_entry_assumptions(self, context: EngineeringPipelineContext) -> bool:
        assert len(context.base_sequences) > 0, "No base sequences provided!"
        return True

    def _check_exit_assumptions(self, context: EngineeringPipelineContext) -> bool:
        assert len(context.mutations or []) > 0, "No mutations generated!"
        return True

    def get_start_message(self) -> str:
        return "Generating mutations..."

    def get_end_message(self) -> str:
        return "Mutations generated."

    @staticmethod
    def _generate_random_mutations(
        wildtype_sequence: str, training_data_sequences: Set[str], n_mutations: int
    ) -> List[str]:
        # Sets of strings iterate in a per-process order, so seeded runs in different
        # workers would draw different amino acids and number the mutations differently
        mutations = {}
        n_max_tries = n_mutations * 2
        selectable_aa_dict = {
            aa: sorted(set(STANDARD_AAS) - {aa}) for aa in STANDARD_AAS
        }

        for attempt in range(n_max_tries):
            random_idx = random.randint(0, len(wildtype_sequence) - 1)
            wildtype_aa = wildtype_sequence[random_idx]
            selectable_aas = selectable_aa_dict[wildtype_aa]
            mutation_aa = random.choice(selectable_aas)
            mutated_seq = (
                wildtype_sequence[:random_idx]
                + mutation_aa
                + wildtype_sequence[random_idx + 1 :]
            )
            assert len(mutated_seq) == len(
                wildtype_sequence
            ), "Mutated sequence is not the same length as the wildtype sequence!"
            assert (
                mutated_seq[random_idx] == mutation_aa
            ), "Mutated sequence does not contain the mutation!"
            if mutated_seq in training_data_sequences:
                continue
            mutations[mutated_seq] = None

            if len(mutations) == n_mutations:
                break
        return list(mutations)

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

    def _execute(
        self, context: EngineeringPipelineContext
    ) -> EngineeringPipelineContext:
        training_data_sequences = {
            data_point.seq for data_point in context.al_training_data
        }
        if context.candidate_pool is not None:
            # The wildtype cannot be named as a variant of itself
            excluded = training_data_sequences | {context.wildtype_sequence}
            # Every iteration reseeds identically, so mix in the iteration to draw a fresh
            # sample each round instead of replaying the same permutation
            rng = random.Random(random.getrandbits(64) + context.iteration)
            context.mutations = self._sample_candidates(
                context.candidate_pool, excluded, context.n_mutations, rng
            )
            return context

        base_sequences = context.base_sequences
        wildtype_sequence = base_sequences[0]  # TODO handle multiple base sequences
        n_mutations = context.n_mutations
        mutations = self._generate_random_mutations(
            wildtype_sequence, training_data_sequences, n_mutations
        )
        context.mutations = mutations

        return context
