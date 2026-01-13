import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class ProteinPredictDialogEvent {}

final class ProteinPredictDialogStartEvent extends ProteinPredictDialogEvent {}

@immutable
final class ProteinPredictDialogState extends Equatable {
  final List<ModelMetadata> modelMetadata;
  final ProteinPredictDialogStatus status;

  const ProteinPredictDialogState(this.modelMetadata, this.status);

  const ProteinPredictDialogState.initial()
      : modelMetadata = const [],
        status = ProteinPredictDialogStatus.initial;

  const ProteinPredictDialogState.loading()
      : modelMetadata = const [],
        status = ProteinPredictDialogStatus.loading;

  const ProteinPredictDialogState.loaded(this.modelMetadata) : status = ProteinPredictDialogStatus.loaded;

  const ProteinPredictDialogState.errored()
      : modelMetadata = const [],
        status = ProteinPredictDialogStatus.errored;

  @override
  List<Object?> get props => [modelMetadata, status];
}

enum ProteinPredictDialogStatus { initial, loading, loaded, errored }

class ProteinPredictDialogBloc extends Bloc<ProteinPredictDialogEvent, ProteinPredictDialogState> {
  final BiocentralAPIRepository _apiRepository;

  ProteinPredictDialogBloc(this._apiRepository) : super(const ProteinPredictDialogState.initial()) {
    on<ProteinPredictDialogStartEvent>((event, emit) async {
      emit(const ProteinPredictDialogState.loading());

      final biocentralAPI = _apiRepository.getBiocentralAPI();
      final metadata = await biocentralAPI.getModelMetadata();
      if(metadata == null) {
        return emit(const ProteinPredictDialogState.errored());
      }
      return emit(ProteinPredictDialogState.loaded(metadata));
    });
  }
}
