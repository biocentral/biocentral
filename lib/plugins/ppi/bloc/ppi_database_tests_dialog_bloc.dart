import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/ppi/data/ppi_client.dart';
import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';
import 'package:biocentral/plugins/ppi/model/ppi_database_test.dart';

sealed class PPIDatabaseTestsDialogEvent {
  PPIDatabaseTestsDialogEvent();
}

final class PPIDatabaseTestsDialogLoadTestsEvent extends PPIDatabaseTestsDialogEvent {
  PPIDatabaseTestsDialogLoadTestsEvent();
}

final class PPIDatabaseTestsDialogSelectTestEvent extends PPIDatabaseTestsDialogEvent {
  final PPIDatabaseTest? selectedTest;

  PPIDatabaseTestsDialogSelectTestEvent(this.selectedTest);
}

@immutable
final class PPIDatabaseTestsDialogState extends Equatable {
  final List<PPIDatabaseTest> availableTests;
  final PPIDatabaseTest? selectedTest;
  final PPIDatabaseTestRequirement? missingRequirement;

  final PPIDatabaseTestsDialogStatus status;

  const PPIDatabaseTestsDialogState(this.availableTests, this.selectedTest, this.missingRequirement, this.status);

  const PPIDatabaseTestsDialogState.initial()
      : availableTests = const [],
        selectedTest = null,
        missingRequirement = null,
        status = PPIDatabaseTestsDialogStatus.initial;

  const PPIDatabaseTestsDialogState.loading()
      : availableTests = const [],
        selectedTest = null,
        missingRequirement = null,
        status = PPIDatabaseTestsDialogStatus.loading;

  const PPIDatabaseTestsDialogState.loaded(this.availableTests)
      : selectedTest = null,
        missingRequirement = null,
        status = PPIDatabaseTestsDialogStatus.loading;

  const PPIDatabaseTestsDialogState.selected(this.availableTests, this.selectedTest, this.missingRequirement)
      : status = PPIDatabaseTestsDialogStatus.selected;

  const PPIDatabaseTestsDialogState.errored()
      : availableTests = const [],
        selectedTest = null,
        missingRequirement = null,
        status = PPIDatabaseTestsDialogStatus.errored;

  @override
  List<Object?> get props => [availableTests, selectedTest, missingRequirement, status];
}

enum PPIDatabaseTestsDialogStatus { initial, loading, loaded, selected, errored }

class PPIDatabaseTestsDialogBloc extends Bloc<PPIDatabaseTestsDialogEvent, PPIDatabaseTestsDialogState> {
  final PPIRepository _ppiRepository;
  final PPIClient _ppiClient;

  PPIDatabaseTestsDialogBloc(this._ppiRepository, this._ppiClient)
      : super(const PPIDatabaseTestsDialogState.initial()) {
    on<PPIDatabaseTestsDialogLoadTestsEvent>((event, emit) async {
      if (state.availableTests.isEmpty) {
        emit(const PPIDatabaseTestsDialogState.loading());

        final availableTestsEither = await _ppiClient.getAvailableDatasetTests();
        availableTestsEither.match((error) => emit(const PPIDatabaseTestsDialogState.errored()),
            (availableTests) => emit(PPIDatabaseTestsDialogState.loaded(availableTests)),);
      }
    });

    on<PPIDatabaseTestsDialogSelectTestEvent>((event, emit) async {
      final PPIDatabaseTest? selectedTest = event.selectedTest;

      if (selectedTest != null) {
        final PPIDatabaseTestRequirement? missingRequirement = await selectedTest.canBeExecuted(_ppiRepository);
        emit(PPIDatabaseTestsDialogState.selected(state.availableTests, selectedTest, missingRequirement));
      }
    });
  }
}
