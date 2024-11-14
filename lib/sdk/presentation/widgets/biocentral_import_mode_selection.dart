import 'package:flutter/material.dart';

import 'package:biocentral/sdk/domain/biocentral_database.dart';
import 'package:biocentral/sdk/util/type_util.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_discrete_selection.dart';

class BiocentralImportModeSelection extends StatefulWidget {
  final void Function(DatabaseImportMode? value) onChangedCallback;

  const BiocentralImportModeSelection({required this.onChangedCallback, super.key});

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
        title: 'Import mode:',
        selectableValues: DatabaseImportMode.values,
        displayConversion: (DatabaseImportMode mode) => mode.name.capitalize(),
        initialValue: DatabaseImportMode.defaultMode,
        onChangedCallback: widget.onChangedCallback,);
  }
}
