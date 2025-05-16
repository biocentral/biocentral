import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/bayesian-optimization/bloc/bayesian_optimization_commands.dart';
import 'package:biocentral/plugins/bayesian-optimization/data/bayesian_optimization_client.dart';
import 'package:biocentral/plugins/bayesian-optimization/domain/bayesian_optimization_repository.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_model_types.dart';
import 'package:biocentral/plugins/bayesian-optimization/model/bayesian_optimization_training_result.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/bayesian_optimization_training_dialog_bloc.dart';
import 'package:biocentral/plugins/bayesian-optimization/presentation/dialogs/start_bayesian_optimization_dialog.dart';
import 'package:biocentral/plugins/embeddings/data/predefined_embedders.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
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

  /// Constructor for starting Bayesian Optimization training.
  ///
  /// - [context]: The build context.
  /// - [selectedTask]: The selected task type.
  /// - [selectedFeature]: The feature to optimize.
  /// - [selectedModel]: The model type.
  /// - [exploitationExplorationValue]: The coefficient for exploitation vs. exploration.
  /// - [selectedEmbedder]: The selected embedder.
  /// - [optimizationType]: The optimization type (e.g., Maximize, Minimize).
  /// - [targetValue]: The target value for optimization.
  /// - [targetRangeMin]: The minimum value for the target range.
  /// - [targetRangeMax]: The maximum value for the target range.
  /// - [desiredBooleanValue]: The desired boolean value for discrete tasks.
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

class BayesianOptimizationIterateTraining extends BayesianOptimizationEvent {
  final BuildContext context;
  final BayesianOptimizationTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Bayesian Optimization training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  BayesianOptimizationIterateTraining(this.context, this.trainingResult, this.updateList);
}

class BayesianOptimizationDirectIterateTraining extends BayesianOptimizationEvent {
  final BuildContext context;
  final BayesianOptimizationTrainingResult trainingResult;
  final List<double?> updateList;

  /// Constructor for iterating Bayesian Optimization training.
  ///
  /// - [context]: The build context.
  /// - [trainingResult]: The training result to iterate from.
  /// - [updateList]: The list of values to update.
  BayesianOptimizationDirectIterateTraining(this.context, this.trainingResult, this.updateList);
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

class BayesianOptimizationBloc extends BiocentralBloc<BayesianOptimizationEvent, BayesianOptimizationState> {
  bool isOperationRunning = false; // Lock to prevent premature reset

  final BayesianOptimizationRepository _bayesianOptimizationRepository;
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralClientRepository _bioCentralClientRepository;
  final EventBus _eventBus;

  /// Constructor for Bayesian Optimization Bloc.
  ///
  /// - [_bayesianOptimizationRepository]: Repository for managing Bayesian Optimization data.
  /// - [_biocentralProjectRepository]: Repository for managing project data.
  /// - [_bioCentralClientRepository]: Repository for managing client data.
  /// - [eventBus]: Event bus for handling events.
  /// - [_biocentralDatabaseRepository]: Repository for managing database data.
  BayesianOptimizationBloc(
    this._bayesianOptimizationRepository,
    this._biocentralProjectRepository,
    this._bioCentralClientRepository,
    this._eventBus,
    this._biocentralDatabaseRepository,
  ) : super(const BayesianOptimizationState.idle(), _eventBus) {
    on<BayesianOptimizationTrainingStarted>(_onTrainingStarted);
    on<BayesianOptimizationLoadPreviousTrainings>(_onLoadPreviousTrainings);
    on<BayesianOptimizationIterateTraining>(_onIterateTraining);
    on<BayesianOptimizationDirectIterateTraining>(_onDirectIterateTraining);
  }

  BayesianOptimizationTrainingResult? get currentResult => _bayesianOptimizationRepository.currentResult;

  /// Updates protein lab values in the database based on training results
  Future<void> _updateProteinLabValues(
    BiocentralDatabase proteinDatabase,
    Map<String, dynamic> config,
    BayesianOptimizationTrainingResult trainingResult,
    List<double?> updateList,
  ) async {
    for (int i = 0; i < updateList.length; i++) {
      if (updateList[i] != null) {
        final String proteinId = trainingResult.results![i].proteinId!;
        final double? newvalue = updateList[i];
        if (newvalue != null) {
          final BioEntity? entity = proteinDatabase.getEntityById(proteinId);
          if (entity != null && entity is Protein) {
            final Map<String, String> newAttributes = Map.from(entity.attributes.toMap());
            newAttributes[config['feature_name']] = newvalue.toString();
            final Protein updatedProtein = entity.copyWith(attributes: CustomAttributes(newAttributes));
            proteinDatabase.updateEntity(proteinId, updatedProtein);
          }
        }
      }
    }
    _eventBus.fire(BiocentralDatabaseUpdatedEvent());
  }

  /// Extracts configuration values from the training result
  Map<String, dynamic> _extractConfigValues(Map<String, dynamic> config) {
    // Extract basic configuration values
    final bool isDiscrete = config['discrete'] == true;
    final String featureName = config['feature_name']?.toString() ?? '';
    final String modelType = config['model_type']?.toString() ?? '';
    final String coefficient = config['coefficient']?.toString() ?? '0.5';
    final String embedderName = config['embedder_name']?.toString() ?? '';

    // Get task type based on discrete flag
    final TaskType task = isDiscrete ? TaskType.findHighestProbability : TaskType.findOptimalValues;

    // Get model type with fallback to first available model
    final BayesianOptimizationModelTypes model = BayesianOptimizationModelTypes.values.firstWhere(
      (model) => model.name == modelType,
      orElse: () => BayesianOptimizationModelTypes.values.first,
    );

    // Get embedder with fallback to first available embedder
    final PredefinedEmbedder embedder = PredefinedEmbedderContainer.predefinedEmbedders().firstWhere(
      (embedder) => embedder.biotrainerName == embedderName,
      orElse: () => PredefinedEmbedderContainer.predefinedEmbedders().first,
    );

    // Parse exploitation/exploration coefficient
    final double exploitationExploration = double.tryParse(coefficient) ?? 0.5;

    // Handle discrete vs continuous optimization
    if (isDiscrete) {
      final bool desiredBooleanValue = config['discrete_targets']?.contains('1') ?? false;
      return {
        'task': task,
        'feature': featureName,
        'model': model,
        'exploitationExploration': exploitationExploration,
        'embedder': embedder,
        'desiredBooleanValue': desiredBooleanValue,
      };
    }

    // Handle continuous optimization
    final String optimizationMode = config['optimization_mode']?.toString() ?? '';
    final String targetValue = config['target_value']?.toString() ?? '';
    final String targetLb = config['target_lb']?.toString() ?? '-Infinity';
    final String targetUb = config['target_ub']?.toString() ?? 'Infinity';

    final String optimizationType = switch (optimizationMode) {
      'maximize' => 'Maximize',
      'minimize' => 'Minimize',
      'interval' => 'Target Range',
      'value' => 'Target Value',
      _ => 'Maximize', // Default to maximize if unknown
    };

    return {
      'task': task,
      'feature': featureName,
      'model': model,
      'exploitationExploration': exploitationExploration,
      'embedder': embedder,
      'optimizationType': optimizationType,
      'targetValue': double.tryParse(targetValue),
      'targetRangeMin': double.tryParse(targetLb),
      'targetRangeMax': double.tryParse(targetUb),
    };
  }

  /// Starts training with the given configuration
  void _startTraining(
    BuildContext context,
    Map<String, dynamic> config,
  ) {
    add(
      BayesianOptimizationTrainingStarted(
        context,
        config['task'],
        config['feature'],
        config['model'],
        config['exploitationExploration'],
        config['embedder'],
        optimizationType: config['optimizationType'],
        targetValue: config['targetValue'],
        targetRangeMin: config['targetRangeMin'],
        targetRangeMax: config['targetRangeMax'],
        desiredBooleanValue: config['desiredBooleanValue'],
      ),
    );
  }

  /// Handles the loading of previous training results.
  ///
  /// - [event]: The event to load previous trainings.
  /// - [emit]: Emits the new state.
  Future<void> _onLoadPreviousTrainings(
    BayesianOptimizationLoadPreviousTrainings event,
    Emitter<BayesianOptimizationState> emit,
  ) async {
    emit(state.setOperating(information: 'Loading previous trainings...'));

    final FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ['json'], type: FileType.custom, withData: kIsWeb);

    if (result != null) {
      _bayesianOptimizationRepository.addPickedPreviousTrainingResults(result.files.first.bytes);
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

  /// Handles the start of Bayesian Optimization training.
  ///
  /// - [event]: The event to start training.
  /// - [emit]: Emits the new state.
  void _onTrainingStarted(
    BayesianOptimizationTrainingStarted event,
    Emitter<BayesianOptimizationState> emit,
  ) async {
    isOperationRunning = true; // Lock the status

    final BiocentralDatabase? biocentralDatabase = _biocentralDatabaseRepository.getFromType(Protein);
    if (biocentralDatabase == null) {
      isOperationRunning = false; // Release the lock
      emit(
        state.setErrored(
          information: 'Could not find the database for which to calculate embeddings!',
        ),
      );
    } else {
      _bayesianOptimizationRepository.clearCurrentResult();

      final String databaseHash = await biocentralDatabase.getHash();
      Map<String, dynamic> config = {
        'database_hash': databaseHash,
        'optimization_mode': switch (event.optimizationType) {
          'Maximize' => 'maximize',
          'Minimize' => 'minimize',
          'Target Range' => 'interval',
          'Target Value' => 'value',
          _ => 'value',
        },
        'model_type': event.selectedModel?.name,
        // Does not support other embedders than One_hot. Backend loads indefinitely
        'embedder_name': event.selectedEmbedder?.biotrainerName,
        'feature_name': event.selectedFeature.toString(),
        'coefficient': event.exploitationExplorationValue.toString(),
      };

      // Discrete:
      if (event.selectedTask == TaskType.findHighestProbability) {
        config = {
          ...config,
          'discrete': true,
          'discrete_labels': ['0', '1'],
          'discrete_targets': event.desiredBooleanValue.toString().toLowerCase() == 'true' ? ['1'] : ['0'],
        };
        // Continuous:
      } else {
        config = {
          ...config,
          'discrete': false,
          'target_lb': event.targetRangeMin?.toString() ?? event.targetValue?.toString() ?? '-Infinity',
          'target_ub': event.targetRangeMax?.toString() ?? event.targetValue?.toString() ?? 'Infinity',
          'target_value': switch (event.optimizationType.toString()) {
            'Target Value' => event.targetValue.toString(),
            _ => '',
          },
        };
      }

      final command = TransferBOTrainingConfigCommand(
        biocentralDatabase: biocentralDatabase,
        client: _bioCentralClientRepository.getServiceClient<BayesianOptimizationClient>(),
        trainingConfiguration: config,
        targetFeature: event.selectedFeature.toString(),
      );

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
            _bayesianOptimizationRepository.setCurrentResult(r);
            emit(
              state.setFinished(
                information: 'Training completed',
              ),
            );
            isOperationRunning = false; // Release the lock
          });
        },
      );
    }
  }

  /// Handles the iteration of Bayesian Optimization training.
  ///
  /// - [event]: The event containing the training result to iterate from.
  /// - [emit]: Emits the new state.
  Future<void> _onIterateTraining(
    BayesianOptimizationIterateTraining event,
    Emitter<BayesianOptimizationState> emit,
  ) async {
    emit(state.setOperating(information: 'Updating database and preparing next iteration...'));
    final config = event.trainingResult.trainingConfig ?? {};

    final BiocentralDatabase? proteinDatabase = _biocentralDatabaseRepository.getFromType(Protein);
    if (proteinDatabase == null) {
      emit(state.setErrored(information: 'Could not find protein database!'));
      return;
    }

    await _updateProteinLabValues(proteinDatabase, config, event.trainingResult, event.updateList);

    final configValues = _extractConfigValues(config);

    showDialog(
      context: event.context,
      builder: (BuildContext context) {
        return StartBOTrainingDialog(
          (
            TaskType? selectedTask,
            String? selectedFeature,
            BayesianOptimizationModelTypes? selectedModel,
            double exploitationExplorationValue,
            PredefinedEmbedder? selectedEmbedder, {
            String? optimizationType,
            double? targetValue,
            double? targetRangeMin,
            double? targetRangeMax,
            bool? desiredBooleanValue,
          }) {
            add(
              BayesianOptimizationTrainingStarted(
                event.context,
                selectedTask,
                selectedFeature,
                selectedModel,
                exploitationExplorationValue,
                selectedEmbedder,
                optimizationType: optimizationType,
                targetValue: targetValue,
                targetRangeMin: targetRangeMin,
                targetRangeMax: targetRangeMax,
                desiredBooleanValue: desiredBooleanValue,
              ),
            );
          },
          initialTask: configValues['task'],
          initialFeature: configValues['feature'],
          initialModel: configValues['model'],
          initialExploitationExploration: configValues['exploitationExploration'],
          initialEmbedder: configValues['embedder'],
          initialOptimizationType: configValues['optimizationType'],
          initialTargetValue: configValues['targetValue'],
          initialTargetRangeMin: configValues['targetRangeMin'],
          initialTargetRangeMax: configValues['targetRangeMax'],
          initialDesiredBooleanValue: configValues['desiredBooleanValue'],
        );
      },
    );
    emit(state.setFinished(information: 'Database updated and training dialog shown'));
  }

  Future<void> _onDirectIterateTraining(
    BayesianOptimizationDirectIterateTraining event,
    Emitter<BayesianOptimizationState> emit,
  ) async {
    emit(state.setOperating(information: 'Updating database and preparing next iteration...'));
    final config = event.trainingResult.trainingConfig ?? {};

    final BiocentralDatabase? proteinDatabase = _biocentralDatabaseRepository.getFromType(Protein);
    if (proteinDatabase == null) {
      emit(state.setErrored(information: 'Could not find protein database!'));
      return;
    }

    await _updateProteinLabValues(proteinDatabase, config, event.trainingResult, event.updateList);

    final configValues = _extractConfigValues(config);
    _startTraining(event.context, configValues);

    emit(state.setFinished(information: 'Database updated and training started'));
  }
}
