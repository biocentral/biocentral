import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

final class ColumnWizardApplyColumnCommand extends BiocentralCommand<BiocentralDatabaseUpdate<BioEntity>> {
  final BiocentralDatabase _database;
  final String _originalColumnName;
  final String _newColumnName;
  final List<ColumnWizardHistoryEntry> _operationHistory;

  ColumnWizardApplyColumnCommand({
    required BiocentralDatabase database,
    required String originalColumnName,
    required String newColumnName,
    required List<ColumnWizardHistoryEntry> operationHistory,
  })  : _database = database,
        _originalColumnName = originalColumnName,
        _newColumnName = newColumnName,
        _operationHistory = operationHistory;

  @override
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<BioEntity>> log = initLog();
    yield log = log.logInfo(information: 'Applying new column..');

    final lastResult = _operationHistory.last.resultWizard;
    final update = await _database.addColumnFromColumnWizard(_newColumnName, lastResult);

    yield log.finish(
      result: BiocentralCommandResult(update, update.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished applying new column!',
        current: update.result.length,
        total: update.result.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is BiocentralDatabaseUpdate) {
      _database.acceptDatabaseUpdate(commandResult as BiocentralDatabaseUpdate<BioEntity>);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'originalColumnName': _originalColumnName,
      'newColumnName': _newColumnName,
      // Skip first because this is the original column
      'operations': _operationHistory.skip(1).map((event) => event.operation.runtimeType.toString()).toList(),
      // TODO Add proper configuration of each operation
    };
  }

  @override
  String get typeName => 'ColumnWizardApplyColumnCommand';
}
