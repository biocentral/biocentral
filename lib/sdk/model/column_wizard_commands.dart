import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:biocentral/sdk/bloc/biocentral_command.dart';
import 'package:biocentral/sdk/bloc/biocentral_state.dart';
import 'package:biocentral/sdk/model/column_wizard_abstract.dart';
import 'package:biocentral/sdk/model/column_wizard_operations.dart';

final class ColumnWizardOperationCommand extends BiocentralCommand<ColumnWizardOperationResult> {
  final ColumnWizard _columnWizard;
  final ColumnWizardOperation _columnWizardOperation;

  ColumnWizardOperationCommand(
      {required ColumnWizard columnWizard, required ColumnWizardOperation columnWizardOperation,})
      : _columnWizard = columnWizard,
        _columnWizardOperation = columnWizardOperation;

  @override
  Stream<Either<T, ColumnWizardOperationResult>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Calculating new column..'));
    final ColumnWizardOperationResult result = await compute(_columnWizardOperation.operate, _columnWizard);
    yield right(result);
    yield left(state.setFinished(information: 'Finished calculating new column!'));
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'originalColumnName': _columnWizard.columnName, 'newColumnName': _columnWizardOperation.newColumnName};
  }
}
