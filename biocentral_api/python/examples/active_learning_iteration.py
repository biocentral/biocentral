"""
BETA

This API feature is currently in BETA state. Some configurations might not work as expected.
"""
from biocentral_api import BiocentralAPI, SequenceTrainingData, ActiveLearningCampaignConfig, \
    ActiveLearningIterationConfig, ActiveLearningOptimizationMode, ActiveLearningModelType

# TODO REMOVE LOCAL ONLY
biocentral_api = BiocentralAPI(local_only=True)

# Create campaign config (for all iterations)
campaign_config = ActiveLearningCampaignConfig(name="Example_Campaign",
                                               model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
                                               embedder_name="one_hot_encoding",
                                               optimization_mode=ActiveLearningOptimizationMode.VALUE,
                                               target_value=10.0
                                               )

# Define initial data
iteration_data = [
    SequenceTrainingData(seq_id="Seq1", sequence="MMALSLALM", label="5.4", set="train", mask=None), # Labeled start data
    SequenceTrainingData(seq_id="Seq2", sequence="PRTEIN", label="1.1", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq3", sequence="PRT", label="2.2", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq4", sequence="SEQWENCE", set="pred", mask=None), # Unlabeled data
    SequenceTrainingData(seq_id="Seq5", sequence="PRTE", set="pred", mask=None),
    SequenceTrainingData(seq_id="Seq6", sequence="MMALSM", set="pred", mask=None),
    SequenceTrainingData(seq_id="Seq7", sequence="PRSEQ", set="pred", mask=None),
]

# Define iteration config
iteration_config = ActiveLearningIterationConfig(iteration_data=iteration_data,
                                                 n_suggestions=1,  # Will be higher for most campaigns
                                                 coefficient=0.8,  # High exploration at the start of the campaign
                                                 iteration=1  # Iteration Index
                                                 )

# Run iteration
iteration_result = biocentral_api.al_iteration(campaign_config, iteration_config).run_with_progress()
print(f"Iteration results: {iteration_result.results}")
print(f"Suggestions for lab-testing: {iteration_result.suggestions}")
