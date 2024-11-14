import 'package:flutter/material.dart';

import 'package:biocentral/sdk/domain/biocentral_database.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_import_mode_selection.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_small_button.dart';
import 'package:biocentral/sdk/presentation/dialogs/biocentral_dialog.dart';

class BiocentralImportModeDialog extends StatefulWidget {
  final void Function(DatabaseImportMode?) selectedImportModeCallback;

  const BiocentralImportModeDialog({required this.selectedImportModeCallback, super.key});

  @override
  State<BiocentralImportModeDialog> createState() => _BiocentralImportModeDialogState();
}

class _BiocentralImportModeDialogState extends State<BiocentralImportModeDialog> {
  DatabaseImportMode? selectedImportMode;

  @override
  void initState() {
    super.initState();
  }

  void closeDialog() {
    widget.selectedImportModeCallback(selectedImportMode);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralDialog(
      children: [
        Text(
          'How should your file be imported?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Padding(
            padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal(context) * 2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BiocentralImportModeSelection(onChangedCallback: (DatabaseImportMode? importMode) {
                    selectedImportMode = importMode;
                  },),
                  BiocentralSmallButton(
                    label: 'OK',
                    onTap: closeDialog,
                  ),
                ],
              ),
            ),),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

Future<DatabaseImportMode> getImportModeFromDialog<T>({required BuildContext context}) async {
  DatabaseImportMode selectedMode = DatabaseImportMode.defaultMode;

  if (!context.mounted) {
    return selectedMode;
  }

  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return BiocentralImportModeDialog(selectedImportModeCallback: (DatabaseImportMode? importMode) {
          selectedMode = importMode ?? selectedMode;
        },);
      },);
  return selectedMode;
}
