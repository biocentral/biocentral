import 'package:biocentral/plugins/proteins/model/analyze_example_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

class ProteinColumnWizardDialog extends ColumnWizardDialog {
  const ProteinColumnWizardDialog({required super.onApplyColumn, required super.initialSelectedColumn});

  @override
  ColumnWizardDialogState createState() => _ProteinColumnWizardDialogState();
}

class _ProteinColumnWizardDialogState extends ColumnWizardDialogState with TutorialRegistrationMixin {
  @override
  void initState() {
    super.initState();
    registerForTutorials([AnalyzeExampleDatasetTutorial]);
  }
}

extension TutorialExtColumnWizardDialog on ProteinColumnWizardDialog {
  BuildContext? getDialogContext(dynamic state) => state is _ProteinColumnWizardDialogState ? state.context : null;

  GlobalKey? getColumnSelectionKey(dynamic state) =>
      state is _ProteinColumnWizardDialogState ? state.columnSelectionKey : null;

  GlobalKey? getOperationSelectionKey(dynamic state) =>
      state is _ProteinColumnWizardDialogState ? state.operationSelectionKey : null;

  GlobalKey? getCalculateButtonKey(dynamic state) =>
      state is _ProteinColumnWizardDialogState ? state.calculateButtonKey : null;

  ColumnWizardBloc? getColumnWizardBloc(dynamic state) =>
      state is _ProteinColumnWizardDialogState ? BlocProvider.of<ColumnWizardBloc>(state.context) : null;
}
