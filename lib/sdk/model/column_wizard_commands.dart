import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../bloc/biocentral_command.dart';
import '../bloc/biocentral_state.dart';
import 'column_wizard_abstract.dart';
import 'column_wizard_operations.dart';

final class ColumnWizardOperationCommand extends BiocentralCommand<ColumnWizardOperationResult> {
  final ColumnWizard _columnWizard;
  final ColumnWizardOperation _columnWizardOperation;

  ColumnWizardOperationCommand(
      {required ColumnWizard columnWizard, required ColumnWizardOperation columnWizardOperation})
      : _columnWizard = columnWizard,
        _columnWizardOperation = columnWizardOperation;

  @override
  Stream<Either<T, ColumnWizardOperationResult>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: "Calculating new column.."));
    ColumnWizardOperationResult result = await compute(_columnWizardOperation.operate, _columnWizard);
    yield right(result);
    yield left(state.setFinished(information: "Finished calculating new column!"));
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {"originalColumnName": _columnWizard.columnName, "newColumnName": _columnWizardOperation.newColumnName};
  }
}
