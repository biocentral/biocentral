import 'package:biocentral/plugins/bay_opt/bloc/bay_opt_config_dialog_bloc.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_config.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_model_types.dart';
import 'package:biocentral/plugins/bay_opt/model/bay_opt_task.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_config_dialog.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_entity_type_selection.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_small_button.dart';
import 'package:flutter/material.dart';

class BayOptConfigDialogBuilder extends BiocentralConfigDialogBuilder<BayOptConfigDialogBloc, BayOptConfigDialogState> {
  static final List<PredefinedEmbedder> _availableEmbedders = PredefinedEmbedderContainer.predefinedEmbedders();
  static final List<BayOptTaskType> _availableTasks = BayOptTaskType.values;

  final void Function(BayOptConfig config) onStartTraining;

  BayOptConfigDialogBuilder(this.onStartTraining);

  @override
  String title() {
    return 'Start New Bayesian Optimization Iteration Cycle';
  }

  @override
  List<BiocentralConfigDialogStep<BayOptConfigDialogBloc, BayOptConfigDialogState>> steps() => [
        BiocentralConfigDialogStep(
          shouldShow: (state) => true, // Always show first step
          builder: (bloc, state) => buildDatasetSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.config.selectedDatasetType != null,
          builder: (bloc, state) => buildTaskSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.config.selectedFeature != null,
          builder: (bloc, state) => buildFeatureConfiguration(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.config.isFeatureConfigurationComplete,
          builder: (bloc, state) => buildEmbedderAndModelSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.config.selectedModel != null,
          builder: (bloc, state) => buildExploitationVsExplorationSelection(bloc, state),
        ),
      ];

  static Widget buildDatasetSelection(BayOptConfigDialogBloc bloc, BayOptConfigDialogState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Dataset:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        BiocentralEntityTypeSelection(
          onChangedCallback: (Type? value) {
            if (value != null) bloc.add(BayOptTrainingDialogDatasetTypeSelectedEvent(value.toString()));
          },
        ),
      ],
    );
  }

  static Widget buildTaskSelection(BayOptConfigDialogBloc bloc, BayOptConfigDialogState state) {
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
                  DropdownButton<BayOptTaskType>(
                    value: state.config.selectedTask,
                    hint: const Text('Choose a task'),
                    isExpanded: true,
                    items: _availableTasks
                        .map((task) => DropdownMenuItem(value: task, child: Text(task.displayName)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) bloc.add(BayOptTrainingDialogTaskSelectedEvent(value));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Feature Selection
            buildFeatureSelection(bloc, state),
          ],
        ),
      ],
    );
  }

  static Widget buildFeatureSelection(BayOptConfigDialogBloc bloc, BayOptConfigDialogState state) {
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
                    if (value != null) {
                      bloc.add(BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(selectedFeature: value)));
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  static Widget buildFeatureConfiguration(BayOptConfigDialogBloc bloc, BayOptConfigDialogState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Boolean type configuration
        if (state.config.selectedTask == BayOptTaskType.findHighestProbability)
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
                  if (value != null) {
                    bloc.add(BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(desiredBooleanValue: value)));
                  }
                },
              ),
            ],
          ),

        // Optimization Type for findOptimalValues
        if (state.config.selectedTask == BayOptTaskType.findOptimalValues)
          (state.config.optimizationType == 'Target Range')
              // Target Range: 1/3 1/3 1/3 layout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Optimization Type (1/3)
                    Expanded(
                      child: buildOptimizationTypeSelection(bloc, state),
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
                            bloc.add(
                                BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(targetRangeMin: number)),);
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
                            bloc.add(
                                BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(targetRangeMax: number)),);
                          }
                        },
                      ),
                    ),
                  ],
                )
              // Full-width Optimization Type
              : buildOptimizationTypeSelection(bloc, state),

        // Show error for target range if needed
        if (state.config.selectedTask == BayOptTaskType.findOptimalValues &&
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

  static Widget buildOptimizationTypeSelection(BayOptConfigDialogBloc bloc, BayOptConfigDialogState state) {
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
            if (value != null) {
              bloc.add(BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(optimizationType: value)));
            }
          },
        ),
      ],
    );
  }

  static Widget buildEmbedderAndModelSelection(BayOptConfigDialogBloc bloc, BayOptConfigDialogState state) {
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
                      if (value != null) {
                        bloc.add(
                            BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(selectedEmbedder: value)),);
                      }
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
                  DropdownButton<BayOptModelTypes>(
                    value: state.config.selectedModel,
                    hint: const Text('Choose model'),
                    isExpanded: true,
                    items: BayOptModelTypes.values
                        .map((model) => DropdownMenuItem(value: model, child: Text(model.name)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        bloc.add(BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(selectedModel: value)));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildExploitationVsExplorationSelection(
    BayOptConfigDialogBloc bloc,
    BayOptConfigDialogState state,
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
          onChanged: (value) => bloc
              .add(BayOptTrainingDialogConfigUpdatedEvent(state.config.copyWith(exploitationExplorationValue: value))),
        ),
      ],
    );
  }

  @override
  Widget buildRunButton(
      BayOptConfigDialogBloc bloc, BayOptConfigDialogState state, void Function({Function()? callback}) closeDialog,) {
    if (state.config.canStartTraining) {
      return BiocentralSmallButton(
        onTap: state.config.canStartTraining
            ? () => closeDialog(callback: () => onStartTraining(state.config))
            : null,
        label: 'Start',
      );
    }
    return Container();
  }
}
