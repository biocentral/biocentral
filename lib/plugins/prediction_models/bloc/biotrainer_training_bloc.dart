import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../data/prediction_models_client.dart';
import '../domain/prediction_model_repository.dart';
import 'models_commands.dart';

sealed class BiotrainerTrainingEvent {}

final class BiotrainerTrainingStartTrainingEvent extends BiotrainerTrainingEvent {
  final Type biocentralDatabaseType;
  final Map<String, String> trainingConfiguration;

  BiotrainerTrainingStartTrainingEvent(this.biocentralDatabaseType, this.trainingConfiguration);
}

@immutable
final class BiotrainerTrainingState extends BiocentralCommandState<BiotrainerTrainingState> {
  final List<String> trainingOutput;
  final String? modelArchitecture;

  const BiotrainerTrainingState(super.stateInformation, super.status, this.trainingOutput, this.modelArchitecture);

  const BiotrainerTrainingState.idle()
      : trainingOutput = const [],
        modelArchitecture = null,
        super.idle();

  @override
  List<Object?> get props => [trainingOutput.length, modelArchitecture, status];

  @override
  BiotrainerTrainingState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return BiotrainerTrainingState(stateInformation, status, trainingOutput, modelArchitecture);
  }

  @override
  BiotrainerTrainingState copyWith({required Map<String, dynamic> copyMap}) {
    return BiotrainerTrainingState(stateInformation, status, copyMap["trainingOutput"] ?? trainingOutput,
        copyMap["modelArchitecture"] ?? modelArchitecture);
  }
}

class BiotrainerTrainingBloc extends BiocentralUpdateBloc<BiotrainerTrainingEvent, BiotrainerTrainingState> {
  final PredictionModelRepository _predictionModelRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralClientRepository _biocentralClientRepository;

  BiotrainerTrainingBloc(this._predictionModelRepository, this._biocentralClientRepository,
      this._biocentralDatabaseRepository, this._biocentralProjectRepository, EventBus eventBus)
      : super(const BiotrainerTrainingState.idle(), eventBus) {
    on<BiotrainerTrainingStartTrainingEvent>((event, emit) async {
      BiocentralDatabase? database = _biocentralDatabaseRepository.getFromType(event.biocentralDatabaseType);

      if (database == null) {
        emit(state.setErrored(information: "Could not find database to train model!"));
      } else {
        TrainBiotrainerModelCommand trainBiotrainerModelCommand = TrainBiotrainerModelCommand(
            biocentralProjectRepository: _biocentralProjectRepository,
            biocentralDatabase: database,
            predictionModelRepository: _predictionModelRepository,
            predictionModelsClient: _biocentralClientRepository.getServiceClient<PredictionModelsClient>(),
            trainingConfiguration: event.trainingConfiguration);
        await trainBiotrainerModelCommand
            .executeWithLogging<BiotrainerTrainingState>(_biocentralProjectRepository, state)
            .forEach((either) {
          either.match((l) => emit(l), (r) => updateDatabases()); // Ignore result here
        });
      }
    });
  }
}
