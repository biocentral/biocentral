import 'package:biocentral/plugins/prediction_models/bloc/set_generation_dialog_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/model/split_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetGenerationDialogStep {
  final bool Function(SetGenerationDialogState state) shouldShow;
  final Widget Function(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) builder;

  const SetGenerationDialogStep({
    required this.shouldShow,
    required this.builder,
  });
}

class SetGenerationDialogBuilder {
  static final List<SetGenerationDialogStep> steps = [
    SetGenerationDialogStep(
      shouldShow: (state) => true, // Always show first step
      builder: (bloc, state) => buildDatasetSelection(bloc, state),
    ),
    SetGenerationDialogStep(
      shouldShow: (state) => state.selectedDatabaseType != null,
      builder: (bloc, state) => buildModeSelection(bloc, state),
    ),
    SetGenerationDialogStep(
      shouldShow: (state) =>
          state.mode == SplitSetGenerationMode.subsplitExisting && state.availableSourceSets.isNotEmpty,
      builder: (bloc, state) => buildExistingSetSelection(bloc, state),
    ),
    SetGenerationDialogStep(
      shouldShow: (state) => state.mode == SplitSetGenerationMode.subsplitExisting && state.selectedSetColumn != null,
      builder: (bloc, state) => buildSourceSetSelection(bloc, state),
    ),
    SetGenerationDialogStep(
      shouldShow: (state) =>
          state.mode == SplitSetGenerationMode.subsplitExisting &&
          state.selectedSetColumn != null &&
          state.subsplitSource != null,
      builder: (bloc, state) => buildNewSetNameSelection(bloc, state),
    ),
    SetGenerationDialogStep(
      shouldShow: (state) => state.mode == SplitSetGenerationMode.generateNew || state.subsplitTarget != null,
      builder: (bloc, state) => buildMethodSelection(bloc, state),
    ),
    SetGenerationDialogStep(
      shouldShow: (state) => state.method != null,
      builder: (bloc, state) => buildRatioSlider(bloc, state),
    ),
    SetGenerationDialogStep(
      shouldShow: (state) => state.splitRatio != null, // TODO isValid() check
      builder: (bloc, state) => buildCalculateButton(bloc, state),
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
      SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state,) {
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
                      .map((BiocentralDatabaseColumn column) =>
                          DropdownMenuEntry<BiocentralDatabaseColumn>(value: column, label: column.name),)
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
      SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state,) {
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
      SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state,) {
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
                        setGenerationDialogBloc.add(SetGenerationDialogUpdateEvent(SetGenerationSTO(method: value))),),
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
      slider = RatioSlider(
        ratio1: state.splitRatio!.r1,
        totalN: state.selectedSetColumn?.length,
        labels: [state.subsplitSource!.name, state.subsplitTarget!.name],
        colors: const [Colors.blue, Colors.black,],
        onChanged: (ratios) {
          setGenerationDialogBloc
              .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(splitRatio: SplitRatio.fromRecord(ratios))));
        },
      );
    } else {
      slider = RatioSlider(
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

  static Widget buildCalculateButton(SetGenerationDialogBloc setGenerationDialogBloc, SetGenerationDialogState state) {
    return BiocentralSmallButton(
      onTap: () => setGenerationDialogBloc.add(SetGenerationDialogCalculateEvent()),
      label: 'Calculate',
    );
  }
}

class SetGenerationDialog extends StatefulWidget {
  final Type? initialSelectedType;

  const SetGenerationDialog({super.key, this.initialSelectedType});

  @override
  State<SetGenerationDialog> createState() => _SetGenerationDialogState();
}

class _SetGenerationDialogState extends State<SetGenerationDialog>
    with BiocentralDialogCloseMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedType != null) {
      final SetGenerationDialogBloc setGenerationDialogBloc = BlocProvider.of<SetGenerationDialogBloc>(context);
      setGenerationDialogBloc
          .add(SetGenerationDialogUpdateEvent(SetGenerationSTO(selectedDatabaseType: widget.initialSelectedType!)));
    }
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
    final SetGenerationDialogBloc bloc = BlocProvider.of<SetGenerationDialogBloc>(context);
    final List<Widget> dialogChildren = [];

    dialogChildren.addAll([
      Text(
        'Generate sets for model training',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      ...buildSteps(bloc, state),
      buildCancelButton(),
    ]);

    return BiocentralDialog(
      children: dialogChildren,
    );
  }

  List<Widget> buildSteps(
    SetGenerationDialogBloc bloc,
    SetGenerationDialogState state,
  ) {
    return SetGenerationDialogBuilder.steps
        .where(
          (step) => step.shouldShow(state),
        )
        .map((step) => step.builder(bloc, state))
        .toList();
  }

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }

  @override
  bool get wantKeepAlive => true;
}

class RatioSlider extends StatefulWidget {
  final double ratio1;
  final double? ratio2;
  final List<String> labels;
  final ValueChanged<(double, double, double?)> onChanged;
  final List<Color>? colors;
  final int? totalN;

  const RatioSlider({
    required this.ratio1, required this.labels, required this.onChanged, super.key,
    this.ratio2,
    this.colors,
    this.totalN,
  })  : assert(ratio2 != null ? labels.length == 3 : labels.length == 2),
        assert(colors != null ? colors.length == labels.length : true);

  @override
  State<RatioSlider> createState() => _RatioSliderState();
}

class _RatioSliderState extends State<RatioSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        if(widget.totalN != null) Text('Total Dataset Length: ${widget.totalN}'),
        const SizedBox(height: 16),
        _buildRatioDisplay(),
        const SizedBox(height: 16),
        _buildSliders(),
        const SizedBox(height: 16),
        _buildRatioBar(),
      ],
    );
  }

  List<double> getRatioList() {
    return widget.ratio2 != null
        ? [widget.ratio1, widget.ratio2!, 1 - (widget.ratio1 + widget.ratio2!)]
        : [widget.ratio1, 1 - widget.ratio1];
  }

  Widget _buildRatioDisplay() {
    final ratioList = getRatioList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(ratioList.length, (index) {
        return Column(
          children: [
            Text(
              widget.labels[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${(ratioList[index] * 100).round()}%'),
            if(widget.totalN != null) Text('~${(widget.totalN! * ratioList[index]).round()}'),
          ],
        );
      }),
    );
  }

  Widget _buildSliders() {
    if (widget.ratio2 == null) {
      return Slider(
        value: widget.ratio1,
        min: 0.01,
        max: 0.99,
        divisions: 98,
        onChanged: (value) {
          widget.onChanged((value, 1 - value, null));
        },
      );
    } else {
      final ratio1 = widget.ratio1;
      final ratio2 = widget.ratio2!;
      // Three-way split using RangeSlider
      final double start = ratio1;
      final double end = ratio1 + ratio2;

      return RangeSlider(
        values: RangeValues(start, end),
        min: 0.01,
        max: 0.99,
        divisions: 98,
        onChanged: (values) {
          final double r1 = values.start;
          final double r2 = values.end - values.start;
          final double r3 = 1.0 - (r1 + r2);
          assert(r1 + r2 + r3 == 1.0);
          widget.onChanged((r1, r2, r3));
        },
      );
    }
  }

  Widget _buildRatioBar() {
    final ratioList = getRatioList();
    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: List.generate(ratioList.length, (index) {
            return Expanded(
              flex: (ratioList[index] * 1000).toInt(),
              child: Container(
                color: widget.colors?[index] ?? [Colors.blue, Colors.orange, Colors.green][index % 3],
              ),
            );
          }),
        ),
      ),
    );
  }
}
