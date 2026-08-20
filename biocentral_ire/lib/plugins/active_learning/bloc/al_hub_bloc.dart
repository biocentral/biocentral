import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

sealed class ALHubEvent {}

final class _ALHubLoadInternalEvent extends ALHubEvent {
  final List<ALCampaign> campaigns;

  _ALHubLoadInternalEvent({required this.campaigns});
}

final class ALHubSelectCampaignEvent extends ALHubEvent {
  final ALCampaign? campaign;

  ALHubSelectCampaignEvent(this.campaign);
}

final class _ALHubProteinUpdateInternalEvent extends ALHubEvent {
  final Map<String, Protein> proteinDatabase;

  _ALHubProteinUpdateInternalEvent({required this.proteinDatabase});
}

enum ALDatasetChangeStatus {
  none,
  suggestionsMissing,
  columnMissing,
}

final class ALHubState extends Equatable {
  final List<ALCampaign> campaigns;
  final ALCampaign? selectedCampaign;
  final Map<String, Protein> proteinDatabase;
  final ALDatasetChangeStatus datasetChangeStatus;
  final int _selectedCampaignIterationCount;

  ALHubState({
    required this.campaigns,
    required this.proteinDatabase,
    this.selectedCampaign,
    this.datasetChangeStatus = ALDatasetChangeStatus.none,
  }) : _selectedCampaignIterationCount = selectedCampaign?.iterationResults.length ?? 0;

  ALHubState.initial()
      : campaigns = const [],
        proteinDatabase = const <String, Protein>{},
        selectedCampaign = null,
        _selectedCampaignIterationCount = 0,
        datasetChangeStatus = ALDatasetChangeStatus.none;

  ALHubState.loaded({
    required this.campaigns,
    required this.proteinDatabase,
    this.selectedCampaign,
    this.datasetChangeStatus = ALDatasetChangeStatus.none,
  }) : _selectedCampaignIterationCount = selectedCampaign?.iterationResults.length ?? 0;

  int get selectedCampaignIterationCount => _selectedCampaignIterationCount;

  @override
  List<Object?> get props =>
      [campaigns, proteinDatabase, selectedCampaign, _selectedCampaignIterationCount, datasetChangeStatus];
}

class ALHubBloc extends Bloc<ALHubEvent, ALHubState> {
  final BiocentralProjectRepository _projectRepository;
  final ALRepository _alRepository;
  final ProteinRepository _proteinRepository;

  ALHubBloc(this._projectRepository, this._alRepository, ProteinRepository _proteinRepository)
      : _proteinRepository = _proteinRepository,
        super(ALHubState(campaigns: const [], proteinDatabase: _proteinRepository.databaseToMap())) {
    on<_ALHubLoadInternalEvent>((event, emit) async {
      if (event.campaigns.isEmpty) {
        emit(ALHubState.initial());
        return;
      }

      final selectedName = state.selectedCampaign?.internalName();
      final selected = selectedName != null
          ? event.campaigns.firstWhereOrNull((c) => c.internalName() == selectedName) ?? event.campaigns.first
          : event.campaigns.first;

      emit(
        ALHubState.loaded(
          campaigns: event.campaigns,
          proteinDatabase: state.proteinDatabase,
          selectedCampaign: selected,
          datasetChangeStatus: _detectDatasetChange(selected, state.proteinDatabase),
        ),
      );
    });

    on<_ALHubProteinUpdateInternalEvent>((event, emit) async {
      emit(
        ALHubState.loaded(
          campaigns: state.campaigns,
          proteinDatabase: event.proteinDatabase,
          selectedCampaign: state.selectedCampaign,
          datasetChangeStatus: _detectDatasetChange(state.selectedCampaign, event.proteinDatabase),
        ),
      );
    });

    on<ALHubSelectCampaignEvent>((event, emit) {
      emit(
        ALHubState.loaded(
          campaigns: state.campaigns,
          selectedCampaign: event.campaign,
          proteinDatabase: state.proteinDatabase,
          datasetChangeStatus: _detectDatasetChange(event.campaign, state.proteinDatabase),
        ),
      );
    });

    _setupSubscriptions();
  }

  static ALDatasetChangeStatus _detectDatasetChange(ALCampaign? campaign, Map<String, Protein> database) {
    if (campaign == null || campaign.iterationResults.isEmpty || database.isEmpty) {
      return ALDatasetChangeStatus.none;
    }

    final columnExists = database.values.any((p) => p.attributes.containsKey(campaign.columnName));
    if (!columnExists) return ALDatasetChangeStatus.columnMissing;

    final lastSuggestions = campaign.iterationResults.last.$2.suggestions.toSet();
    if (lastSuggestions.isNotEmpty && lastSuggestions.any((id) => !database.containsKey(id))) {
      return ALDatasetChangeStatus.suggestionsMissing;
    }

    return ALDatasetChangeStatus.none;
  }

  void _setupSubscriptions() {
    _alRepository.databaseStream.listen((campaigns) {
      add(_ALHubLoadInternalEvent(campaigns: campaigns));
    });

    _proteinRepository.databaseStream.listen((_) {
      add(_ALHubProteinUpdateInternalEvent(proteinDatabase: _proteinRepository.databaseToMap()));
    });
  }
}
