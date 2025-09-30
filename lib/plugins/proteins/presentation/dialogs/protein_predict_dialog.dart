import 'package:biocentral/plugins/proteins/bloc/protein_predict_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProteinPredictDialog extends StatefulWidget {
  final void Function(Set<String>) onPredict;

  const ProteinPredictDialog({required this.onPredict, super.key});

  @override
  State<ProteinPredictDialog> createState() => _ProteinPredictDialogState();
}

class _ProteinPredictDialogState extends State<ProteinPredictDialog>
    with BiocentralDialogCloseMixin, AutomaticKeepAliveClientMixin {
  final Set<String> _selectedModels = {};

  @override
  void initState() {
    super.initState();
  }

  void onPredict() {
    if (_selectedModels.isNotEmpty) {
      closeDialog(
        callback: () => widget.onPredict(_selectedModels),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ProteinPredictDialogBloc, ProteinPredictDialogState>(
      builder: (context, state) => buildDialog(state),
    );
  }

  Widget buildDialog(ProteinPredictDialogState state) {
    final List<Widget> dialogChildren = [];

    dialogChildren.addAll([
      Text(
        'Predict Protein Properties',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      buildModelSelection(state),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [buildCancelButton(), const Spacer(), buildPredictButton()],
      )
    ]);

    return BiocentralDialog(
      children: dialogChildren,
    );
  }

  Widget buildModelSelection(ProteinPredictDialogState state) {
    if (state.modelMetadata.isEmpty) {
      return Container();
    }
    return Column(
      children: state.modelMetadata.entries
          .map<CheckboxListTile>(
            (entry) => CheckboxListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value['description'] ?? ''),
              value: _selectedModels.contains(entry.key),
              onChanged: (bool? value) {
                value ??= false;
                setState(() {
                  if (value!) {
                    _selectedModels.add(entry.key);
                  } else {
                    _selectedModels.remove(entry.key);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }

  Widget buildPredictButton() {
    return BiocentralSmallButton(
      onTap: _selectedModels.isNotEmpty ? onPredict : null,
      label: 'Predict',
    );
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }

  @override
  bool get wantKeepAlive => true;
}
