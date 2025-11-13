import 'package:biocentral/plugins/custom_models/bloc/inference_dialog_bloc.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_config_dialog.dart';
import 'package:flutter/material.dart';

class InferenceDialogBuilder extends BiocentralConfigDialogBuilder<InferenceDialogBloc, InferenceDialogState> {
  final void Function(PredictionModel, Set<String>) onStartInference;

  InferenceDialogBuilder({required this.onStartInference});

  @override
  String title() {
    return 'Create predictions from trained model';
  }

  @override
  List<BiocentralConfigDialogStep<InferenceDialogBloc, InferenceDialogState>> steps() => [
        BiocentralConfigDialogStep(
          shouldShow: (state) => true, // Always show first step
          builder: (bloc, state) => buildModelSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.selectedModel != null,
          builder: (bloc, state) => buildEntityIDSelection(bloc, state),
        ),
      ];

  static Widget buildModelSelection(InferenceDialogBloc inferenceDialogBloc, InferenceDialogState state) {
    if (state.availableModels.isEmpty) {
      return const Text('No models available!');
    }
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          BiocentralDiscreteSelection<PredictionModel>(
            title: 'Select the model for which you want to create predictions',
            initialValue: state.selectedModel,
            selectableValues: state.availableModels.toList(),
            displayConversion: (model) => model.getReadableModelID(),
            onChangedCallback: (PredictionModel? selected) {
              if (selected != null) {
                inferenceDialogBloc.add(InferenceDialogSelectModelEvent(selected));
              }
            },
          ),
        ],
      ),
    );
  }

  static Widget buildEntityIDSelection(InferenceDialogBloc inferenceDialogBloc, InferenceDialogState state) {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select for which ids you want to create predictions:'),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CheckboxListTile(
                title: const Text('Select all'),
                value: state.selectedEntityIDs.length == state.availableEntityIDs.length,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  value ??= false;
                  if (value) {
                    inferenceDialogBloc.add(InferenceDialogSelectEntitiesEvent(Set.from(state.availableEntityIDs)));
                  } else {
                    inferenceDialogBloc.add(InferenceDialogSelectEntitiesEvent({}));
                  }
                },
              ),
            ),
            ...state.availableEntityIDs.map(
              (id) => CheckboxListTile(
                title: Text(id),
                value: state.selectedEntityIDs.contains(id),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  value ??= false;
                  if (value) {
                    inferenceDialogBloc
                        .add(InferenceDialogSelectEntitiesEvent(Set.from(state.selectedEntityIDs)..add(id)));
                  } else {
                    inferenceDialogBloc
                        .add(InferenceDialogSelectEntitiesEvent(Set.from(state.selectedEntityIDs)..remove(id)));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildRunButton(
      InferenceDialogBloc bloc, InferenceDialogState state, void Function({Function()? callback}) closeDialog) {
    if (state.selectedModel != null && state.selectedEntityIDs.isNotEmpty) {
      return BiocentralSmallButton(
        onTap: () => closeDialog(callback: () => onStartInference(state.selectedModel!, state.selectedEntityIDs)),
        label: 'Calculate',
      );
    }
    return Container();
  }
}
