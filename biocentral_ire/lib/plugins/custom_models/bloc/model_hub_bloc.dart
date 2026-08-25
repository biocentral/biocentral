import 'package:biocentral/plugins/custom_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/custom_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

sealed class ModelHubEvent {}

final class _ModelHubLoadInternalEvent extends ModelHubEvent {
  final List<PredictionModel> predictionModels;

  _ModelHubLoadInternalEvent(this.predictionModels);
}


@immutable
final class ModelHubState extends Equatable {
  final List<PredictionModel> predictionModels;

  const ModelHubState(this.predictionModels);

  const ModelHubState.initial() : predictionModels = const [];

  const ModelHubState.loaded(this.predictionModels);

  @override
  List<Object?> get props => [predictionModels];
}

class ModelHubBloc extends Bloc<ModelHubEvent, ModelHubState> {
  final BiocentralProjectRepository _projectRepository;
  final CustomModelRepository _modelRepository;

  ModelHubBloc(this._projectRepository, this._modelRepository) : super(const ModelHubState.initial()) {
    on<_ModelHubLoadInternalEvent>((event, emit) async {
      emit(ModelHubState.loaded(event.predictionModels));
    });

    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    _modelRepository.databaseStream.listen((predictionModels) {
      add(_ModelHubLoadInternalEvent(predictionModels));
    });
  }
}
