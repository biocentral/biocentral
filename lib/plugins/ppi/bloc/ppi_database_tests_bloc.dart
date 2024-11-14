import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';
import 'package:biocentral/plugins/ppi/model/ppi_database_test.dart';

sealed class PPIDatabaseTestsEvent {
  PPIDatabaseTestsEvent();
}

final class PPIDatabaseTestsLoadTestsEvent extends PPIDatabaseTestsEvent {
  PPIDatabaseTestsLoadTestsEvent();
}

@immutable
final class PPIDatabaseTestsState extends Equatable {
  final List<PPIDatabaseTest> executedTests;

  final PPIDatabaseTestsStatus status;

  const PPIDatabaseTestsState(this.executedTests, this.status);

  const PPIDatabaseTestsState.initial()
      : executedTests = const [],
        status = PPIDatabaseTestsStatus.initial;

  const PPIDatabaseTestsState.loading()
      : executedTests = const [],
        status = PPIDatabaseTestsStatus.loading;

  const PPIDatabaseTestsState.loaded(this.executedTests) : status = PPIDatabaseTestsStatus.loading;

  @override
  List<Object?> get props => [executedTests, status];
}

enum PPIDatabaseTestsStatus { initial, loading, loaded }

class PPIDatabaseTestsBloc extends Bloc<PPIDatabaseTestsEvent, PPIDatabaseTestsState> {
  final PPIRepository _ppiRepository;

  PPIDatabaseTestsBloc(this._ppiRepository) : super(const PPIDatabaseTestsState.initial()) {
    on<PPIDatabaseTestsLoadTestsEvent>((event, emit) async {
      emit(const PPIDatabaseTestsState.loading());

      final List<PPIDatabaseTest> executedTests = _ppiRepository.associatedDatasetTests;

      emit(PPIDatabaseTestsState.loaded(executedTests));
    });
  }
}
