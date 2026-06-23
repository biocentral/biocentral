import random

from typing import List
from junban import PipelineStep
from biotrainer_core.utils.constants import STANDARD_AAS

from ..engineering_pipeline_context import EngineeringPipelineContext


class MutationGenerationStep(PipelineStep[EngineeringPipelineContext]):
    def _check_entry_assumptions(self, context: EngineeringPipelineContext) -> bool:
        pass

    def _check_exit_assumptions(self, context: EngineeringPipelineContext) -> bool:
        pass

    def get_start_message(self) -> str:
        return "Generating mutations..."

    def get_end_message(self) -> str:
        return "Mutations generated."

    @staticmethod
    def _generate_random_mutations(
        wildtype_sequence: str, n_mutations: int
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
            mutations.add(mutated_seq)

            if len(mutations) == n_mutations:
                break
        return list(mutations)

    def _execute(
        self, context: EngineeringPipelineContext
    ) -> EngineeringPipelineContext:
        wildtype_sequence = context.wildtype_sequence
        n_mutations = context.n_mutations

        mutations = self._generate_random_mutations(wildtype_sequence, n_mutations)
        context.mutations = mutations

        return context
