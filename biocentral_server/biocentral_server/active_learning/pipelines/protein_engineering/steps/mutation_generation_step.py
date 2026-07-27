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
        mutations = set()
        n_max_tries = n_mutations * 2
        selectable_aa_dict = {aa: list(set(STANDARD_AAS) - {aa}) for aa in STANDARD_AAS}

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
            assert len(mutated_seq) == len(wildtype_sequence), (
                "Mutated sequence is not the same length as the wildtype sequence!"
            )
            assert mutated_seq[random_idx] == mutation_aa, (
                "Mutated sequence does not contain the mutation!"
            )
            if mutated_seq in training_data_sequences:
                continue
            mutations.add(mutated_seq)

            if len(mutations) == n_mutations:
                break
        return list(mutations)

    def _execute(
        self, context: EngineeringPipelineContext
    ) -> EngineeringPipelineContext:
        base_sequences = context.base_sequences
        wildtype_sequence = base_sequences[0]  # TODO handle multiple base sequences

        training_data_sequences = {
            data_point.seq for data_point in context.al_training_data
        }
        n_mutations = context.n_mutations
        mutations = self._generate_random_mutations(
            wildtype_sequence, training_data_sequences, n_mutations
        )
        context.mutations = mutations

        return context
