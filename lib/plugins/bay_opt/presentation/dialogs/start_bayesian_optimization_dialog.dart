import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bay_opt/presentation/dialogs/bayesian_optimization_training_dialog_bloc.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_dialog.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_entity_type_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';

// Dialog Widget
class StartBOTrainingDialog extends StatelessWidget {
  final Function(
    TaskType? selectedTask,
    String? selectedFeature,
    BayesianOptimizationModelTypes? selectedModel,
    double exploitationExplorationValue,
    PredefinedEmbedder? selectedEmbedder, {
    String? optimizationType,
    double? targetValue,
    double? targetRangeMin,
    double? targetRangeMax,
    bool? desiredBooleanValue,
  }) _startTraining;

  final TaskType? initialTask;
  final String? initialFeature;
  final BayesianOptimizationModelTypes? initialModel;
  final double initialExploitationExploration;
  final PredefinedEmbedder? initialEmbedder;
  final String? initialOptimizationType;
  final double? initialTargetValue;
  final double? initialTargetRangeMin;
  final double? initialTargetRangeMax;
  final bool? initialDesiredBooleanValue;

  const StartBOTrainingDialog(
    this._startTraining, {
    this.initialTask,
    this.initialFeature,
    this.initialModel,
    this.initialExploitationExploration = 0.5,
    this.initialEmbedder,
    this.initialOptimizationType,
    this.initialTargetValue,
    this.initialTargetRangeMin,
    this.initialTargetRangeMax,
    this.initialDesiredBooleanValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BOTrainingDialogBloc(
        context.read<BiocentralDatabaseRepository>(),
        context.read<BiocentralProjectRepository>(),
        initialTask: initialTask,
        initialFeature: initialFeature,
        initialModel: initialModel,
        initialExploitationExploration: initialExploitationExploration,
        initialEmbedder: initialEmbedder,
        initialOptimizationType: initialOptimizationType,
        initialTargetValue: initialTargetValue,
        initialTargetRangeMin: initialTargetRangeMin,
        initialTargetRangeMax: initialTargetRangeMax,
        initialDesiredBooleanValue: initialDesiredBooleanValue,
      ),
      child: BlocBuilder<BOTrainingDialogBloc, BOTrainingDialogState>(
        builder: (context, state) {
          final bloc = context.read<BOTrainingDialogBloc>();

          // Check if target range is valid (min < max)
          final bool isTargetRangeValid = state.optimizationType != 'Target Range' ||
              (state.targetRangeMin != null &&
                  state.targetRangeMax != null &&
                  state.targetRangeMin! < state.targetRangeMax!);

          // Check if all required fields are filled to enable the start button
          final bool canStartTraining = state.selectedTask != null &&
              state.selectedFeature != null &&
              state.selectedModel != null &&
              state.selectedEmbedder != null &&
              state.isFeatureConfigurationComplete &&
              isTargetRangeValid &&
              state.currentStep.index >= BOTrainingDialogStep.exploitationExplorationSelection.index;

          return BiocentralDialog(
            children: [
              const Text('Start Training', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),

              // Dataset Selection
              if (state.currentStep.index >= BOTrainingDialogStep.datasetSelection.index)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Dataset:', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    BiocentralEntityTypeSelection(
                      onChangedCallback: (Type? value) {
                        if (value != null) bloc.add(DatasetSelected(value));
                      },
                      initialValue: state.selectedDataset,
                    ),
                  ],
                ),

              // Task and Feature Selection (in the same row)
              if (state.currentStep.index >= BOTrainingDialogStep.taskSelection.index && state.selectedDataset != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Selection
                        Expanded(
                          flex: 2, // Takes up 2/3 of the row
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Task:', style: TextStyle(fontSize: 16)),
                              DropdownButton<TaskType>(
                                value: state.selectedTask,
                                hint: const Text('Choose a task'),
                                isExpanded: true,
                                items: state.tasks
                                    .map((task) => DropdownMenuItem(value: task, child: Text(task.displayName)))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) bloc.add(TaskSelected(value));
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Feature Selection
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Feature:', style: TextStyle(fontSize: 16)),
                              DropdownButton<String>(
                                value: state.selectedFeature,
                                hint: const Text('Choose a feature'),
                                isExpanded: true,
                                items: state.currentStep.index >= BOTrainingDialogStep.featureSelection.index &&
                                        state.selectedTask != null
                                    ? state.availableFeatures
                                        .map((feature) => DropdownMenuItem(value: feature, child: Text(feature)))
                                        .toList()
                                    : [],
                                onChanged: state.currentStep.index >= BOTrainingDialogStep.featureSelection.index &&
                                        state.selectedTask != null
                                    ? (value) {
                                        if (value != null) bloc.add(FeatureSelected(value));
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              // Feature Configuration and Optimization Type (full row or split with target range)
              if (state.currentStep.index >= BOTrainingDialogStep.featureConfiguration.index &&
                  state.selectedFeature != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Boolean type configuration
                    if (state.selectedTask == TaskType.findHighestProbability)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Desired Value:', style: TextStyle(fontSize: 16)),
                          DropdownButton<bool>(
                            value: state.desiredBooleanValue,
                            hint: const Text('Choose desired value'),
                            items: [
                              const DropdownMenuItem(value: true, child: Text('True')),
                              const DropdownMenuItem(value: false, child: Text('False')),
                            ],
                            onChanged: (value) {
                              if (value != null) bloc.add(DesiredBooleanValueUpdated(value));
                            },
                          ),
                        ],
                      ),

                    // Optimization Type for findOptimalValues
                    if (state.selectedTask == TaskType.findOptimalValues)
                      (state.optimizationType == 'Target Range')
                          // Target Range: 1/3 1/3 1/3 layout
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Optimization Type (1/3)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Optimization Type:', style: TextStyle(fontSize: 16)),
                                      DropdownButton<String>(
                                        value: state.optimizationType,
                                        hint: const Text('Choose type'),
                                        isExpanded: true,
                                        items: ['Maximize', 'Minimize', 'Target Range']
                                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) bloc.add(OptimizationTypeSelected(value));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Min Value (1/3)
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(labelText: 'Min'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final number = double.tryParse(value);
                                      if (number != null) {
                                        bloc.add(TargetRangeMinUpdated(number));
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Max Value (1/3)
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(labelText: 'Max'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final number = double.tryParse(value);
                                      if (number != null) {
                                        bloc.add(TargetRangeMaxUpdated(number));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          // Full-width Optimization Type
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Optimization Type:', style: TextStyle(fontSize: 16)),
                                DropdownButton<String>(
                                  value: state.optimizationType,
                                  hint: const Text('Choose type'),
                                  isExpanded: true,
                                  items: ['Maximize', 'Minimize', 'Target Range']
                                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) bloc.add(OptimizationTypeSelected(value));
                                  },
                                ),
                              ],
                            ),

                    // Show error for target range if needed
                    if (state.selectedTask == TaskType.findOptimalValues &&
                        state.optimizationType == 'Target Range' &&
                        state.targetRangeMin != null &&
                        state.targetRangeMax != null &&
                        state.targetRangeMin! >= state.targetRangeMax!)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Min value must be less than Max value',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),

              // Embedder and Model Selection (50/50 split row)
              if (state.currentStep.index >= BOTrainingDialogStep.embedderSelection.index &&
                  state.isFeatureConfigurationComplete)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Embedder Selection (1/2)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Embedder:', style: TextStyle(fontSize: 16)),
                              DropdownButton<PredefinedEmbedder>(
                                value: state.selectedEmbedder,
                                hint: const Text('Choose embedder'),
                                isExpanded: true,
                                items: state.availableEmbedders
                                    .map(
                                      (embedder) => DropdownMenuItem(
                                        value: embedder,
                                        child: Text(embedder.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) bloc.add(EmbedderSelected(value));
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Model Selection (1/2)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Model:', style: TextStyle(fontSize: 16)),
                              DropdownButton<BayesianOptimizationModelTypes>(
                                value: state.selectedModel,
                                hint: const Text('Choose model'),
                                isExpanded: true,
                                items: state.currentStep.index >= BOTrainingDialogStep.modelSelection.index &&
                                        state.selectedEmbedder != null
                                    ? BayesianOptimizationModelTypes.values
                                        .map((model) => DropdownMenuItem(value: model, child: Text(model.name)))
                                        .toList()
                                    : [],
                                onChanged: state.currentStep.index >= BOTrainingDialogStep.modelSelection.index &&
                                        state.selectedEmbedder != null
                                    ? (value) {
                                        if (value != null) bloc.add(ModelSelected(value));
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              // Exploitation vs. Exploration Selection
              if (state.currentStep.index >= BOTrainingDialogStep.exploitationExplorationSelection.index &&
                  state.selectedModel != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Exploitation vs Exploration:', style: TextStyle(fontSize: 16)),
                    Slider(
                      value: state.exploitationExplorationValue,
                      divisions: 10,
                      label: state.exploitationExplorationValue.toStringAsFixed(1),
                      onChanged: (value) => bloc.add(ExploitationExplorationUpdated(value)),
                    ),
                  ],
                ),

              // Action Buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: canStartTraining
                        ? () {
                            _startTraining(
                              state.selectedTask,
                              state.selectedFeature,
                              state.selectedModel,
                              state.exploitationExplorationValue,
                              state.selectedEmbedder,
                              optimizationType: state.optimizationType,
                              targetValue: state.targetValue,
                              targetRangeMin: state.targetRangeMin,
                              targetRangeMax: state.targetRangeMax,
                              desiredBooleanValue: state.desiredBooleanValue,
                            );
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: const Text('Start'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
