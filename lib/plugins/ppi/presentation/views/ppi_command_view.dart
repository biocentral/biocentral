import 'dart:async';

import 'package:bloc_effects/bloc_effects.dart';
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
import 'package:biocentral/plugins/ppi/model/load_example_ppi_dataset_tutorial.dart';
import 'package:biocentral/plugins/ppi/model/ppi_database_test.dart';
import 'package:biocentral/plugins/ppi/presentation/dialogs/ppi_database_tests_dialog.dart';
import 'package:biocentral/plugins/ppi/presentation/dialogs/ppi_dataset_import_dialog.dart';
import 'package:biocentral/plugins/ppi/presentation/dialogs/ppi_example_dataset_dialog.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

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
      interactionsCommandBloc.add(PPICommandLoadFromFileEvent(xFile: result.xFiles.single));
    } else {
      // User canceled the picker
    }
  }

  Future<void> saveInteractions(PPICommandBloc interactionsCommandBloc) async {
    String? outputPath;
    if (!kIsWeb) {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'interactions.fasta',
        allowedExtensions: ['.fasta'],
      );
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
            context.read<BiocentralProjectRepository>(),
            context.read<BiocentralClientRepository>(),
          )..add(PPIImportDialogLoadFormatsEvent()),
          child: PPIDatasetImportDialog(
            onImportInteractions: (LoadedFileData selectedFile, String format, DatabaseImportMode importMode) async {
              interactionsCommandBloc.add(
                PPICommandImportWithHVIToolkitEvent(
                  fileData: selectedFile,
                  databaseFormat: format,
                  importMode: importMode,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void openColumnWizardDialog(PPICommandBloc interactionsCommandBloc, String? initialSelectedColumn) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) =>
              ColumnWizardBloc(context.read<PPIRepository>(), context.read<BiocentralColumnWizardRepository>())
                ..add(ColumnWizardLoadEvent()),
          child: ColumnWizardDialog(
            onCalculateColumn: (columnWizard, columnWizardOperation) {
              interactionsCommandBloc.add(
                PPICommandColumnWizardOperationEvent(columnWizard, columnWizardOperation),
              );
            },
            initialSelectedColumn: initialSelectedColumn,
          ),
        );
      },
    );
  }

  void openRunInteractionDatabaseTestDialog(PPICommandBloc interactionsCommandBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => PPIDatabaseTestsDialogBloc(
            context.read<PPIRepository>(),
            context.read<BiocentralClientRepository>().getServiceClient<PPIClient>(),
          )..add(PPIDatabaseTestsDialogLoadTestsEvent()),
          child: PPIDatabaseTestsDialog(
            onRunInteractionDatabaseTest: (PPIDatabaseTest testToRun) {
              interactionsCommandBloc.add(PPICommandRunDatabaseTestEvent(testToRun));
            },
          ),
        );
      },
    );
  }

  void openLoadExampleInteractionDatasetDialog(PPICommandBloc interactionsCommandBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PPIExampleDatasetDialog(
          assetDatasets: PPIAssetDatasetContainer.assetInteractionDatasets(),
          loadDatasetCallback: (LoadedFileData fileData, DatabaseImportMode importMode) {
            // TODO FILE / STRING
            interactionsCommandBloc.add(PPICommandLoadFromFileEvent(fileData: fileData, importMode: importMode));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final PPICommandBloc ppiCommandBloc = BlocProvider.of<PPICommandBloc>(context);

    // TODO [Refactoring] Duplicated in every command view that uses column wizard dialogs
    return BlocEffectListener<PPICommandBloc, ReOpenColumnWizardEffect>(
      listener: (context, effect) {
        openColumnWizardDialog(ppiCommandBloc, effect.column);
      },
      child: BlocBuilder<PPICommandBloc, PPICommandState>(
        builder: (context, state) => BiocentralCommandBar(
          commands: [
            BiocentralTooltip(
              message: 'Load interactions from file..',
              child: BiocentralButton(
                iconData: Icons.file_open_outlined,
                onTap: () => loadInteractionFile(ppiCommandBloc),
              ),
            ),
            BiocentralTooltip(
              message: 'Save interactions to file..',
              child: BiocentralButton(
                iconData: Icons.save,
                onTap: () => saveInteractions(ppiCommandBloc),
              ),
            ),
            BiocentralTooltip(
              message: 'Analyze and modify the columns in your dataset',
              child: BiocentralButton(
                iconData: Icons.view_column_outlined,
                onTap: () => openColumnWizardDialog(ppiCommandBloc, null),
              ),
            ),
            BiocentralTooltip(
              message: 'Remove redundant interactions from the database',
              child: BiocentralButton(
                iconData: Icons.remove_circle,
                onTap: () => removeDuplicates(ppiCommandBloc),
              ),
            ),
            BiocentralTooltip(
              message: 'Import a ppi dataset from various database formats',
              child: BiocentralButton(
                iconData: Icons.downloading,
                requiredServices: const ['ppi_service'],
                onTap: () => openInteractionsImportDialog(ppiCommandBloc),
              ),
            ),
            BiocentralTooltip(
              message: 'Perform bias and descriptive analysis on your interactions',
              child: BiocentralButton(
                iconData: Icons.check_box_outlined,
                requiredServices: const ['ppi_service'],
                onTap: () => openRunInteractionDatabaseTestDialog(ppiCommandBloc),
              ),
            ),
            BiocentralTooltip(
              message: 'Load a predefined dataset to learn and explore',
              child: BiocentralButton(
                key: loadExamplePPIDatasetButtonKey,
                iconData: Icons.bubble_chart_sharp,
                onTap: () => openLoadExampleInteractionDatasetDialog(ppiCommandBloc),
              ),
            ),
          ],
        ),
      ),
    );
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
