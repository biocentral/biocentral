import 'package:biocentral/plugins/proteins/data/protein_client.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class ProteinPredictDialogEvent {}

final class ProteinPredictDialogStartEvent extends ProteinPredictDialogEvent {}

@immutable
final class ProteinPredictDialogState extends Equatable {
  final Map<String, dynamic> modelMetadata;
  final ProteinPredictDialogStatus status;

  const ProteinPredictDialogState(this.modelMetadata, this.status);

  const ProteinPredictDialogState.initial()
      : modelMetadata = const {},
        status = ProteinPredictDialogStatus.initial;

  const ProteinPredictDialogState.loading()
      : modelMetadata = const {},
        status = ProteinPredictDialogStatus.loading;

  const ProteinPredictDialogState.loaded(this.modelMetadata) : status = ProteinPredictDialogStatus.loaded;

  const ProteinPredictDialogState.errored()
      : modelMetadata = const {},
        status = ProteinPredictDialogStatus.errored;

  @override
  List<Object?> get props => [modelMetadata, status];
}

enum ProteinPredictDialogStatus { initial, loading, loaded, errored }

class ProteinPredictDialogBloc extends Bloc<ProteinPredictDialogEvent, ProteinPredictDialogState> {
  final BiocentralClientRepository _clientRepository;

  ProteinPredictDialogBloc(this._clientRepository) : super(const ProteinPredictDialogState.initial()) {
    on<ProteinPredictDialogStartEvent>((event, emit) async {
      emit(const ProteinPredictDialogState.loading());

      final ProteinClient client = _clientRepository.getServiceClient<ProteinClient>();
      final metadataEither = await client.modelMetadata();
      metadataEither.match(
        (error) => emit(const ProteinPredictDialogState.errored()),
        (modelMetadata) => emit(
          ProteinPredictDialogState.loaded(modelMetadata),
        ),
      );
    });
  }
}
