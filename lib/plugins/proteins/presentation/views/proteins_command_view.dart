import 'package:biocentral/plugins/proteins/bloc/protein_predict_dialog_bloc.dart';
import 'package:biocentral/plugins/proteins/bloc/proteins_command_bloc.dart';
import 'package:biocentral/plugins/proteins/data/asset_protein_datasets.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/plugins/proteins/model/analyze_example_dataset_tutorial.dart';
import 'package:biocentral/plugins/proteins/presentation/dialogs/protein_asset_datasets_dialog.dart';
import 'package:biocentral/plugins/proteins/presentation/dialogs/protein_column_wizard_dialog.dart';
import 'package:biocentral/plugins/proteins/presentation/dialogs/protein_predict_dialog.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/biocentral/presentation/widgets/biocentral_explainable_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/presentation/tutorial_registration_mixin.dart';

class ProteinsCommandView extends StatefulWidget {
  const ProteinsCommandView({super.key});

  @override
  State<ProteinsCommandView> createState() => _ProteinsCommandViewState();
}

class _ProteinsCommandViewState extends State<ProteinsCommandView> with TutorialRegistrationMixin {
  GlobalKey loadProteinsExampleDatasetsButtonKey = GlobalKey();
  GlobalKey showProteinsColumnWizardButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    registerForTutorials([AnalyzeExampleDatasetTutorial]);
  }

  void loadProteinFile(ProteinsCommandBloc proteinCommandBloc) async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ['fasta'], type: FileType.custom, withData: kIsWeb);

    if (result != null) {
      DatabaseImportMode importMode = DatabaseImportMode.defaultMode;
      if (mounted) {
        importMode = await getImportModeFromDialog(context: context);
      }
      proteinCommandBloc
          .add(ProteinsCommandLoadProteinsFromFileEvent(xFile: result.xFiles.single, importMode: importMode));
    } else {
      // User canceled the picker
    }
  }

  void loadCustomAttributesFile(ProteinsCommandBloc proteinCommandBloc) async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ['csv', 'tsv'], type: FileType.custom, withData: kIsWeb);

    if (result != null) {
      // TODO Import Mode
      proteinCommandBloc.add(ProteinsCommandLoadCustomAttributesFromFileEvent(xFile: result.xFiles.single));
    } else {
      // User canceled the picker
    }
  }

  void saveProteins(ProteinsCommandBloc proteinCommandBloc) async {
    String? outputPath;
    if (!kIsWeb) {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'proteins.fasta',
        allowedExtensions: ['.fasta'],
      );
      if (outputPath == null) {
        // User canceled the picker
        return;
      }
    }
    proteinCommandBloc.add(ProteinsCommandSaveToFileEvent(outputPath));
  }

  void openColumnWizardDialog(ProteinsCommandBloc proteinCommandBloc, String? initialSelectedColumn) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => ColumnWizardBloc(
            context.read<ProteinRepository>(),
            context.read<BiocentralColumnWizardRepository>(),
          )..add(ColumnWizardLoadEvent()),
          child: ProteinColumnWizardDialog(
            onApplyColumn: (newColumnName, originalColumnName, operationHistory) {
              proteinCommandBloc.add(
                ProteinsCommandAddColumnEvent(newColumnName, originalColumnName, operationHistory),
              );
            },
            initialSelectedColumn: initialSelectedColumn,
          ),
        );
      },
    );
  }

  void openProteinPredictDialog(ProteinsCommandBloc proteinCommandBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => ProteinPredictDialogBloc(
            context.read<BiocentralAPIRepository>(),
          )..add(ProteinPredictDialogStartEvent()),
          child: ProteinPredictDialog(
            onPredict: (selectedModels) => proteinCommandBloc.add(ProteinsCommandPredictEvent(selectedModels)),
          ),
        );
      },
    );
  }

  void retrieveTaxonomy(ProteinsCommandBloc proteinCommandBloc) {
    proteinCommandBloc.add(ProteinsCommandRetrieveTaxonomyEvent());
  }

  void openProteinAssetDatasetsDialog(ProteinsCommandBloc proteinCommandBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProteinAssetDatasetsDialog(
          assetDatasets: AssetProteinDatasetContainer.assetProteinDatasets(),
          loadDatasetCallback: (LoadedFileData fileData, DatabaseImportMode importMode) {
            // TODO FILE / STRING
            proteinCommandBloc
                .add(ProteinsCommandLoadProteinsFromFileEvent(fileData: fileData, importMode: importMode));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProteinsCommandBloc proteinCommandBloc = BlocProvider.of<ProteinsCommandBloc>(context);

    return BlocBuilder<ProteinsCommandBloc, ProteinsCommandState>(
      builder: (context, state) => BiocentralCommandBar(
        commands: [
          BiocentralTooltip(
            message: 'Load proteins from file..',
            child: BiocentralButton(
              iconData: Icons.file_open,
              onTap: () => loadProteinFile(proteinCommandBloc),
            ),
          ),
          BiocentralTooltip(
            message: 'Load protein attributes from file..',
            child: BiocentralExplainableWidget(
              explain: "TEST",
              child: BiocentralButton(
                iconData: Icons.file_present_rounded,
                onTap: () => loadCustomAttributesFile(proteinCommandBloc),
              ),
            ),
          ),
          BiocentralTooltip(
            message: 'Save proteins to file..',
            child: BiocentralButton(
              iconData: Icons.save,
              onTap: () => saveProteins(proteinCommandBloc),
            ),
          ),
          BiocentralTooltip(
            message: 'Analyze and modify the columns in your dataset',
            child: BiocentralButton(
              key: showProteinsColumnWizardButtonKey,
              iconData: Icons.view_column_outlined,
              onTap: () => openColumnWizardDialog(proteinCommandBloc, null),
            ),
          ),
          BiocentralTooltip(
            message: 'Get missing taxonomy data from the server for your proteins',
            child: BiocentralButton(
              iconData: Icons.nature_people_rounded,
              onTap: () => retrieveTaxonomy(proteinCommandBloc),
            ),
          ),
          BiocentralTooltip(
            message: 'Predict missing protein features',
            child: BiocentralButton(
              iconData: Icons.batch_prediction_outlined,
              onTap: () => openProteinPredictDialog(proteinCommandBloc),
            ),
          ),
          BiocentralTooltip(
            message: 'Load a predefined dataset to learn and explore',
            child: BiocentralButton(
              key: loadProteinsExampleDatasetsButtonKey,
              iconData: Icons.bubble_chart_sharp,
              onTap: () => openProteinAssetDatasetsDialog(proteinCommandBloc),
            ),
          ),
        ],
      ),
    );
  }
}

extension TutorialExtCommand on ProteinsCommandView {
  ProteinsCommandBloc? getProteinsCommandBloc(dynamic state) =>
      state is _ProteinsCommandViewState ? BlocProvider.of(state.context) : null;

  GlobalKey? getLoadProteinsExampleDatasetsButtonKey(dynamic state) =>
      state is _ProteinsCommandViewState ? state.loadProteinsExampleDatasetsButtonKey : null;

  GlobalKey? getShowProteinsColumnWizardButtonKey(dynamic state) =>
      state is _ProteinsCommandViewState ? state.showProteinsColumnWizardButtonKey : null;
}
