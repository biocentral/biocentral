from typing import List
from junban import PipelineStep

from ..al_context import ALContext

from .....server_management import ActiveLearningResult


class AcquisitionStep(PipelineStep[ALContext]):
    def _check_entry_assumptions(self, context: ALContext) -> bool:
        assert context.desirability is not None
        assert context.uncertainty is not None
        return True

    def _check_exit_assumptions(self, context: ALContext) -> bool:
        assert context.scores is not None
        return True

    def get_start_message(self) -> str:
        return "Running scoring via acquisition function..."

    def get_end_message(self) -> str:
        return "Samples scored."

    @staticmethod
    def _upper_confidence_bound(desirability, uncertainty, beta):
        """Calculate acquisition score as desirability + beta * uncertainty. (Upper Confidence Bound)

        Note: The terms are not normalized, so for a model whose predicted standard deviations
        are small compared to the spread of its predicted values, even beta = 1 mostly picks the
        most desirable variants. Normalizing both terms to [0, 1] would make beta comparable
        across datasets, rounds and models (and fix the unit mismatch between class probability
        and BALD score for DISCRETE), but would discard how confident the model actually is.
        """
        acquisition = desirability + beta * uncertainty
        return acquisition

    def _execute(self, context: ALContext) -> ALContext:
        # Calculate acquisition scores
        beta = context.coefficient
        desirability = context.desirability
        uncertainty = context.uncertainty
        acquisition_scores = self._upper_confidence_bound(
            desirability, uncertainty, beta
        )

        context.scores = acquisition_scores

        # Create AL results
        results: List[ActiveLearningResult] = []
        for idx, key in enumerate(context.inference_data.keys()):
            sid = key
            pred = str(context.predictions[idx])
            uncertainty = context.uncertainty[idx].item()
            score = context.scores[idx].item()
            al_result = ActiveLearningResult(
                entity_id=sid, prediction=pred, uncertainty=uncertainty, score=score
            )
            results.append(al_result)

        context.al_results = results
        return context
