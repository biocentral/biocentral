import 'package:biocentral/plugins/bay_opt/bloc/bayesian_optimization_config_dialog_bloc.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bay_opt/model/bayesian_optimization_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_dialog.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_entity_type_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Dialog Widget
class BayesianOptimizationConfigDialog extends StatefulWidget {
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

  const BayesianOptimizationConfigDialog(
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
  State<BayesianOptimizationConfigDialog> createState() => _BayesianOptimizationConfigDialogState();
}

class _BayesianOptimizationConfigDialogState extends State<BayesianOptimizationConfigDialog> {
  final List<PredefinedEmbedder> _availableEmbedders = PredefinedEmbedderContainer.predefinedEmbedders();
  final List<TaskType> _availableTasks = TaskType.values;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BayesianOptimizationConfigDialogBloc(
        context.read<BiocentralDatabaseRepository>(),
        context.read<BiocentralProjectRepository>(),
        initialTask: widget.initialTask,
        initialFeature: widget.initialFeature,
        initialModel: widget.initialModel,
        initialExploitationExploration: widget.initialExploitationExploration,
        initialEmbedder: widget.initialEmbedder,
        initialOptimizationType: widget.initialOptimizationType,
        initialTargetValue: widget.initialTargetValue,
        initialTargetRangeMin: widget.initialTargetRangeMin,
        initialTargetRangeMax: widget.initialTargetRangeMax,
        initialDesiredBooleanValue: widget.initialDesiredBooleanValue,
      ),
      child: BlocBuilder<BayesianOptimizationConfigDialogBloc, BayesianOptimizationConfigDialogState>(
        builder: (context, state) {
          final bloc = context.read<BayesianOptimizationConfigDialogBloc>();

          return BiocentralDialog(
            children: [
              const Text('Start Training', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),

              // Dataset Selection
              if (state.currentStep.index >= BayesianOptimizationConfigDialogStep.datasetSelection.index)
                buildDatasetSelection(state, bloc),

              // Task and Feature Selection (in the same row)
              if (state.currentStep.index >= BayesianOptimizationConfigDialogStep.taskSelection.index &&
                  state.config.selectedDataset != null)
                buildTaskSelection(state, bloc),

              // Feature Configuration and Optimization Type (full row or split with target range)
              if (state.currentStep.index >= BayesianOptimizationConfigDialogStep.featureConfiguration.index &&
                  state.config.selectedFeature != null)
                buildFeatureConfiguration(state, bloc),

              // Embedder and Model Selection (50/50 split row)
              if (state.currentStep.index >= BayesianOptimizationConfigDialogStep.embedderSelection.index &&
                  state.config.isFeatureConfigurationComplete)
                buildEmbedderAndModelSelection(state, bloc),

              // Exploitation vs. Exploration Selection
              if (state.currentStep.index >=
                      BayesianOptimizationConfigDialogStep.exploitationExplorationSelection.index &&
                  state.config.selectedModel != null)
                buildExploitationVsExplorationSelection(state, bloc),

              // Action Buttons
              const SizedBox(
                height: 16,
              ),
              buildActionButtons(state, bloc),
            ],
          );
        },
      ),
    );
  }

  Widget buildDatasetSelection(BayesianOptimizationConfigDialogState state, BayesianOptimizationConfigDialogBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Dataset:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        BiocentralEntityTypeSelection(
          onChangedCallback: (Type? value) {
            if (value != null) bloc.add(DatasetSelected(value));
          },
          initialValue: state.config.selectedDataset,
        ),
      ],
    );
  }

  Widget buildTaskSelection(BayesianOptimizationConfigDialogState state, BayesianOptimizationConfigDialogBloc bloc) {
    return Column(
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
                    value: state.config.selectedTask,
                    hint: const Text('Choose a task'),
                    isExpanded: true,
                    items: _availableTasks
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
            buildFeatureSelection(state, bloc),
          ],
        ),
      ],
    );
  }

  Widget buildFeatureSelection(BayesianOptimizationConfigDialogState state, BayesianOptimizationConfigDialogBloc bloc) {
    if (state.config.selectedTask != null && state.availableFeatures.isEmpty) {
      return const Text('Could not find any features to optimize, please check your dataset!');
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Feature:', style: TextStyle(fontSize: 16)),
          // TODO Create BiocentralDropdownButton
          DropdownButton<String>(
            value: state.config.selectedFeature,
            hint: const Text('Choose a feature'),
            isExpanded: true,
            items: state.config.selectedTask != null
                ? state.availableFeatures
                    .map((feature) => DropdownMenuItem(value: feature, child: Text(feature)))
                    .toList()
                : [],
            onChanged: state.config.selectedTask != null
                ? (value) {
                    if (value != null) bloc.add(FeatureSelected(value));
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildFeatureConfiguration(
      BayesianOptimizationConfigDialogState state, BayesianOptimizationConfigDialogBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Boolean type configuration
        if (state.config.selectedTask == TaskType.findHighestProbability)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Desired Value:', style: TextStyle(fontSize: 16)),
              DropdownButton<bool>(
                value: state.config.desiredBooleanValue,
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
        if (state.config.selectedTask == TaskType.findOptimalValues)
          (state.config.optimizationType == 'Target Range')
              // Target Range: 1/3 1/3 1/3 layout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Optimization Type (1/3)
                    Expanded(
                      child: buildOptimizationTypeSelection(state, bloc),
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
              : buildOptimizationTypeSelection(state, bloc),

        // Show error for target range if needed
        if (state.config.selectedTask == TaskType.findOptimalValues &&
            state.config.optimizationType == 'Target Range' &&
            state.config.targetRangeMin != null &&
            state.config.targetRangeMax != null &&
            state.config.targetRangeMin! >= state.config.targetRangeMax!)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Min value must be less than Max value',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget buildOptimizationTypeSelection(
      BayesianOptimizationConfigDialogState state, BayesianOptimizationConfigDialogBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Optimization Type:', style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: state.config.optimizationType,
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
    );
  }

  Widget buildEmbedderAndModelSelection(
      BayesianOptimizationConfigDialogState state, BayesianOptimizationConfigDialogBloc bloc) {
    return Column(
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
                    value: state.config.selectedEmbedder,
                    hint: const Text('Choose embedder'),
                    isExpanded: true,
                    items: _availableEmbedders
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
                    value: state.config.selectedModel,
                    hint: const Text('Choose model'),
                    isExpanded: true,
                    items: state.currentStep.index >= BayesianOptimizationConfigDialogStep.modelSelection.index &&
                            state.config.selectedEmbedder != null
                        ? BayesianOptimizationModelTypes.values
                            .map((model) => DropdownMenuItem(value: model, child: Text(model.name)))
                            .toList()
                        : [],
                    onChanged: state.currentStep.index >= BayesianOptimizationConfigDialogStep.modelSelection.index &&
                            state.config.selectedEmbedder != null
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
    );
  }

  Widget buildExploitationVsExplorationSelection(
    BayesianOptimizationConfigDialogState state,
    BayesianOptimizationConfigDialogBloc bloc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Exploitation vs Exploration:', style: TextStyle(fontSize: 16)),
        Slider(
          value: state.config.exploitationExplorationValue ?? 0.5,
          divisions: 10,
          label: (state.config.exploitationExplorationValue ?? 0.5).toStringAsFixed(1),
          onChanged: (value) => bloc.add(ExploitationExplorationUpdated(value)),
        ),
      ],
    );
  }

  Widget buildActionButtons(
    BayesianOptimizationConfigDialogState state,
    BayesianOptimizationConfigDialogBloc bloc,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: state.config.canStartTraining
              ? () {
                  widget._startTraining(
                    state.config.selectedTask,
                    state.config.selectedFeature,
                    state.config.selectedModel,
                    state.config.exploitationExplorationValue!,
                    state.config.selectedEmbedder,
                    optimizationType: state.config.optimizationType,
                    targetValue: state.config.targetValue,
                    targetRangeMin: state.config.targetRangeMin,
                    targetRangeMax: state.config.targetRangeMax,
                    desiredBooleanValue: state.config.desiredBooleanValue,
                  );
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Start'),
        ),
      ],
    );
  }
}
