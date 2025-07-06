import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

final class ColumnWizardOperationCommand extends BiocentralCommand<Map<String, BioEntity>> {
  final BiocentralDatabase _database;
  final String _originalColumnName;
  final String _newColumnName;
  final List<ColumnWizardHistoryEntry> _operationHistory;

  ColumnWizardOperationCommand(
      {required BiocentralDatabase database,
      required String originalColumnName,
      required String newColumnName,
      required List<ColumnWizardHistoryEntry> operationHistory})
      : _database = database,
        _originalColumnName = originalColumnName,
        _newColumnName = newColumnName,
        _operationHistory = operationHistory;

  @override
  Stream<Either<T, Map<String, BioEntity>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Applying new column..'));
    final lastResult = _operationHistory.last.resultWizard;
    final Map<String, BioEntity> databaseResult = await _database.addColumnFromColumnWizard(_newColumnName, lastResult);
    yield right(databaseResult);
    yield left(state.setFinished(information: 'Finished adding new column!'));
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'originalColumnName': _originalColumnName,
      'newColumnName': _newColumnName,
      // Skip first because this is the original column
      'operations': _operationHistory.skip(1).map((event) => event.operation.runtimeType.toString()).toList()
      // TODO Add proper configuration of each operation
    };
  }

  @override
  String get typeName => 'ColumnWizardOperationCommand';
}
