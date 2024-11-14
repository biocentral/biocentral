import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/prediction_models/bloc/biotrainer_config_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/bloc/prediction_model_events.dart';
import 'package:biocentral/plugins/prediction_models/bloc/set_generation_dialog_bloc.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/presentation/displays/biotrainer_option_config_widget.dart';
import 'package:biocentral/plugins/prediction_models/presentation/dialogs/set_generation_dialog.dart';

class BiotrainerConfigDialog extends StatefulWidget {
  final EventBus eventBus;

  const BiotrainerConfigDialog({required this.eventBus, super.key});

  @override
  State<BiotrainerConfigDialog> createState() => _BiotrainerConfigDialogState();
}

class _BiotrainerConfigDialogState extends State<BiotrainerConfigDialog> with AutomaticKeepAliveClientMixin {
  bool _showOptionalOptions = false;

  final TextEditingController _protocolFromController = TextEditingController();
  final TextEditingController _protocolToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final BiotrainerConfigBloc biotrainerConfigBloc = BlocProvider.of<BiotrainerConfigBloc>(context);
    widget.eventBus.on<SetGeneratedEvent>().listen((event) {
      biotrainerConfigBloc.add(BiotrainerConfigCalculatedSetColumnEvent(columnName: event.columnName));
    });
  }

  void selectProtocol(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    final String? protocol = state.buildProtocolFromTo(_protocolFromController.text, _protocolToController.text);
    if (protocol != null) {
      biotrainerConfigBloc.add(BiotrainerConfigSelectProtocolEvent(protocol));
    }
  }

  void openGenerateSetsDialog(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => SetGenerationDialogBloc(context.read<BiocentralDatabaseRepository>(), widget.eventBus),
            child: SetGenerationDialog(
              initialSelectedType: state.selectedDatabaseType,
            ),
          );
        },);
  }

  void startTraining(BiotrainerConfigState state) {
    closeDialog();
    widget.eventBus.fire(BiotrainerStartTrainingEvent(
        databaseType: state.selectedDatabaseType!, trainingConfiguration: state.currentConfiguration,),);
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<BiotrainerConfigBloc, BiotrainerConfigState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) => buildDialog(state),
    );
  }

  Widget buildDialog(BiotrainerConfigState state) {
    final BiotrainerConfigBloc biotrainerConfigBloc = BlocProvider.of<BiotrainerConfigBloc>(context);
    final List<Widget> dialogChildren = [];
    if (state.status == BiotrainerConfigStatus.loadingProtocols ||
        state.status == BiotrainerConfigStatus.loadingConfigOptions) {
      dialogChildren.add(const CircularProgressIndicator());
    } else {
      dialogChildren.addAll([
        Text(
          'Train a model via biotrainer',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        ...buildConfigSelectionByState(biotrainerConfigBloc, state),
      ]);
    }
    return BiocentralDialog(
      children: dialogChildren,
    );
  }

  List<Widget> buildConfigSelectionByState(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    final List<Widget> widgetsForCurrentState = [];
    final BiotrainerConfigStatus status = state.status;
    for (int statusIndex = 0; statusIndex <= BiotrainerConfigStatus.values.indexOf(status); statusIndex++) {
      switch (BiotrainerConfigStatus.values.elementAt(statusIndex)) {
        case BiotrainerConfigStatus.selectingDatabaseType:
          widgetsForCurrentState.add(buildSelectDatabaseType(biotrainerConfigBloc, state));
          break;
        case BiotrainerConfigStatus.loadingProtocols:
          break;
        case BiotrainerConfigStatus.selectingProtocol:
          widgetsForCurrentState.add(buildProtocolSelection(biotrainerConfigBloc, state));
          break;
        case BiotrainerConfigStatus.loadingConfigOptions:
          break;
        case BiotrainerConfigStatus.selectingEmbeddings:
          widgetsForCurrentState.add(buildEmbedderSelection(biotrainerConfigBloc, state));
          break;
        case BiotrainerConfigStatus.selectingTarget:
          widgetsForCurrentState.add(buildTargetSelection(biotrainerConfigBloc, state));
          break;
        case BiotrainerConfigStatus.selectingSets:
          widgetsForCurrentState.add(buildSetSelection(biotrainerConfigBloc, state));
          break;
        case BiotrainerConfigStatus.selectingModel:
          widgetsForCurrentState.add(buildModelSelection(biotrainerConfigBloc, state));
          break;
        case BiotrainerConfigStatus.selectingOptionalConfig:
          widgetsForCurrentState.add(buildOptionalConfigOptions(state));
          widgetsForCurrentState.add(buildTrainModelButton(biotrainerConfigBloc, state));
          break;
        case BiotrainerConfigStatus.verifying:
          widgetsForCurrentState.add(buildVerifyingStatus(state));
          break;
        case BiotrainerConfigStatus.verified:
          widgetsForCurrentState.add(buildVerifiedMessage(state));
        default:
          break;
      }
    }
    widgetsForCurrentState.add(buildErrorMessage(state));
    return widgetsForCurrentState;
  }

  Widget buildSelectDatabaseType(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('1. Do you want to train a model for proteins or protein-protein interactions?'),
          BiocentralEntityTypeSelection(
              initialValue: state.selectedDatabaseType,
              onChangedCallback: (Type? selected) {
                if (selected != null) {
                  biotrainerConfigBloc.add(BiotrainerConfigSelectDatabaseTypeEvent(selected));
                }
              },),
        ],
      ),
    );
  }

  Widget buildProtocolSelection(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    // TODO Does not work as needed yet
    final Set<String> fromValues = state.getProtocolsFrom(_protocolToController.text);
    final Set<String> toValues = state.getProtocolsTo(_protocolFromController.text);

    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('2. Which kind of prediction do you need?'),
          Row(
            children: [
              Expanded(
                child: BiocentralDropdownMenu<String>(
                  controller: _protocolFromController,
                  label: const Text('From..'),
                  dropdownMenuEntries: fromValues
                      .map((String protocol) => DropdownMenuEntry<String>(value: protocol, label: protocol))
                      .toList(),
                  onSelected: (String? value) {
                    setState(() {});
                    selectProtocol(biotrainerConfigBloc, state);
                  },
                ),
              ),
              const Icon(Icons.arrow_forward),
              Expanded(
                child: BiocentralDropdownMenu<String>(
                  controller: _protocolToController,
                  label: const Text('To..'),
                  dropdownMenuEntries: toValues
                      .map((String protocol) => DropdownMenuEntry<String>(value: protocol, label: protocol))
                      .toList(),
                  onSelected: toValues.isEmpty
                      ? null
                      : (String? value) {
                          setState(() {});
                          selectProtocol(biotrainerConfigBloc, state);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEmbedderSelection(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    Widget missingSequencesIcon;
    if (state.proteinsHaveMissingSequences == null || state.proteinsHaveMissingSequences == true) {
      missingSequencesIcon = ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.remove_circle),
          label: const Text('Missing sequences for your proteins!'),);
    }
    missingSequencesIcon = ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle),
        label: const Text('All of your proteins have sequences!'),);
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
              child: Text('3. Which embedder do you want to use for your sequences?'),),
          Flexible(child: missingSequencesIcon),
          Flexible(
            // TODO Available embedders should come from server
            child: BiocentralDropdownMenu<String>(
              label: const Text('Choose embeddings..'),
              dropdownMenuEntries: ['one_hot_encoding', 'Rostlab/prot_t5_xl_uniref50']
                  .map((String embedder) => DropdownMenuEntry<String>(value: embedder, label: embedder))
                  .toList(),
              onSelected: (String? value) => biotrainerConfigBloc.add(BiotrainerConfigSelectEmbedderEvent(value ?? '')),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTargetSelection(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('3. What are your prediction targets?'),
        Flexible(
          child: BiocentralDropdownMenu<String>(
            label: const Text('Choose targets..'),
            dropdownMenuEntries: state.availableTargets
                .map((String target) => DropdownMenuEntry<String>(value: target, label: target))
                .toList(),
            onSelected: (String? value) => biotrainerConfigBloc.add(BiotrainerConfigSelectTargetEvent(value ?? '')),
          ),
        ),
      ],
    );
  }

  Widget buildSetSelection(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('4. How should your training data be split?'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: BiocentralDropdownMenu<String>(
                label: const Text('Choose sets..'),
                controller: TextEditingController(text: state.currentConfiguration['set_column'] ?? ''),
                dropdownMenuEntries:
                    state.availableSets.map((String set) => DropdownMenuEntry<String>(value: set, label: set)).toList(),
                onSelected: (String? value) =>
                    biotrainerConfigBloc.add(BiotrainerConfigSelectSetColumnEvent(value ?? '')),
              ),
            ),
            Flexible(
                child: BiocentralSmallButton(
                  onTap: () => openGenerateSetsDialog(biotrainerConfigBloc, state),
                  label: 'Calculate sets..',
                ),),
          ],
        ),
      ],
    );
  }

  Widget buildModelSelection(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('5. Which model do you want to use?'),
        Flexible(
          child: BiocentralDropdownMenu<String>(
            label: const Text('Choose model..'),
            dropdownMenuEntries: state
                .getAvailableModels()
                .map((String target) => DropdownMenuEntry<String>(value: target, label: target))
                .toList(),
            onSelected: (String? value) => biotrainerConfigBloc.add(BiotrainerConfigSelectModelEvent(value ?? '')),
          ),
        ),
      ],
    );
  }

  Widget buildOptionalConfigOptions(BiotrainerConfigState state) {
    final List<BiotrainerOptionalConfigWidget> optionalConfigWidgets = [];

    if (_showOptionalOptions) {
      for (BiotrainerOption configOption in state.configOptionsByProtocol[state.selectedProtocol] ?? []) {
        if (configOption.name != 'protocol') {
          if (!configOption.required) {
            final BiotrainerOptionalConfigWidget biotrainerOption = BiotrainerOptionalConfigWidget(
              option: configOption,
            );
            optionalConfigWidgets.add(biotrainerOption);
          }
        }
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('6. Do you want to customize default options?'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: _showOptionalOptions,
              onChanged: (bool? value) {
                setState(() {
                  _showOptionalOptions = value ?? false;
                });
              },
            ),
            const Text('Show options'),
          ],
        ),
        ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8.0),
          children: optionalConfigWidgets,
        ),
      ],
    );
  }

  Widget buildVerifyingStatus(BiotrainerConfigState state) {
    return Visibility(
      visible: state.status == BiotrainerConfigStatus.verifying,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(flex: 4, child: CircularProgressIndicator()),
          Spacer(
            
          ),
          Flexible(flex: 4, child: Text('Verifying..')),
        ],
      ),
    );
  }

  Widget buildErrorMessage(BiotrainerConfigState state) {
    return Visibility(
      visible: state.errorMessage != null && state.errorMessage != '',
      child: Text(
        'Error: ${state.errorMessage}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
      ),
    );
  }

  Widget buildVerifiedMessage(BiotrainerConfigState state) {
    return Visibility(
      visible: state.status == BiotrainerConfigStatus.verified,
      child: Text('Configuration verified!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor),),
    );
  }

  Widget buildTrainModelButton(BiotrainerConfigBloc biotrainerConfigBloc, BiotrainerConfigState state) {
    if (state.status != BiotrainerConfigStatus.verified) {
      return BiocentralSmallButton(
          onTap: () => biotrainerConfigBloc.add(BiotrainerConfigVerifyConfigEvent()), label: 'Verify Config',);
    } else {
      return BiocentralSmallButton(onTap: () => startTraining(state), label: 'Start Training');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
