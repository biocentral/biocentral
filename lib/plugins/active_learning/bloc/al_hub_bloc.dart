import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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

@immutable
final class ALHubState extends Equatable {
  final List<ALCampaign> campaigns;
  final ALCampaign? selectedCampaign;
  final Map<String, Protein> proteinDatabase;

  const ALHubState({required this.campaigns, required this.proteinDatabase, this.selectedCampaign});

  const ALHubState.initial() : campaigns = const [], proteinDatabase = const <String, Protein>{}, selectedCampaign = null;

  const ALHubState.loaded({required this.campaigns, required this.proteinDatabase, this.selectedCampaign});

  @override
  List<Object?> get props => [campaigns, proteinDatabase, selectedCampaign];
}

class ALHubBloc extends Bloc<ALHubEvent, ALHubState> {
  final BiocentralProjectRepository _projectRepository;
  final ALRepository _alRepository;
  final ProteinRepository _proteinRepository;

  ALHubBloc(this._projectRepository, this._alRepository, ProteinRepository _proteinRepository)
      : _proteinRepository = _proteinRepository,
        super(ALHubState(campaigns: const [],
          proteinDatabase: _proteinRepository.databaseToMap(),),) {
    on<_ALHubLoadInternalEvent>((event, emit) async {
      if (event.campaigns.isEmpty) {
        emit(const ALHubState.initial());
        return;
      }

      final selectedName = state.selectedCampaign?.internalName();
      final selected = selectedName != null
          ? event.campaigns.firstWhereOrNull((c) => c.internalName() == selectedName) ?? event.campaigns.first
          : event.campaigns.first;

      emit(ALHubState.loaded(campaigns: event.campaigns, proteinDatabase: state.proteinDatabase, selectedCampaign: selected));
    });

    on<_ALHubProteinUpdateInternalEvent>((event, emit) async {
      emit(ALHubState.loaded(campaigns: state.campaigns, proteinDatabase: event.proteinDatabase));
    });

    on<ALHubSelectCampaignEvent>((event, emit) {
      emit(ALHubState.loaded(state.campaigns, selectedCampaign: event.campaign));
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
