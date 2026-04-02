import 'package:biocentral/plugins/proteins/bloc/proteins_commands.dart';
import 'package:biocentral/plugins/proteins/model/analyze_example_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/model/tutorial_id.dart';
import 'package:tutorial_system/presentation/tutorial_registration_mixin.dart';

class ProteinLoadAssetDatasetCommandDisplay extends StatefulWidget {
  final List<BiocentralAssetDataset> assetDatasets;

  const ProteinLoadAssetDatasetCommandDisplay({required this.assetDatasets, super.key});

  @override
  State<ProteinLoadAssetDatasetCommandDisplay> createState() => _ProteinLoadAssetDatasetCommandDisplayState();
}

class _ProteinLoadAssetDatasetCommandDisplayState extends State<ProteinLoadAssetDatasetCommandDisplay>
    with TutorialRegistrationMixin {
  // TODO TUTORIAL
  final Map<BiocentralAssetDataset, GlobalKey> assetDatasetKeys = {};
  final GlobalKey importButtonKey = GlobalKey();

  BiocentralAssetDataset? _selectedAssetDataset;

  @override
  void initState() {
    super.initState();
    registerForTutorials([AnalyzeExampleDatasetTutorial]);
  }

  LoadProteinsFromFileCommand? collectCommand() {
    if (_selectedAssetDataset != null) {
      return LoadProteinsFromFileCommand(
        biocentralProjectRepository: context.read(),
        proteinRepository: context.read(),
        xFile: null,
        assetDataset: _selectedAssetDataset,
        importMode: DatabaseImportMode.overwrite,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.bubble_chart_sharp),
      name: 'Load an example dataset',
      description: 'Load a predefined dataset to learn and explore',
      executeButtonLabel: 'Load',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
      commandAvailability: BiocentralCommandAvailability.always(),
    );
  }

  Widget buildParameterSelection() {
    return Column(
      children: [
        Padding(padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal(context) * 2), child: buildExampleDatasetDocs()),
        buildDatasetSelection(),
      ].withPadding(const Padding(
        padding: EdgeInsetsGeometry.all(8.0),
      )),
    );
  }

  Widget buildExampleDatasetDocs() {
    String docString = '';
    if (_selectedAssetDataset != null) {
      docString = '\n${_selectedAssetDataset!.name}:\n\n${_selectedAssetDataset!.docs}\n';
    }
    return buildDocStringBox(docString);
  }

  Widget buildDocStringBox(String docString) {
    return SizedBox(
      height: SizeConfig.screenHeight(context) * 0.15,
      width: SizeConfig.screenWidth(context) * 0.8,
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.grey,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(docString),
          ),
        ),
      ),
    );
  }

  Widget buildDatasetSelection() {
    final List<Widget> exampleDatasetRadioTiles = [];
    for (BiocentralAssetDataset assetDataset in widget.assetDatasets) {
      final Widget exampleDatasetRadioTile = RadioListTile<BiocentralAssetDataset>(
        key: assetDatasetKeys[assetDataset],
        title: Text(assetDataset.name, style: Theme.of(context).textTheme.bodyMedium),
        value: assetDataset,
        groupValue: _selectedAssetDataset,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (BiocentralAssetDataset? value) {
          setState(() {
            _selectedAssetDataset = value;
          });
        },
      );
      exampleDatasetRadioTiles.add(exampleDatasetRadioTile);
    }
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal(context)),
      child: Column(children: exampleDatasetRadioTiles),
    );
  }
}

extension TutorialExtExample on ProteinLoadAssetDatasetCommandDisplay {
  // TODO
  BuildContext? getDialogContext(dynamic state) {
    return state is _ProteinLoadAssetDatasetCommandDisplayState ? state.context : null;
  }

  Map<TutorialID, GlobalKey> getAssetDatasetKeys(dynamic state) {
    final Map<TutorialID, GlobalKey> result = {};
    if (state is _ProteinLoadAssetDatasetCommandDisplayState) {
      for (MapEntry<BiocentralAssetDataset, GlobalKey> entry in state.assetDatasetKeys.entries) {
        if (entry.key.tutorialID != null) {
          result[entry.key.tutorialID!] = entry.value;
        }
      }
    }
    return result;
  }

  GlobalKey? getImportButtonKey(dynamic state) {
    return state is _ProteinLoadAssetDatasetCommandDisplayState ? state.importButtonKey : null;
  }

  BiocentralAssetDataset? getSelectedAssetDataset(dynamic state) {
    return state is _ProteinLoadAssetDatasetCommandDisplayState ? state._selectedAssetDataset : null;
  }
}
