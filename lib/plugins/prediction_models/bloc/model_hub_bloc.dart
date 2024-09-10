import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../domain/prediction_model_repository.dart';
import '../model/prediction_model.dart';

sealed class ModelHubEvent {}

final class ModelHubLoadEvent extends ModelHubEvent {}

@immutable
final class ModelHubState extends BiocentralCommandState<ModelHubState> {
  final List<PredictionModel> predictionModels;

  const ModelHubState(super.stateInformation, super.status, this.predictionModels);

  const ModelHubState.idle()
      : predictionModels = const [],
        super.idle();

  @override
  ModelHubState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return ModelHubState(stateInformation, status, predictionModels);
  }

  @override
  ModelHubState copyWith({required Map<String, dynamic> copyMap}) {
    return ModelHubState(stateInformation, status, copyMap["predictionModels"] ?? predictionModels);
  }

  @override
  List<Object?> get props => [predictionModels, stateInformation, status];
}

class ModelHubBloc extends Bloc<ModelHubEvent, ModelHubState> {
  final PredictionModelRepository _predictionModelRepository;

  ModelHubBloc(this._predictionModelRepository) : super(const ModelHubState.idle()) {
    on<ModelHubLoadEvent>((event, emit) async {
      emit(state.setOperating(information: "Loading models.."));

      List<PredictionModel> predictionModels = _predictionModelRepository.predictionModelsToList();

      emit(state
          .setFinished(information: "Finished loading models!")
          .copyWith(copyMap: {"predictionModels": predictionModels}));
    });
  }
}
