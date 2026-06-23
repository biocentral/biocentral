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

final class ALHubState extends Equatable {
  final List<ALCampaign> campaigns;
  final ALCampaign? selectedCampaign;
  final Map<String, Protein> proteinDatabase;
  // Snapshot of selected campaign's iteration count at state-creation time.
  // ALCampaign is mutable, so including its reference in props would always
  // compare as equal after an in-place mutation. This int is captured once and
  // lets Equatable detect that iteration results were added.
  final int _selectedCampaignIterationCount;

  ALHubState({required this.campaigns, required this.proteinDatabase, this.selectedCampaign}) : _selectedCampaignIterationCount = selectedCampaign?.iterationResults.length ?? 0;

  ALHubState.initial() : campaigns = const [], proteinDatabase = const <String, Protein>{}, selectedCampaign = null, _selectedCampaignIterationCount = 0;

  ALHubState.loaded({required this.campaigns, required this.proteinDatabase, this.selectedCampaign}) : _selectedCampaignIterationCount = selectedCampaign?.iterationResults.length ?? 0;

  @override
  List<Object?> get props => [campaigns, proteinDatabase, selectedCampaign, _selectedCampaignIterationCount];
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

      emit(ALHubState.loaded(campaigns: event.campaigns, proteinDatabase: state.proteinDatabase, selectedCampaign: selected));
    });

    on<_ALHubProteinUpdateInternalEvent>((event, emit) async {
      emit(ALHubState.loaded(campaigns: state.campaigns, proteinDatabase: event.proteinDatabase, selectedCampaign: state.selectedCampaign));
    });

    on<ALHubSelectCampaignEvent>((event, emit) {
      emit(ALHubState.loaded(campaigns: state.campaigns, selectedCampaign: event.campaign, proteinDatabase: state.proteinDatabase));
    });

    _setupSubscriptions();
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
