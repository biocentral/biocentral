"""
BETA

This API feature is currently in BETA state. Some configurations might not work as expected.
"""
from biocentral_api import BiocentralAPI, SequenceData, ActiveLearningScreeningCampaignConfig, \
    ActiveLearningScreeningIterationConfig, ActiveLearningEngineeringCampaignConfig, \
    ActiveLearningEngineeringIterationConfig, ActiveLearningOptimizationMode, ActiveLearningModelType


def demonstrate_al_screening():
    biocentral_api = BiocentralAPI(local_only=True)

    # Create campaign config (for all iterations)
    campaign_config = ActiveLearningScreeningCampaignConfig(
        name="Example_Screening_Campaign",
        model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
        embedder_name="one_hot_encoding",
        optimization_mode=ActiveLearningOptimizationMode.VALUE,
        target_value=10.0
    )

    # Define initial data
    iteration_data = [
        SequenceData(seq_id="Seq1", seq="MMALSLALM", label="5.4", set="train", mask=None),  # Labeled start data
        SequenceData(seq_id="Seq2", seq="PRTEIN", label="1.1", set="train", mask=None),
        SequenceData(seq_id="Seq3", seq="PRT", label="2.2", set="train", mask=None),
        SequenceData(seq_id="Seq4", seq="SEQWENCE", set="pred", mask=None),  # Unlabeled data
        SequenceData(seq_id="Seq5", seq="PRTE", set="pred", mask=None),
        SequenceData(seq_id="Seq6", seq="MMALSM", set="pred", mask=None),
        SequenceData(seq_id="Seq7", seq="PRSEQ", set="pred", mask=None),
    ]

    # Define iteration config
    iteration_config = ActiveLearningScreeningIterationConfig(
        iteration_data=iteration_data,
        n_suggestions=1,  # Will be higher for most campaigns
        coefficient=0.8,  # High exploration at the start of the campaign
        iteration=1  # Iteration Index
    )

    # Run iteration
    iteration_result = biocentral_api.al_screening_iteration(campaign_config, iteration_config).run_with_progress()
    print(f"Screening iteration results: {iteration_result.results}")
    print(f"Screening suggestions for lab-testing: {iteration_result.suggestions}")


def demonstrate_al_engineering():
    biocentral_api = BiocentralAPI(local_only=True)

    # Define sequence to optimize
    wildtype_sequence = "TSSLFPHPRL"

    # Create campaign config (for all iterations)
    campaign_config = ActiveLearningEngineeringCampaignConfig(
        name="Example_Engineering_Campaign",
        model_type=ActiveLearningModelType.FNN_MCD,
        embedder_name="one_hot_encoding",
        optimization_mode=ActiveLearningOptimizationMode.MAXIMIZE,
        seed=44,
        wildtype_sequence=wildtype_sequence,
    )

    # Define existing training data (if any)
    training_data = [
        SequenceData(seq_id="Mut1", seq="TSSLFPHPRM", label="1.054", set="train"),
    ]

    # Define iteration config
    iteration_config = ActiveLearningEngineeringIterationConfig(
        base_sequences=[wildtype_sequence],
        training_data=training_data,
        n_suggestions=10,
        coefficient=0.8,
        iteration=1,
    )

    # Run iteration
    iteration_result = biocentral_api.al_engineering_iteration(campaign_config, iteration_config).run_with_progress()
    print(f"Engineering iteration results: {iteration_result.results}")
    print(f"Engineering suggestions for lab-testing: {iteration_result.suggestions}")


if __name__ == "__main__":
    print("=" * 50)
    print("Active Learning Screening Example")
    print("=" * 50)
    demonstrate_al_screening()

    print("\n" + "=" * 50)
    print("Active Learning Engineering Example")
    print("=" * 50)
    demonstrate_al_engineering()
