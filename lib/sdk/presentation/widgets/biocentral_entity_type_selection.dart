import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/biocentral_database_repository.dart';
import '../../util/logging.dart';
import 'biocentral_discrete_selection.dart';

class BiocentralEntityTypeSelection extends StatefulWidget {
  final void Function(Type? value) onChangedCallback;
  final Type? initialValue;

  const BiocentralEntityTypeSelection({super.key, required this.onChangedCallback, this.initialValue});

  @override
  State<BiocentralEntityTypeSelection> createState() => _BiocentralEntityTypeSelectionState();
}

class _BiocentralEntityTypeSelectionState extends State<BiocentralEntityTypeSelection> {
  late final BiocentralDatabaseRepository? biocentralDatabaseRepository;

  @override
  void initState() {
    super.initState();
    try {
      biocentralDatabaseRepository = context.read<BiocentralDatabaseRepository>();
    } catch (e) {
      biocentralDatabaseRepository = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (biocentralDatabaseRepository == null || biocentralDatabaseRepository!.getAvailableTypes().isEmpty) {
      String errorMessage = "ERROR: Could not find any databases!";
      logger.e(errorMessage);
      return Text(errorMessage);
    }
    Set<Type> entityTypes = biocentralDatabaseRepository!.getAvailableTypes();
    return BiocentralDiscreteSelection<Type?>(
        title: "Type: ",
        selectableValues: entityTypes.toList(),
        initialValue: widget.initialValue,
        onChangedCallback: widget.onChangedCallback);
  }
}
