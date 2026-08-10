import unittest

from biocentral_api import (
    SequenceData,
    ActiveLearningScreeningCampaignConfig,
    ActiveLearningScreeningIterationConfig,
    ActiveLearningEngineeringCampaignConfig,
    ActiveLearningEngineeringIterationConfig,
    ActiveLearningOptimizationMode,
    ActiveLearningModelType,
    ActiveLearningScreeningSimulationConfig,
    ActiveLearningConvergenceConfig,
)


class TestActiveLearning(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from tests.integration.conftest import _make_api, _wait_or_skip

        cls.api = _wait_or_skip(_make_api())

    def test_active_learning_screening_iteration(self):
        campaign_config = ActiveLearningScreeningCampaignConfig(
            name="Example_Campaign",
            model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
            embedder_name="one_hot_encoding",
            optimization_mode=ActiveLearningOptimizationMode.VALUE,
            target_value=10.0,
        )

        iteration_data = [
            SequenceData(
                seq_id="Seq1", seq="MMALSLALM", label="5.4", set="train", mask=None
            ),
            SequenceData(
                seq_id="Seq2", seq="PRTEIN", label="1.1", set="train", mask=None
            ),
            SequenceData(seq_id="Seq3", seq="PRT", label="2.2", set="train", mask=None),
            SequenceData(seq_id="Seq4", seq="SEQWENCE", set="pred", mask=None),
            SequenceData(seq_id="Seq5", seq="PRTE", set="pred", mask=None),
            SequenceData(seq_id="Seq6", seq="MMALSM", set="pred", mask=None),
            SequenceData(seq_id="Seq7", seq="PRSEQ", set="pred", mask=None),
        ]

        iteration_config = ActiveLearningScreeningIterationConfig(
            iteration_data=iteration_data,
            n_suggestions=1,
            coefficient=0.8,
            iteration=1,
        )

        iteration_result = self.api.al_screening_iteration(
            campaign_config, iteration_config
        ).run_with_progress()
        self.assertTrue(hasattr(iteration_result, "results"))
        self.assertTrue(hasattr(iteration_result, "suggestions"))
        self.assertIsInstance(iteration_result.suggestions, list)

    def test_active_learning_screening_simulation(self):
        campaign_config = ActiveLearningScreeningCampaignConfig(
            name="Example_Simulation_Campaign",
            model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
            embedder_name="one_hot_encoding",
            optimization_mode=ActiveLearningOptimizationMode.VALUE,
            target_value=10.0,
        )

        simulation_data = [
            SequenceData(
                seq_id="Seq1", seq="MMALSLALM", label="5.4", set="train", mask=None
            ),
            SequenceData(
                seq_id="Seq2", seq="PRTEIN", label="1.1", set="train", mask=None
            ),
            SequenceData(seq_id="Seq3", seq="PRT", label="2.2", set="train", mask=None),
            SequenceData(
                seq_id="Seq4", seq="SEQWENCE", label="3.3", set="pred", mask=None
            ),
            SequenceData(seq_id="Seq5", seq="PRTE", label="9.9", set="pred", mask=None),
            SequenceData(
                seq_id="Seq6", seq="MMALSM", label="4.0", set="pred", mask=None
            ),
            SequenceData(
                seq_id="Seq7", seq="PRSEQ", label="0.5", set="pred", mask=None
            ),
        ]

        simulation_config = ActiveLearningScreeningSimulationConfig(
            simulation_data=simulation_data,
            n_start=2,
            n_suggestions_per_iteration=1,
            convergence_config=ActiveLearningConvergenceConfig(
                max_labels_budget=3,
                n_hits=2,
                max_consecutive_failures=2,
            ),
        )

        simulation_results = self.api.al_screening_simulation(
            campaign_config, simulation_config
        ).run_with_progress()
        self.assertTrue(hasattr(simulation_results, "iteration_results"))

    def test_active_learning_engineering_iteration(self):
        wildtype_sequence = "TSSLFPHPRL"
        campaign_config = ActiveLearningEngineeringCampaignConfig(
            name="Example_Campaign",
            model_type=ActiveLearningModelType.FNN_MCD,
            embedder_name="one_hot_encoding",
            optimization_mode=ActiveLearningOptimizationMode.MAXIMIZE,
            seed=44,
            wildtype_sequence=wildtype_sequence,
        )

        iteration_data = [
            SequenceData(seq_id="Mut1", seq="TSSLFPHPRM", label="1.054", set="train"),
        ]

        iteration_config = ActiveLearningEngineeringIterationConfig(
            base_sequences=[wildtype_sequence],
            training_data=iteration_data,
            n_suggestions=10,
            coefficient=0.8,
            iteration=1,
        )

        iteration_result = self.api.al_engineering_iteration(
            campaign_config, iteration_config
        ).run_with_progress()
        self.assertTrue(hasattr(iteration_result, "results"))
        self.assertTrue(hasattr(iteration_result, "suggestions"))
        self.assertIsInstance(iteration_result.suggestions, list)


if __name__ == "__main__":
    unittest.main()
