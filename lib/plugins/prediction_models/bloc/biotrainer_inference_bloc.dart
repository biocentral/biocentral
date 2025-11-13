import 'package:biocentral/plugins/prediction_models/bloc/models_commands.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

sealed class BiotrainerInferenceEvent {}

final class BiotrainerInferenceStartInferenceEvent extends BiotrainerInferenceEvent {
  final PredictionModel predictionModel;
  final Set<String> selectedEntityIDs;

  BiotrainerInferenceStartInferenceEvent(this.predictionModel, this.selectedEntityIDs);
}

@immutable
final class BiotrainerInferenceState extends BiocentralCommandState<BiotrainerInferenceState> {
  final PredictionModel? predictingModel;
  final Map<String, dynamic>? predictions;

  const BiotrainerInferenceState(
    super.stateInformation,
    super.status,
    this.predictingModel,
    this.predictions,
  );

  const BiotrainerInferenceState.idle()
      : predictingModel = null,
        predictions = null,
        super.idle();

  @override
  List<Object?> get props => [stateInformation, status, predictingModel, predictions];

  @override
  BiotrainerInferenceState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return BiotrainerInferenceState(
      stateInformation,
      status,
      predictingModel,
      predictions,
    );
  }

  @override
  BiotrainerInferenceState copyWith({required Map<String, dynamic> copyMap}) {
    return BiotrainerInferenceState(
      stateInformation,
      status,
      predictingModel,
      copyMap['predictions'] ?? predictions,
    );
  }
}

class BiotrainerInferenceBloc extends BiocentralBloc<BiotrainerInferenceEvent, BiotrainerInferenceState>
    with BiocentralUpdateBloc {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralAPIRepository _apiRepository;

  BiotrainerInferenceBloc(
    this._biocentralProjectRepository,
    this._biocentralDatabaseRepository,
    this._apiRepository,
    EventBus eventBus,
  ) : super(const BiotrainerInferenceState.idle(), eventBus) {
    on<BiotrainerInferenceStartInferenceEvent>((event, emit) async {
      final databaseType = _biocentralDatabaseRepository.getAvailableTypes()[event.predictionModel.databaseType];
      final BiocentralDatabase? database = _biocentralDatabaseRepository.getFromType(databaseType);

      if (database == null) {
        emit(state.setErrored(information: 'Could not find database for inference!'));
      } else {
        final BiotrainerInferenceCommand inferenceCommand = BiotrainerInferenceCommand(
          biocentralDatabase: database,
          apiRepository: _apiRepository,
          predictionModel: event.predictionModel,
          selectedEntityIDs: event.selectedEntityIDs,
        );
        await inferenceCommand
            .executeWithLogging<BiotrainerInferenceState>(_biocentralProjectRepository, state)
            .forEach((either) {
          either.match((l) => emit(l), (r) => updateDatabases()); // Ignore result here
        });
      }
    });
  }
}
