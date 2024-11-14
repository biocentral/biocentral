import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_discrete_selection.dart';

class BiocentralEntityTypeSelection extends StatefulWidget {
  final void Function(Type? value) onChangedCallback;
  final Type? initialValue;

  const BiocentralEntityTypeSelection({required this.onChangedCallback, super.key, this.initialValue});

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
      final String errorMessage = 'ERROR: Could not find any databases!';
      logger.e(errorMessage);
      return Text(errorMessage);
    }
    final Map<String, Type> entityTypes = biocentralDatabaseRepository!.getAvailableTypes();
    final String? initialValue = entityTypes.entries.where((entry) => entry.value == widget.initialValue).firstOrNull?.key;
    return BiocentralDiscreteSelection<String?>(
        title: 'Type: ',
        selectableValues: entityTypes.keys.toList(),
        initialValue: initialValue,
        onChangedCallback: (String? value) => widget.onChangedCallback(entityTypes[value]),);
  }
}
