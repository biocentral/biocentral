import 'package:biocentral/plugins/ppi/domain/ppi_repository.dart';
import 'package:biocentral/plugins/ppi/domain/ppi_repository_properties.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class PPIPropertiesEvent {}

final class PPIPropertiesCalculateEvent extends PPIPropertiesEvent {}

@immutable
final class PPIPropertiesState extends Equatable {
  final List<PPIRepositoryProperty> properties;
  final PPIPropertiesStatus status;

  const PPIPropertiesState(this.properties, this.status);

  const PPIPropertiesState.initial(this.properties) : status = PPIPropertiesStatus.initial;

  const PPIPropertiesState.loading(this.properties) : status = PPIPropertiesStatus.loading;

  const PPIPropertiesState.loaded(this.properties) : status = PPIPropertiesStatus.loaded;

  @override
  List<Object?> get props => [properties, status];
}

enum PPIPropertiesStatus { initial, loading, loaded }

class PPIPropertiesBloc extends Bloc<PPIPropertiesEvent, PPIPropertiesState> {
  final PPIRepository _ppiRepository;

  PPIPropertiesBloc(this._ppiRepository) : super(const PPIPropertiesState.initial([])) {
    on<PPIPropertiesCalculateEvent>((event, emit) async {
      emit(const PPIPropertiesState.loading([]));
      final List<PPIRepositoryProperty> properties =
          await PpiRepositoryProperties().calculateProperties(_ppiRepository.databaseToList());
      emit(PPIPropertiesState.loaded(properties));
    });
  }
}
