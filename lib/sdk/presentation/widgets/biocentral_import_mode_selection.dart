import 'package:flutter/material.dart';

import '../../domain/biocentral_database.dart';
import '../../util/type_util.dart';
import 'biocentral_discrete_selection.dart';

class BiocentralImportModeSelection extends StatefulWidget {
  final void Function(DatabaseImportMode? value) onChangedCallback;

  const BiocentralImportModeSelection({super.key, required this.onChangedCallback});

  @override
  State<BiocentralImportModeSelection> createState() => _BiocentralImportModeSelectionState();
}

class _BiocentralImportModeSelectionState extends State<BiocentralImportModeSelection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralDiscreteSelection<DatabaseImportMode>(
        title: "Import mode:",
        selectableValues: DatabaseImportMode.values,
        displayConversion: (DatabaseImportMode mode) => mode.name.capitalize(),
        initialValue: DatabaseImportMode.defaultMode,
        onChangedCallback: widget.onChangedCallback);
  }
}
