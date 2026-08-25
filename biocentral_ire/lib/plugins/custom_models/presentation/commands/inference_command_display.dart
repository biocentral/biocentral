import 'package:biocentral/plugins/custom_models/bloc/model_hub_bloc.dart';
import 'package:biocentral/plugins/custom_models/bloc/models_commands.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InferenceCommandDisplay extends StatefulWidget {
  const InferenceCommandDisplay({super.key});

  @override
  State<InferenceCommandDisplay> createState() => _InferenceCommandDisplayState();
}

class _InferenceCommandDisplayState extends State<InferenceCommandDisplay> {
  PredictionModel? _selectedModel;
  String? _predictionColumnName;

  final Set<String> _availableEntityIDs = {};
  final Set<String> _selectedEntityIDs = {};

  InferenceCommand? collectCommand() {
    if (_selectedModel != null && _predictionColumnName != null && _selectedEntityIDs.isNotEmpty) {
      return InferenceCommand(
        biocentralDatabase: context.read<ProteinRepository>(),
        apiRepository: context.read(),
        predictionColumnName: _predictionColumnName!,
        predictionModel: _selectedModel!,
        selectedEntityIDs: _selectedEntityIDs,
      );
    }
    return null;
  }

  void _changeModelSelection(PredictionModel? selectedModel) {
    _selectedModel = selectedModel;
    if (selectedModel == null) {
      _availableEntityIDs.clear();
      _selectedEntityIDs.clear();
      _predictionColumnName = null;
      return;
    }
    final databaseRepository = context.read<BiocentralDatabaseRepository>();
    final databaseType = databaseRepository.getAvailableTypes()[selectedModel.databaseType];
    final database = databaseRepository.getFromType(databaseType);
    if (database == null) {
      // TODO Error Handling
      return;
    }

    final availableEntityIDs = database.databaseToMap().keys.toSet();
    _availableEntityIDs.clear();
    _availableEntityIDs.addAll(availableEntityIDs);
    _selectedEntityIDs.clear();
    _selectedEntityIDs.addAll(availableEntityIDs); // Select all ids initially
    _predictionColumnName ??= 'Prediction-${_selectedModel?.modelHash ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final BiocentralAPIRepository apiRepository = context.read();

    return StreamBuilder(
      initialData: apiRepository.currentHealth,
      stream: apiRepository.healthStatusStream,
      builder: (context, asyncSnapshot) {
        final currentHealth = asyncSnapshot.data ?? [];
        final availability = BiocentralCommandAvailability.fromHealth(currentHealth);
        return BiocentralCommandWidget(
          icon: const Icon(Icons.online_prediction),
          name: 'Create predictions from your trained models',
          description: 'Use an existing model to get predictions for your dataset',
          executeButtonLabel: 'Inference',
          parameterSelection: buildParameterSelection,
          collectCommand: collectCommand,
          visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
          commandAvailability: availability,
        );
      },
    );
  }

  Widget buildParameterSelection() {
    return BlocBuilder<ModelHubBloc, ModelHubState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              withCondition(condition: true, childFunction: () => buildModelSelection(state.predictionModels.toSet())),
              withCondition(
                condition: _selectedModel != null,
                childFunction: () => buildPredictionColumnNameSelection(),
              ),
              withCondition(condition: _selectedModel != null, childFunction: () => buildEntityIDSelection()),
            ].withPadding(
              const Padding(
                padding: EdgeInsetsGeometry.all(8.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildModelSelection(Set<PredictionModel> availableModels) {
    if (availableModels.isEmpty) {
      return const Text('No models available!');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        BiocentralDiscreteSelection<PredictionModel>(
          title: 'Select the model',
          initialValue: _selectedModel,
          selectableValues: availableModels.toList(),
          displayConversion: (model) => model.getReadableModelID(),
          onChangedCallback: (PredictionModel? selected) {
            setState(() {
              _changeModelSelection(selected);
            });
          },
        ),
      ],
    );
  }

  Widget buildPredictionColumnNameSelection() {
    return TextFormField(
      initialValue: _predictionColumnName,
      decoration: const InputDecoration(labelText: 'Column Name'),
      textAlign: TextAlign.center,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (val) => val == null || val.isEmpty ? 'Column name must not be empty!' : null,
      onChanged: (val) {
        setState(() {
          _predictionColumnName = val;
        });
      },
    );
  }

  Widget buildEntityIDSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text('Select for which ids you want to create predictions:')),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  if (_selectedEntityIDs.length == _availableEntityIDs.length) {
                    _selectedEntityIDs.clear();
                  } else {
                    _selectedEntityIDs.addAll(_availableEntityIDs);
                  }
                });
              },
              icon: const Icon(Icons.select_all),
              label: Text(_selectedEntityIDs.length == _availableEntityIDs.length
                  ? 'Deselect All'
                  : 'Select All'),
            ),
            const SizedBox(width: 8),
            Text('${_selectedEntityIDs.length} / ${_availableEntityIDs.length} selected'),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: _availableEntityIDs.length,
            itemBuilder: (context, index) {
              final id = _availableEntityIDs.toList()[index];
              final isSelected = _selectedEntityIDs.contains(id);
              return ListTile(
                dense: true,
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedEntityIDs.add(id);
                      } else {
                        _selectedEntityIDs.remove(id);
                      }
                    });
                  },
                ),
                title: Text(id),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedEntityIDs.remove(id);
                    } else {
                      _selectedEntityIDs.add(id);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
