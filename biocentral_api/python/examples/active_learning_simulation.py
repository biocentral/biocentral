from biocentral_api import BiocentralAPI, SequenceTrainingData, ActiveLearningCampaignConfig, \
    ActiveLearningSimulationConfig, ActiveLearningOptimizationMode, ActiveLearningModelType, \
    ActiveLearningConvergenceConfig

# TODO REMOVE LOCAL ONLY
biocentral_api = BiocentralAPI(local_only=True)

# Create campaign config (for all iterations)
campaign_config = ActiveLearningCampaignConfig(name="Example_Simulation_Campaign",
                                               model_type=ActiveLearningModelType.GAUSSIAN_PROCESS,
                                               embedder_name="one_hot_encoding",
                                               optimization_mode=ActiveLearningOptimizationMode.VALUE,
                                               target_value=10.0
                                               )

# Define simulation data - every sequence must have a label. Labels will be masked during training
simulation_data = [
    SequenceTrainingData(seq_id="Seq1", sequence="MMALSLALM", label="5.4", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq2", sequence="PRTEIN", label="1.1", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq3", sequence="PRT", label="2.2", set="train", mask=None),
    SequenceTrainingData(seq_id="Seq4", sequence="SEQWENCE", label="3.3", set="pred", mask=None),
    SequenceTrainingData(seq_id="Seq5", sequence="PRTE", label="9.9", set="pred", mask=None),
    SequenceTrainingData(seq_id="Seq6", sequence="MMALSM", label="4.0", set="pred", mask=None),
    SequenceTrainingData(seq_id="Seq7", sequence="PRSEQ", label="0.5", set="pred", mask=None),
]

# Define simulation config
simulation_config = ActiveLearningSimulationConfig(simulation_data=simulation_data,
                                                   n_start=1,
                                                   n_suggestions_per_iteration=1, # Will be higher for most campaigns
                                                   convergence_config=ActiveLearningConvergenceConfig(
                                                       max_labels_budget=3,
                                                       target_successes=2,
                                                       max_consecutive_failures=2)
                                                   )
# Run iteration
simulation_results = biocentral_api.al_simulation(campaign_config, simulation_config).run_with_progress()
print(f"Simulation results: {simulation_results}")
