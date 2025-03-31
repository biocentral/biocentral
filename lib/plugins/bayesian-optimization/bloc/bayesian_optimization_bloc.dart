import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_commands.dart';
import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/bayesian_optimization_training_dialog_bloc.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BayesianOptimizationEvent {}

class BayesianOptimizationInitial extends BayesianOptimizationEvent {
  BayesianOptimizationInitial();
}

class BayesianOptimizationLoadPreviousTrainings extends BayesianOptimizationEvent {
  BayesianOptimizationLoadPreviousTrainings();
}

class BayesianOptimizationTrainingStarted extends BayesianOptimizationEvent {
  final BuildContext context;
  final TaskType? selectedTask;
  final String? selectedFeature;
  final BayesianOptimizationModelTypes? selectedModel;
  final double exploitationExplorationValue;
  final PredefinedEmbedder? selectedEmbedder;
  final String? optimizationType;
  final double? targetValue;
  final double? targetRangeMin;
  final double? targetRangeMax;
  final bool? desiredBooleanValue;

  BayesianOptimizationTrainingStarted(
    this.context,
    this.selectedTask,
    this.selectedFeature,
    this.selectedModel,
    this.exploitationExplorationValue,
    this.selectedEmbedder, {
    this.optimizationType,
    this.targetValue,
    this.targetRangeMin,
    this.targetRangeMax,
    this.desiredBooleanValue,
  });
}

@immutable
final class BayesianOptimizationState extends BiocentralCommandState<BayesianOptimizationState> {
  const BayesianOptimizationState(super.stateInformation, super.status);

  const BayesianOptimizationState.idle() : super.idle();

  @override
  BayesianOptimizationState newState(
    BiocentralCommandStateInformation stateInformation,
    BiocentralCommandStatus status,
  ) {
    return BayesianOptimizationState(stateInformation, status);
  }

  @override
  List<Object?> get props => [stateInformation, status];
}

class BayesianOptimizationBloc extends BiocentralBloc<BayesianOptimizationEvent, BayesianOptimizationState>
    with BiocentralSyncBloc, Effects<ReOpenColumnWizardEffect> {
  final BayesianOptimizationRepository _bayesianOptimizationRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralClientRepository _bioCentralClientRepository;

  BayesianOptimizationBloc(
    this._bayesianOptimizationRepository,
    this._biocentralProjectRepository,
    this._bioCentralClientRepository,
    EventBus eventBus,
    this._biocentralDatabaseRepository,
  ) : super(const BayesianOptimizationState.idle(), eventBus) {
    on<BayesianOptimizationTrainingStarted>(_onTrainingStarted);
    on<BayesianOptimizationLoadPreviousTrainings>(_onLoadPreviousTrainings);
  }

  List<BayesianOptimizationTrainingResult>? get previousResults =>
      _bayesianOptimizationRepository.previousTrainingResults;

  BayesianOptimizationTrainingResult? get currentResult => _bayesianOptimizationRepository.currentResult;

  Future<void> _onLoadPreviousTrainings(
    BayesianOptimizationLoadPreviousTrainings event,
    Emitter<BayesianOptimizationState> emit,
  ) async {
    emit(state.setOperating(information: 'Loading previous trainings...'));

    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ['csv'], type: FileType.custom, withData: kIsWeb);

    if (result != null) {
      _bayesianOptimizationRepository.previousTrainingResults = [];
      for (PlatformFile file in result.files) {
        _bayesianOptimizationRepository.addPickedPreviousTrainingResults(file.bytes);
      }
      emit(
        state.newState(
          const BiocentralCommandStateInformation(information: 'Previous Training Loaded'),
          BiocentralCommandStatus.finished,
        ),
      );
    } else {
      emit(state.setErrored(information: 'No file selected'));
    }
  }

  void _onTrainingStarted(
    BayesianOptimizationTrainingStarted event,
    Emitter<BayesianOptimizationState> emit,
  ) async {
    final BiocentralDatabase? biocentralDatabase = _biocentralDatabaseRepository.getFromType(Protein);
    if (biocentralDatabase == null) {
      emit(
        state.setErrored(
          information: 'Could not find the database for which to calculate embeddings!',
        ),
      );
    } else {
      final String databaseHash = await biocentralDatabase.getHash();
      Map<String, dynamic> config = {
        'database_hash': databaseHash,
        'model_type': event.selectedModel?.name,
        // 'selectedEmbedder': event.selectedEmbedder?.name, //TODO: Tell Shuze to add
        'coefficient': event.exploitationExplorationValue.toString()
      };
      // TODO: Tell Shuze to accept coefficient as string, and cast to flaot in backend

      // Discrete:
      if (event.selectedTask == TaskType.findHighestProbability) {
        config = {
          ...config,
          'discrete': true,
          'discrete_labels': ['true', 'false'],
          'discrete_targets': event.desiredBooleanValue.toString(),
        };
        // Continuous:
      } else {
        config = {
          ...config,
          'discrete': false,
          'target_interval_lb': event.targetRangeMin?.toString() ?? event.targetValue?.toString() ?? '',
          'target_interval_ub': event.targetRangeMax?.toString() ?? event.targetValue?.toString() ?? '',
          'value_preference': switch (event.optimizationType.toString()) {
            'Maximize' => 'maximize',
            'Minimize' => 'minimize',
            _ => 'neutral',
          },
        };
      }

      final command = TransferBOTrainingConfigCommand(
          biocentralProjectRepository: _biocentralProjectRepository,
          biocentralDatabase: biocentralDatabase,
          client: _bioCentralClientRepository.getServiceClient<BayesianOptimizationClient>(),
          trainingConfiguration: config,
          targetFeature: event.selectedFeature.toString());

      await command
          .executeWithLogging<BayesianOptimizationState>(
        _biocentralProjectRepository,
        const BayesianOptimizationState(
          BiocentralCommandStateInformation(information: ''),
          BiocentralCommandStatus.operating,
        ),
      )
          .forEach(
        (either) {
          either.match((l) => emit(l), (r) {
            //TODO: check if r can ba set and saved
            _bayesianOptimizationRepository.setCurrentResult(r);
            emit(
              state.setFinished(
                information: 'Training completed',
              ),
            );
          });
        },
      );
    }
  }
}
