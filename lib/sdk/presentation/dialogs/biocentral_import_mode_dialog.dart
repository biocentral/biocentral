import 'package:flutter/material.dart';

import '../../domain/biocentral_database.dart';
import '../../util/size_config.dart';
import '../widgets/biocentral_import_mode_selection.dart';
import '../widgets/biocentral_small_button.dart';
import 'biocentral_dialog.dart';

class BiocentralImportModeDialog extends StatefulWidget {
  final void Function(DatabaseImportMode?) selectedImportModeCallback;

  const BiocentralImportModeDialog({super.key, required this.selectedImportModeCallback});

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
      small: false, // TODO Small Dialog not working yet
      children: [
        Text(
          "How should your file be imported?",
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
                  }),
                  BiocentralSmallButton(
                    label: "OK",
                    onTap: closeDialog,
                  ),
                ],
              ),
            )),
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
        });
      });
  return selectedMode;
}
