import 'package:biocentral/sdk/domain/biocentral_database_repository.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_discrete_selection.dart';
import 'package:biocentral/sdk/util/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralEntityTypeSelection extends StatefulWidget {
  final void Function(Type? value) onChangedCallback;
  final Type? initialValue;

  const BiocentralEntityTypeSelection({required this.onChangedCallback, super.key, this.initialValue});

  @override
  State<BiocentralEntityTypeSelection> createState() => _BiocentralEntityTypeSelectionState();
}

class _BiocentralEntityTypeSelectionState extends State<BiocentralEntityTypeSelection> {
  late String? _initialValue;
  final Map<String, Type> _entityTypes = {};

  @override
  void initState() {
    super.initState();
    try {
      final biocentralDatabaseRepository = context.read<BiocentralDatabaseRepository>();
      final loadedTypes = biocentralDatabaseRepository.getAvailableTypes();
      _entityTypes.clear();
      _entityTypes.addAll(loadedTypes);
      _initialValue =
          _entityTypes.entries.where((entry) => entry.value == widget.initialValue).firstOrNull?.key ?? 'Protein';
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entityTypes.isEmpty) {
      final String errorMessage = 'ERROR: Could not find any databases!';
      logger.e(errorMessage);
      return Text(errorMessage);
    }

    return BiocentralDiscreteSelection<String?>(
      title: 'Type: ',
      selectableValues: _entityTypes.keys.toList(),
      initialValue: _initialValue,
      onChangedCallback: (String? value) => widget.onChangedCallback(_entityTypes[value]),
    );
  }
}
