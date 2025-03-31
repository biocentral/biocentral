import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/bayesian_optimization_training_dialog_bloc.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_dialog.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_entity_type_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../embeddings/data/predefined_embedders.dart';

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

  const StartBOTrainingDialog(this._startTraining, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BOTrainingDialogBloc(
        context.read<BiocentralDatabaseRepository>(),
        context.read<BiocentralProjectRepository>(),
      ),
      child: BlocBuilder<BOTrainingDialogBloc, BOTrainingDialogState>(
        builder: (context, state) {
          final bloc = context.read<BOTrainingDialogBloc>();

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

              // Task Selection
              if (state.currentStep.index >= BOTrainingDialogStep.taskSelection.index && state.selectedDataset != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Select Task:', style: TextStyle(fontSize: 16)),
                    DropdownButton<TaskType>(
                      value: state.selectedTask,
                      hint: const Text('Choose a task'),
                      items: state.tasks
                          .map((task) => DropdownMenuItem(value: task, child: Text(task.displayName)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) bloc.add(TaskSelected(value));
                      },
                    ),
                  ],
                ),

              // Feature Selection
              if (state.currentStep.index >= BOTrainingDialogStep.featureSelection.index && state.selectedTask != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Select Feature:', style: TextStyle(fontSize: 16)),
                    DropdownButton<String>(
                      value: state.selectedFeature,
                      hint: const Text('Choose a feature'),
                      items: state.availableFeatures
                          .map((feature) => DropdownMenuItem(value: feature, child: Text(feature)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) bloc.add(FeatureSelected(value));
                      },
                    ),
                  ],
                ),

              // Feature Configuration
              if (state.currentStep.index >= BOTrainingDialogStep.featureConfiguration.index &&
                  state.selectedFeature != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (state.selectedTask == TaskType.findOptimalValues)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Optimization Type:', style: TextStyle(fontSize: 16)),
                          DropdownButton<String>(
                            value: state.optimizationType,
                            hint: const Text('Choose optimization type'),
                            items: ['Maximize', 'Minimize', 'Target Value', 'Target Range']
                                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) bloc.add(OptimizationTypeSelected(value));
                            },
                          ),
                          if (state.optimizationType == 'Target Value')
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Target Value'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final number = double.tryParse(value);
                                if (number != null) {
                                  bloc.add(TargetValueUpdated(number));
                                }
                              },
                            ),
                          if (state.optimizationType == 'Target Range')
                            Row(
                              children: [
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
                            ),
                        ],
                      )
                    else if (state.selectedTask == TaskType.findHighestProbability)
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
                  ],
                ),

              // Embedder Selection
              if (state.currentStep.index >= BOTrainingDialogStep.embedderSelection.index &&
                  state.isFeatureConfigurationComplete)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Select Embedder:', style: TextStyle(fontSize: 16)),
                    DropdownButton<PredefinedEmbedder>(
                      value: state.selectedEmbedder,
                      hint: const Text('Choose an embedder'),
                      items: state.availableEmbedders
                          .map((embedder) => DropdownMenuItem(
                                value: embedder,
                                child: Text(embedder.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) bloc.add(EmbedderSelected(value));
                      },
                    ),
                  ],
                ),

              // Model Selection
              if (state.currentStep.index >= BOTrainingDialogStep.modelSelection.index &&
                  state.selectedEmbedder != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Select Model:', style: TextStyle(fontSize: 16)),
                    DropdownButton<BayesianOptimizationModelTypes>(
                      value: state.selectedModel,
                      hint: const Text('Choose a model'),
                      items: BayesianOptimizationModelTypes.values
                          .map((model) => DropdownMenuItem(value: model, child: Text(model.name)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) bloc.add(ModelSelected(value));
                      },
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
                      min: 0,
                      max: 1,
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
                    onPressed: state.currentStep == BOTrainingDialogStep.complete
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
