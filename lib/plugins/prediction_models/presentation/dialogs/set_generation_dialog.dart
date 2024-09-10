import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/set_generation_dialog_bloc.dart';
import '../../model/set_generator.dart';

class SetGenerationDialog extends StatefulWidget {
  final Type? initialSelectedType;

  const SetGenerationDialog({super.key, this.initialSelectedType});

  @override
  State<SetGenerationDialog> createState() => _SetGenerationDialogState();
}

class _SetGenerationDialogState extends State<SetGenerationDialog> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedType != null) {
      SetGenerationDialogBloc setGenerationDialogBloc = BlocProvider.of<SetGenerationDialogBloc>(context);
      setGenerationDialogBloc.add(SetGenerationDialogSelectDatabaseTypeEvent(widget.initialSelectedType!));
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<SetGenerationDialogBloc, SetGenerationDialogState>(
      listener: (context, state) {
        if (state.isFinished()) {
          closeDialog();
        }
      },
      builder: (context, state) => buildDialog(state),
    );
  }

  Widget buildDialog(SetGenerationDialogState state) {
    SetGenerationDialogBloc setGenerationDialogBloc = BlocProvider.of<SetGenerationDialogBloc>(context);
    List<Widget> dialogChildren = [];

    dialogChildren.addAll([
      Text(
        "Generate sets for model training",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      ...buildConfigSelectionByState(setGenerationDialogBloc, state)
    ]);

    return BiocentralDialog(
      small: false, // TODO Small Dialog not working yet
      children: dialogChildren,
    );
  }

  List<Widget> buildConfigSelectionByState(
      SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    List<Widget> widgetsForCurrentState = [];
    List<Widget> bottomRowButtons = [];
    SetGenerationDialogStep step = state.currentStep;
    for (int statusIndex = 0; statusIndex <= SetGenerationDialogStep.values.indexOf(step); statusIndex++) {
      switch (SetGenerationDialogStep.values.elementAt(statusIndex)) {
        case SetGenerationDialogStep.initial:
          widgetsForCurrentState.add(buildSelectDatabaseType(setGenerationDialogBloc, state));
          break;
        case SetGenerationDialogStep.selectedDatabaseType:
          break;
        case SetGenerationDialogStep.loadedMethods:
          widgetsForCurrentState.add(buildMethodSelection(setGenerationDialogBloc, state));
          break;
        case SetGenerationDialogStep.selectedMethod:
          bottomRowButtons.add(buildCalculateButton(setGenerationDialogBloc));
          break;
      }
    }
    bottomRowButtons.add(buildCancelButton());
    widgetsForCurrentState.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: bottomRowButtons));
    return widgetsForCurrentState;
  }

  Widget buildSelectDatabaseType(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    return Flexible(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("1. Do you want to generate a set for proteins or protein-protein interactions?"),
          BiocentralEntityTypeSelection(
              initialValue: state.selectedDatabaseType,
              onChangedCallback: (Type? selected) {
                if (selected != null) {
                  setGenerationDialogBloc.add(SetGenerationDialogSelectDatabaseTypeEvent(selected));
                }
              }),
        ],
      ),
    );
  }

  Widget buildMethodSelection(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    return Flexible(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("2. Which kind of set generation method should be applied?"),
          Row(
            children: [
              Expanded(
                child: BiocentralDropdownMenu<SplitSetGenerationMethod>(
                  label: const Text("Method.."),
                  dropdownMenuEntries: state.availableMethods
                      .map((SplitSetGenerationMethod method) =>
                          DropdownMenuEntry<SplitSetGenerationMethod>(value: method, label: method.name))
                      .toList(),
                  onSelected: (SplitSetGenerationMethod? value) =>
                      setGenerationDialogBloc.add(SetGenerationDialogSelectMethodEvent(value)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCalculateButton(SetGenerationDialogBloc setGenerationDialogBloc) {
    return BiocentralSmallButton(
        onTap: () => setGenerationDialogBloc.add(SetGenerationDialogCalculateEvent()), label: "Calculate");
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: "Close");
  }

  @override
  bool get wantKeepAlive => true;
}
