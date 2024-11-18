import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/prediction_models/data/biotrainer_file_handler.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_client.dart';
import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class BiotrainerConfigEvent {}

final class BiotrainerConfigSelectDatabaseTypeEvent extends BiotrainerConfigEvent {
  final Type databaseType;

  BiotrainerConfigSelectDatabaseTypeEvent(this.databaseType);
}

final class BiotrainerConfigSelectProtocolEvent extends BiotrainerConfigEvent {
  final String selectedProtocol;

  BiotrainerConfigSelectProtocolEvent(this.selectedProtocol);
}

final class BiotrainerConfigSelectEmbedderEvent extends BiotrainerConfigEvent {
  final String embedderName;

  BiotrainerConfigSelectEmbedderEvent(this.embedderName);
}

final class BiotrainerConfigSelectTargetEvent extends BiotrainerConfigEvent {
  final String target;

  BiotrainerConfigSelectTargetEvent(this.target);
}

final class BiotrainerConfigCalculatedSetColumnEvent extends BiotrainerConfigEvent {
  final String columnName;

  BiotrainerConfigCalculatedSetColumnEvent({required this.columnName});
}

final class BiotrainerConfigSelectSetColumnEvent extends BiotrainerConfigEvent {
  final String setColumn;

  BiotrainerConfigSelectSetColumnEvent(this.setColumn);
}

final class BiotrainerConfigSelectModelEvent extends BiotrainerConfigEvent {
  final String model;

  BiotrainerConfigSelectModelEvent(this.model);
}

final class BiotrainerConfigChangeOptionalConfigEvent extends BiotrainerConfigEvent {
  final String optionName;
  final String newValue;

  BiotrainerConfigChangeOptionalConfigEvent(this.optionName, this.newValue);
}

final class BiotrainerConfigVerifyConfigEvent extends BiotrainerConfigEvent {}

final class BiotrainerConfigVerifyEvent extends BiotrainerConfigEvent {}

@immutable
final class BiotrainerConfigState extends Equatable {
  final List<String> availableProtocols;
  final Map<String, List<BiotrainerOption>> configOptionsByProtocol;
  final Set<String> availableTargets;
  final Set<String> availableSets;

  final String? selectedProtocol;
  final Type? selectedDatabaseType;
  final bool? proteinsHaveMissingSequences;

  final Map<String, String> currentConfiguration;

  final String? errorMessage;

  final BiotrainerConfigStatus status;

  const BiotrainerConfigState(
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.availableTargets,
    this.availableSets,
    this.selectedProtocol,
    this.selectedDatabaseType,
    this.proteinsHaveMissingSequences,
    this.currentConfiguration,
    this.errorMessage,
    this.status,
  );

  const BiotrainerConfigState.selectingDatabaseType()
      : selectedDatabaseType = null,
        availableProtocols = const [],
        configOptionsByProtocol = const {},
        availableTargets = const {},
        availableSets = const {},
        currentConfiguration = const {},
        proteinsHaveMissingSequences = null,
        selectedProtocol = '',
        errorMessage = '',
        status = BiotrainerConfigStatus.selectingDatabaseType;

  const BiotrainerConfigState.loadingProtocols(this.selectedDatabaseType)
      : availableProtocols = const [],
        configOptionsByProtocol = const {},
        availableTargets = const {},
        availableSets = const {},
        currentConfiguration = const {},
        proteinsHaveMissingSequences = null,
        selectedProtocol = '',
        errorMessage = '',
        status = BiotrainerConfigStatus.loadingProtocols;

  const BiotrainerConfigState.selectingProtocol(this.selectedDatabaseType, this.availableProtocols)
      : configOptionsByProtocol = const {},
        availableTargets = const {},
        availableSets = const {},
        currentConfiguration = const {},
        proteinsHaveMissingSequences = null,
        selectedProtocol = '',
        errorMessage = '',
        status = BiotrainerConfigStatus.selectingProtocol;

  const BiotrainerConfigState.loadingConfigOptions(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.selectedProtocol,
  )   : configOptionsByProtocol = const {},
        availableTargets = const {},
        availableSets = const {},
        currentConfiguration = const {},
        proteinsHaveMissingSequences = null,
        errorMessage = '',
        status = BiotrainerConfigStatus.loadingConfigOptions;

  const BiotrainerConfigState.selectingEmbeddings(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
  )   : availableTargets = const {},
        availableSets = const {},
        errorMessage = '',
        status = BiotrainerConfigStatus.selectingEmbeddings;

  const BiotrainerConfigState.selectingTarget(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
    this.availableTargets,
  )   : availableSets = const {},
        errorMessage = '',
        status = BiotrainerConfigStatus.selectingTarget;

  const BiotrainerConfigState.selectingSets(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
    this.availableTargets,
    this.availableSets,
  )   : errorMessage = '',
        status = BiotrainerConfigStatus.selectingSets;

  const BiotrainerConfigState.selectingModel(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
    this.availableTargets,
    this.availableSets,
  )   : errorMessage = '',
        status = BiotrainerConfigStatus.selectingModel;

  const BiotrainerConfigState.selectingOptionalConfig(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
    this.availableTargets,
    this.availableSets,
  )   : errorMessage = '',
        status = BiotrainerConfigStatus.selectingOptionalConfig;

  const BiotrainerConfigState.verifying(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
    this.availableTargets,
    this.availableSets,
  )   : errorMessage = '',
        status = BiotrainerConfigStatus.verifying;

  const BiotrainerConfigState.verified(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
    this.availableTargets,
    this.availableSets,
  )   : errorMessage = '',
        status = BiotrainerConfigStatus.verified;

  const BiotrainerConfigState.configError(
    this.selectedDatabaseType,
    this.availableProtocols,
    this.configOptionsByProtocol,
    this.currentConfiguration,
    this.selectedProtocol,
    this.proteinsHaveMissingSequences,
    this.availableTargets,
    this.availableSets,
    this.errorMessage,
  ) : status = BiotrainerConfigStatus.configError;

  const BiotrainerConfigState.errored(this.errorMessage)
      : selectedDatabaseType = null,
        availableProtocols = const [],
        configOptionsByProtocol = const {},
        availableTargets = const {},
        availableSets = const {},
        currentConfiguration = const {},
        proteinsHaveMissingSequences = null,
        selectedProtocol = '',
        status = BiotrainerConfigStatus.errored;

  Set<String> getProtocolsFrom(String to) {
    return availableProtocols
        .where((protocol) => protocol.contains('to_$to'))
        .map((protocol) => protocol.split('_').first)
        .toSet();
  }

  Set<String> getProtocolsTo(String from) {
    return availableProtocols
        .where((protocol) => protocol.contains('${from}_'))
        .map((protocol) => protocol.split('_').last)
        .toSet();
  }

  String? buildProtocolFromTo(String from, String to) {
    final String protocol = [from, to].join('_to_');
    if (availableProtocols.contains(protocol)) {
      return protocol;
    }
    return null;
  }

  Set<String> getAvailableModels() {
    // TODO Maybe move to biotrainer API
    return configOptionsByProtocol[selectedProtocol]
            ?.firstWhere((biotrainerOption) => biotrainerOption.name == 'model_choice')
            .possibleValues
            .toSet() ??
        {};
  }

  @override
  List<Object?> get props => [
        status,
        availableProtocols,
        availableTargets,
        availableSets,
        selectedDatabaseType,
        configOptionsByProtocol,
        currentConfiguration,
        selectedProtocol,
      ];
}

enum BiotrainerConfigStatus {
  selectingDatabaseType,
  loadingProtocols,
  selectingProtocol,
  loadingConfigOptions,
  selectingEmbeddings,
  selectingTarget,
  selectingSets,
  selectingModel,
  selectingOptionalConfig,
  verifying,
  verified,
  configError,
  errored
}

class BiotrainerConfigBloc extends Bloc<BiotrainerConfigEvent, BiotrainerConfigState> {
  final BiocentralDatabaseRepository _biocentralDatabaseRepository;
  final PredictionModelsClient _biotrainerTrainingClient;

  BiotrainerConfigBloc(this._biocentralDatabaseRepository, this._biotrainerTrainingClient)
      : super(const BiotrainerConfigState.selectingDatabaseType()) {
    on<BiotrainerConfigSelectDatabaseTypeEvent>((event, emit) async {
      emit(BiotrainerConfigState.loadingProtocols(event.databaseType));

      final availableProtocolsEither = await _biotrainerTrainingClient.getAvailableBiotrainerProtocols();
      availableProtocolsEither.match(
        (error) => emit(BiotrainerConfigState.errored(error.message)),
        (availableProtocols) => emit(BiotrainerConfigState.selectingProtocol(event.databaseType, availableProtocols)),
      );
    });

    on<BiotrainerConfigSelectProtocolEvent>((event, emit) async {
      final String selectedProtocol = event.selectedProtocol;

      emit(
        BiotrainerConfigState.loadingConfigOptions(
          state.selectedDatabaseType,
          state.availableProtocols,
          selectedProtocol,
        ),
      );

      final Map<String, List<BiotrainerOption>> configOptionsByProtocol = Map.from(state.configOptionsByProtocol);
      final Map<String, String> currentConfiguration = {};

      List<BiotrainerOption>? options = configOptionsByProtocol[selectedProtocol];

      if (options == null || options.isEmpty) {
        final configOptionsByProtocolEither =
            await _biotrainerTrainingClient.getBiotrainerConfigOptionsByProtocol(selectedProtocol);
        options = List.from(configOptionsByProtocolEither.getOrElse((l) => []));
      }

      if (options.isEmpty) {
        emit(const BiotrainerConfigState.errored('Could not load biotrainer config options!'));
      } else {
        configOptionsByProtocol[selectedProtocol] = options;

        for (BiotrainerOption biotrainerOption in configOptionsByProtocol[selectedProtocol]!) {
          currentConfiguration[biotrainerOption.name] = biotrainerOption.defaultValue;
        }

        // TODO Maybe move to biotrainer API
        currentConfiguration['protocol'] = selectedProtocol;
        if (state.selectedDatabaseType is Protein) {
          currentConfiguration['interaction'] = '';
        }

        // TODO Could be more generic
        bool? proteinsHaveMissingSequences;
        if (state.selectedDatabaseType == Protein) {
          final List<Map<String, dynamic>> entityMaps =
              _biocentralDatabaseRepository.getFromType(state.selectedDatabaseType)?.entitiesAsMaps() ?? [];
          proteinsHaveMissingSequences =
              entityMaps.any((entityMap) => entityMap['sequence']?.toString().isEmpty ?? true);
        }

        emit(
          BiotrainerConfigState.selectingEmbeddings(
            state.selectedDatabaseType,
            state.availableProtocols,
            configOptionsByProtocol,
            currentConfiguration,
            selectedProtocol,
            proteinsHaveMissingSequences,
          ),
        );
      }
    });

    on<BiotrainerConfigSelectEmbedderEvent>((event, emit) async {
      final Map<String, String> newConfiguration = Map<String, String>.from(state.currentConfiguration);
      newConfiguration['embedder_name'] = event.embedderName;

      final Set<String> availableAttributes = _biocentralDatabaseRepository
              .getFromType(state.selectedDatabaseType)
              ?.getAvailableAttributesForAllEntities() ??
          {};

      if (availableAttributes.isEmpty) {
        emit(const BiotrainerConfigState.errored('Could not find any possible targets for training!'));
      } else {
        emit(
          BiotrainerConfigState.selectingTarget(
            state.selectedDatabaseType,
            state.availableProtocols,
            state.configOptionsByProtocol,
            newConfiguration,
            state.selectedProtocol,
            state.proteinsHaveMissingSequences,
            availableAttributes,
          ),
        );
      }
    });

    on<BiotrainerConfigSelectTargetEvent>((event, emit) async {
      final Map<String, String> newConfiguration = Map<String, String>.from(state.currentConfiguration);
      newConfiguration['target_column'] = event.target;

      final Set<String> availableSets = await getAvailableSetsFromState();

      emit(
        BiotrainerConfigState.selectingSets(
          state.selectedDatabaseType,
          state.availableProtocols,
          state.configOptionsByProtocol,
          newConfiguration,
          state.selectedProtocol,
          state.proteinsHaveMissingSequences,
          state.availableTargets,
          availableSets,
        ),
      );
    });

    on<BiotrainerConfigCalculatedSetColumnEvent>((event, emit) async {
      // Get available sets
      final Set<String> availableSets = await getAvailableSetsFromState();

      // Automatically select newly generated set
      final Map<String, String> newConfiguration = Map<String, String>.from(state.currentConfiguration);
      newConfiguration['set_column'] = event.columnName;

      emit(
        BiotrainerConfigState.selectingModel(
          state.selectedDatabaseType,
          state.availableProtocols,
          state.configOptionsByProtocol,
          newConfiguration,
          state.selectedProtocol,
          state.proteinsHaveMissingSequences,
          state.availableTargets,
          availableSets,
        ),
      );
    });

    on<BiotrainerConfigSelectSetColumnEvent>((event, emit) async {
      final Map<String, String> newConfiguration = Map<String, String>.from(state.currentConfiguration);
      newConfiguration['set_column'] = event.setColumn;
      emit(
        BiotrainerConfigState.selectingModel(
          state.selectedDatabaseType,
          state.availableProtocols,
          state.configOptionsByProtocol,
          newConfiguration,
          state.selectedProtocol,
          state.proteinsHaveMissingSequences,
          state.availableTargets,
          state.availableSets,
        ),
      );
    });

    on<BiotrainerConfigSelectModelEvent>((event, emit) async {
      final Map<String, String> newConfiguration = Map<String, String>.from(state.currentConfiguration);
      newConfiguration['model_choice'] = event.model;
      emit(
        BiotrainerConfigState.selectingOptionalConfig(
          state.selectedDatabaseType,
          state.availableProtocols,
          state.configOptionsByProtocol,
          newConfiguration,
          state.selectedProtocol,
          state.proteinsHaveMissingSequences,
          state.availableTargets,
          state.availableSets,
        ),
      );
    });

    on<BiotrainerConfigChangeOptionalConfigEvent>((event, emit) async {
      final Map<String, String> newConfiguration = Map<String, String>.from(state.currentConfiguration);
      newConfiguration[event.optionName] = event.newValue;
      emit(
        BiotrainerConfigState.selectingOptionalConfig(
          state.selectedDatabaseType,
          state.availableProtocols,
          state.configOptionsByProtocol,
          newConfiguration,
          state.selectedProtocol,
          state.proteinsHaveMissingSequences,
          state.availableTargets,
          state.availableSets,
        ),
      );
    });

    on<BiotrainerConfigVerifyConfigEvent>((event, emit) async {
      final String configFile = BiotrainerFileHandler.biotrainerConfigurationToConfigFile(state.currentConfiguration);

      emit(
        BiotrainerConfigState.verifying(
          state.selectedDatabaseType,
          state.availableProtocols,
          state.configOptionsByProtocol,
          state.currentConfiguration,
          state.selectedProtocol,
          state.proteinsHaveMissingSequences,
          state.availableTargets,
          state.availableSets,
        ),
      );

      // TODO Refactor: shorten
      final errorEither = await _biotrainerTrainingClient.verifyBiotrainerConfig(configFile);
      errorEither.match(
          (exception) => emit(
                BiotrainerConfigState.configError(
                  state.selectedDatabaseType,
                  state.availableProtocols,
                  state.configOptionsByProtocol,
                  state.currentConfiguration,
                  state.selectedProtocol,
                  state.proteinsHaveMissingSequences,
                  state.availableTargets,
                  state.availableSets,
                  exception.message,
                ),
              ), (u) {
        emit(
          BiotrainerConfigState.verified(
            state.selectedDatabaseType,
            state.availableProtocols,
            state.configOptionsByProtocol,
            state.currentConfiguration,
            state.selectedProtocol,
            state.proteinsHaveMissingSequences,
            state.availableTargets,
            state.availableSets,
          ),
        );
      });
    });
  }

  Future<Set<String>> getAvailableSetsFromState() async {
    // TODO ERROR HANDLING
    return _biocentralDatabaseRepository
            .getFromType(state.selectedDatabaseType)
            ?.getAvailableSetColumnsForAllEntities() ??
        {};
  }
}
