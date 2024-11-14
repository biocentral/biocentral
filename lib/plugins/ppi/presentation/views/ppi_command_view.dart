import 'dart:async';

import 'package:biocentral/plugins/ppi/model/load_example_ppi_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_system/tutorial_system.dart';

import 'package:biocentral/plugins/ppi/bloc/ppi_command_bloc.dart';
import 'package:biocentral/plugins/ppi/bloc/ppi_database_tests_dialog_bloc.dart';
import 'package:biocentral/plugins/ppi/bloc/ppi_import_dialog_bloc.dart';
import 'package:biocentral/plugins/ppi/data/ppi_asset_dataset_container.dart';
import 'package:biocentral/plugins/ppi/data/ppi_client.dart';
import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';
import 'package:biocentral/plugins/ppi/model/ppi_database_test.dart';
import 'package:biocentral/plugins/ppi/presentation/dialogs/ppi_database_tests_dialog.dart';
import 'package:biocentral/plugins/ppi/presentation/dialogs/ppi_dataset_import_dialog.dart';
import 'package:biocentral/plugins/ppi/presentation/dialogs/ppi_example_dataset_dialog.dart';

class PPICommandView extends StatefulWidget {
  const PPICommandView({super.key});

  @override
  State<PPICommandView> createState() => _PPICommandViewState();
}

class _PPICommandViewState extends State<PPICommandView> with AutomaticKeepAliveClientMixin, TutorialRegistrationMixin {
  GlobalKey loadExamplePPIDatasetButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    registerForTutorials([LoadExampleInteractionDatasetTutorialContainer]);
  }

  void loadInteractionFile(PPICommandBloc interactionsCommandBloc) async {
    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ['fasta'], type: FileType.custom, withData: kIsWeb);

    if (result != null) {
      //TODO Import Mode
      interactionsCommandBloc.add(PPICommandLoadFromFileEvent(platformFile: result.files.single));
    } else {
      // User canceled the picker
    }
  }

  Future<void> saveInteractions(PPICommandBloc interactionsCommandBloc) async {
    String? outputPath;
    if (!kIsWeb) {
      outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:', fileName: 'interactions.fasta', allowedExtensions: ['.fasta'],);
      if (outputPath == null) {
        // User canceled the picker
        return;
      }
    }
    interactionsCommandBloc.add(PPICommandSaveToFileEvent(filePath: outputPath));
  }

  void removeDuplicates(PPICommandBloc interactionsCommandBloc) {
    interactionsCommandBloc.add(PPICommandRemoveDuplicatesEvent());
  }

  void openInteractionsImportDialog(PPICommandBloc interactionsCommandBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => PPIImportDialogBloc(
                context.read<BiocentralProjectRepository>(), context.read<BiocentralClientRepository>(),)
              ..add(PPIImportDialogLoadFormatsEvent()),
            child: PPIDatasetImportDialog(
                onImportInteractions: (FileData selectedFile, String format, DatabaseImportMode importMode) async {
              interactionsCommandBloc.add(PPICommandImportWithHVIToolkitEvent(
                  fileData: selectedFile, databaseFormat: format, importMode: importMode,),);
            },),
          );
        },);
  }

  void openColumnWizardDialog(PPICommandBloc interactionsCommandBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) =>
                ColumnWizardBloc(context.read<PPIRepository>(), context.read<BiocentralColumnWizardRepository>())
                  ..add(ColumnWizardLoadEvent()),
            child: ColumnWizardDialog(onCalculateColumn: (columnWizard, columnWizardOperation) {
              interactionsCommandBloc.add(PPICommandColumnWizardOperationEvent(columnWizard, columnWizardOperation));
            },),
          );
        },);
  }

  void openRunInteractionDatabaseTestDialog(PPICommandBloc interactionsCommandBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => PPIDatabaseTestsDialogBloc(
                context.read<PPIRepository>(), context.read<BiocentralClientRepository>().getServiceClient<PPIClient>(),)
              ..add(PPIDatabaseTestsDialogLoadTestsEvent()),
            child: PPIDatabaseTestsDialog(onRunInteractionDatabaseTest: (PPIDatabaseTest testToRun) {
              interactionsCommandBloc.add(PPICommandRunDatabaseTestEvent(testToRun));
            },),
          );
        },);
  }

  void openLoadExampleInteractionDatasetDialog(PPICommandBloc interactionsCommandBloc) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PPIExampleDatasetDialog(
              assetDatasets: PPIAssetDatasetContainer.assetInteractionDatasets(),
              loadDatasetCallback: (FileData fileData, DatabaseImportMode importMode) {
                // TODO FILE / STRING
                interactionsCommandBloc.add(PPICommandLoadFromFileEvent(fileData: fileData, importMode: importMode));
              },);
        },);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final PPICommandBloc interactionsCommandBloc = BlocProvider.of<PPICommandBloc>(context);

    return BlocBuilder<PPICommandBloc, PPICommandState>(
        builder: (context, state) => BiocentralCommandBar(
              commands: [
                BiocentralButton(
                    label: 'Load interactions from file..',
                    iconData: Icons.file_open_outlined,
                    onTap: () => loadInteractionFile(interactionsCommandBloc),),
                BiocentralButton(
                    label: 'Save interactions to file..',
                    iconData: Icons.save,
                    onTap: () => saveInteractions(interactionsCommandBloc),),
                BiocentralTooltip(
                  message: 'Analyze and modify the columns in your dataset',
                  child: BiocentralButton(
                    label: 'Open column wizard..',
                    iconData: Icons.view_column_outlined,
                    onTap: () => openColumnWizardDialog(interactionsCommandBloc),
                  ),
                ),
                BiocentralTooltip(
                  message: 'Remove redundant interactions from the database',
                  child: BiocentralButton(
                      label: 'Remove duplicates..',
                      iconData: Icons.remove_circle,
                      onTap: () => removeDuplicates(interactionsCommandBloc),),
                ),
                BiocentralTooltip(
                  message: 'Import a ppi dataset from various database formats',
                  child: BiocentralButton(
                      label: 'Import interactions from database..',
                      iconData: Icons.downloading,
                      requiredServices: const ['ppi_service'],
                      onTap: () => openInteractionsImportDialog(interactionsCommandBloc),),
                ),
                BiocentralTooltip(
                  message: 'Perform bias and descriptive analysis on your interactions',
                  child: BiocentralButton(
                      label: 'Run test on interaction database..',
                      iconData: Icons.check_box_outlined,
                      requiredServices: const ['ppi_service'],
                      onTap: () => openRunInteractionDatabaseTestDialog(interactionsCommandBloc),),
                ),
                BiocentralTooltip(
                  message: 'Load a predefined dataset to learn and explore',
                  child: BiocentralButton(
                      key: loadExamplePPIDatasetButtonKey,
                      label: 'Load example interaction dataset..',
                      iconData: Icons.bubble_chart_sharp,
                      onTap: () => openLoadExampleInteractionDatasetDialog(interactionsCommandBloc),),
                ),
              ],
            ),);
  }

  @override
  bool get wantKeepAlive => true;
}

extension TutorialExtCommand on PPICommandView {
  PPICommandBloc? getPPICommandBloc(dynamic state) {
    if (state is _PPICommandViewState) {
      return BlocProvider.of(state.context);
    }
    return null;
  }

  GlobalKey? getExampleInteractionDatasetButtonKey(dynamic state) {
    if (state is _PPICommandViewState) {
      return state.loadExamplePPIDatasetButtonKey;
    }
    return null;
  }
}
