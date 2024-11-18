import 'package:biocentral/plugins/prediction_models/bloc/models_commands.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_client.dart';
import 'package:biocentral/plugins/prediction_models/domain/prediction_model_repository.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class BiotrainerTrainingEvent {}

final class BiotrainerTrainingStartTrainingEvent extends BiotrainerTrainingEvent {
  final Type biocentralDatabaseType;
  final Map<String, String> trainingConfiguration;

  BiotrainerTrainingStartTrainingEvent(this.biocentralDatabaseType, this.trainingConfiguration);
}

@immutable
final class BiotrainerTrainingState extends BiocentralCommandState<BiotrainerTrainingState> {
  final PredictionModel? trainingModel;

  const BiotrainerTrainingState(
    super.stateInformation,
    super.status,
    this.trainingModel,
  );

  const BiotrainerTrainingState.idle()
      : trainingModel = null,
        super.idle();

  const BiotrainerTrainingState.fromModel({this.trainingModel}) : super.idle();

  @override
  List<Object?> get props => [trainingModel, status];

  @override
  BiotrainerTrainingState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return BiotrainerTrainingState(
      stateInformation,
      status,
      trainingModel,
    );
  }

  @override
  BiotrainerTrainingState copyWith({required Map<String, dynamic> copyMap}) {
    return BiotrainerTrainingState(
      stateInformation,
      status,
      copyMap['trainingModel'] ?? trainingModel,
    );
  }
}

class BiotrainerTrainingBloc extends BiocentralBloc<BiotrainerTrainingEvent, BiotrainerTrainingState>
    with BiocentralUpdateBloc {
  final PredictionModelRepository _predictionModelRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralClientRepository _biocentralClientRepository;

  BiotrainerTrainingBloc(
    this._predictionModelRepository,
    this._biocentralClientRepository,
    this._biocentralDatabaseRepository,
    this._biocentralProjectRepository,
    EventBus eventBus,
  ) : super(const BiotrainerTrainingState.idle(), eventBus) {
    on<BiotrainerTrainingStartTrainingEvent>((event, emit) async {
      final BiocentralDatabase? database = _biocentralDatabaseRepository.getFromType(event.biocentralDatabaseType);

      if (database == null) {
        emit(state.setErrored(information: 'Could not find database to train model!'));
      } else {
        final TrainBiotrainerModelCommand trainBiotrainerModelCommand = TrainBiotrainerModelCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          biocentralDatabase: database,
          predictionModelRepository: _predictionModelRepository,
          predictionModelsClient: _biocentralClientRepository.getServiceClient<PredictionModelsClient>(),
          trainingConfiguration: event.trainingConfiguration,
        );
        await trainBiotrainerModelCommand
            .executeWithLogging<BiotrainerTrainingState>(_biocentralProjectRepository, state)
            .forEach((either) {
          either.match((l) => emit(l), (r) => updateDatabases()); // Ignore result here
        });
      }
    });
  }
}
