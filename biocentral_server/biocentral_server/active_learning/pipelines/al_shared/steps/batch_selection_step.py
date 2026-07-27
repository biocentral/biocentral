from typing import List
from junban import PipelineStep

from ..al_context import ALContext

from .....server_management import ActiveLearningResult


class BatchSelectionStep(PipelineStep[ALContext]):
    def _check_entry_assumptions(self, context: ALContext) -> bool:
        assert context.scores is not None
        assert context.al_results is not None
        return True

    def _check_exit_assumptions(self, context: ALContext) -> bool:
        return True

    def get_start_message(self) -> str:
        return "Running batch selection..."

    def get_end_message(self) -> str:
        return "Batch selection finished."

    @staticmethod
    def _batch_selection(results: List[ActiveLearningResult], n_suggestions: int):
        """Sort results by score and return top n_suggestions."""
        results.sort(key=lambda al_r: al_r.score, reverse=True)
        suggestions = [result.entity_id for result in results[:n_suggestions]]
        return results, suggestions

    def _execute(self, context: ALContext) -> ALContext:
        sorted_results, suggestions = self._batch_selection(
            context.al_results, context.n_suggestions
        )

        context.al_results = sorted_results
        context.suggestions = suggestions
        return context
