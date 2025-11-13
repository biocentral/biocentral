import 'package:biocentral/plugins/custom_models/bloc/set_generation_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/model/split_set.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_config_dialog.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_ratio_slider.dart';
import 'package:flutter/material.dart';

class SetGenerationDialogBuilder
    extends BiocentralConfigDialogBuilder<SetGenerationDialogBloc, SetGenerationDialogState> {
  @override
  String title() {
    return 'Generate sets for model training';
  }

  @override
  List<BiocentralConfigDialogStep<SetGenerationDialogBloc, SetGenerationDialogState>> steps() => [
        BiocentralConfigDialogStep(
          shouldShow: (state) => true, // Always show first step
          builder: (bloc, state) => buildDatasetSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.selectedDatabaseType != null,
          builder: (bloc, state) => buildModeSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) =>
              state.mode == SplitSetGenerationMode.subsplitExisting && state.availableSourceSets.isNotEmpty,
          builder: (bloc, state) => buildExistingSetSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) =>
              state.mode == SplitSetGenerationMode.subsplitExisting && state.selectedSetColumn != null,
          builder: (bloc, state) => buildSourceSetSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) =>
              state.mode == SplitSetGenerationMode.subsplitExisting &&
              state.selectedSetColumn != null &&
              state.subsplitSource != null,
          builder: (bloc, state) => buildNewSetNameSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.mode == SplitSetGenerationMode.generateNew || state.subsplitTarget != null,
          builder: (bloc, state) => buildMethodSelection(bloc, state),
        ),
        BiocentralConfigDialogStep(
          shouldShow: (state) => state.method != null,
          builder: (bloc, state) => buildRatioSlider(bloc, state),
        ),
      ];

  static Widget buildDatasetSelection(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Do you want to generate a set for proteins or protein-protein interactions?'),
          BiocentralEntityTypeSelection(
            initialValue: state.selectedDatabaseType,
            onChangedCallback: (Type? selected) {
              setGenerationDialogBloc
                  .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(selectedDatabaseType: selected)));
            },
          ),
        ],
      ),
    );
  }

  static Widget buildModeSelection(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Do you want to create new splits or subsplit an existing set?'),
          Row(
            children: [
              Expanded(
                child: BiocentralDropdownMenu<SplitSetGenerationMode>(
                  label: const Text('Mode..'),
                  initialSelection: state.mode,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry<SplitSetGenerationMode>(
                      value: SplitSetGenerationMode.generateNew,
                      label: 'Create new splits',
                    ),
                    DropdownMenuEntry<SplitSetGenerationMode>(
                      value: SplitSetGenerationMode.subsplitExisting,
                      label: 'Subsplit existing set',
                      enabled: state.availableSourceSets.isNotEmpty,
                    ),
                  ],
                  onSelected: (SplitSetGenerationMode? value) {
                    setGenerationDialogBloc.add(SetGenerationDialogUpdateEvent(SetGenerationSTO(mode: value)));
                  },
                ),
              ),
            ],
          ),
          if (state.mode == SplitSetGenerationMode.subsplitExisting && state.availableSourceSets.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'No existing set columns found in the database.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildExistingSetSelection(
    SetGenerationDialogBloc setGenerationDialogBloc,
    SetGenerationDialogState state,
  ) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select the existing set column to subsplit:'),
          Row(
            children: [
              Expanded(
                child: BiocentralDropdownMenu<BiocentralDatabaseColumn>(
                  label: const Text('Existing set column..'),
                  dropdownMenuEntries: state.availableSourceSets.keys
                      .map(
                        (BiocentralDatabaseColumn column) =>
                            DropdownMenuEntry<BiocentralDatabaseColumn>(value: column, label: column.name),
                      )
                      .toList(),
                  onSelected: (BiocentralDatabaseColumn? value) {
                    setGenerationDialogBloc
                        .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(selectedSetColumn: value)));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildSourceSetSelection(
    SetGenerationDialogBloc setGenerationDialogBloc,
    SetGenerationDialogState state,
  ) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select which set to split:'),
          Row(
            children: [
              Expanded(
                child: BiocentralDropdownMenu<SplitSet>(
                  label: const Text('Source set..'),
                  dropdownMenuEntries: state.availableSplitSetsForSelection
                      .map((SplitSet set) => DropdownMenuEntry<SplitSet>(value: set, label: set.name))
                      .toList(),
                  onSelected: (SplitSet? value) {
                    setGenerationDialogBloc
                        .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(subsplitSource: value)));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildNewSetNameSelection(
    SetGenerationDialogBloc setGenerationDialogBloc,
    SetGenerationDialogState state,
  ) {
    final List<SplitSet> availableNames = SplitSet.values.where((set) => set != state.subsplitSource).toList();

    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select the name for the new subsplit:'),
          Row(
            children: [
              Expanded(
                child: BiocentralDropdownMenu<SplitSet>(
                  label: const Text('New set name..'),
                  dropdownMenuEntries: availableNames
                      .map((SplitSet set) => DropdownMenuEntry<SplitSet>(value: set, label: set.name))
                      .toList(),
                  onSelected: (SplitSet? value) {
                    setGenerationDialogBloc
                        .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(subsplitTarget: value)));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildMethodSelection(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Which kind of set generation method should be applied?'),
          Row(
            children: [
              Expanded(
                child: BiocentralDropdownMenu<SplitSetGenerationMethod>(
                  label: const Text('Method..'),
                  dropdownMenuEntries: state.availableMethods
                      .map(
                        (SplitSetGenerationMethod method) =>
                            DropdownMenuEntry<SplitSetGenerationMethod>(value: method, label: method.name),
                      )
                      .toList(),
                  onSelected: (SplitSetGenerationMethod? value) =>
                      setGenerationDialogBloc.add(SetGenerationDialogUpdateEvent(SetGenerationSTO(method: value))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildRatioSlider(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    Widget slider;
    if (state.mode == SplitSetGenerationMode.subsplitExisting) {
      slider = BiocentralRatioSlider(
        ratio1: state.splitRatio!.r1,
        totalN: state.selectedSetColumn?.length,
        labels: [state.subsplitSource!.name, state.subsplitTarget!.name],
        colors: const [
          Colors.blue,
          Colors.black,
        ],
        onChanged: (ratios) {
          setGenerationDialogBloc
              .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(splitRatio: SplitRatio.fromRecord(ratios))));
        },
      );
    } else {
      slider = BiocentralRatioSlider(
        ratio1: state.splitRatio!.r1,
        ratio2: state.splitRatio?.r2,
        totalN: state.selectedDatabaseLength,
        labels: const ['Training', 'Validation', 'Test'],
        colors: const [Colors.blue, Colors.black, Colors.blueGrey],
        onChanged: (ratios) {
          setGenerationDialogBloc
              .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(splitRatio: SplitRatio.fromRecord(ratios))));
        },
      );
    }
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select the size of the subsplit:'),
          slider,
        ],
      ),
    );
  }

  @override
  Widget buildRunButton(SetGenerationDialogBloc bloc, SetGenerationDialogState state, void Function({Function()? callback}) closeDialog) {
    if (state.splitRatio != null) {
      return BiocentralSmallButton(
        onTap: () => closeDialog(callback: () => bloc.add(SetGenerationDialogCalculateEvent())),
        label: 'Calculate',
      );
    }
    return Container();
  }

}
