import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

sealed class ALHubEvent {}

final class _ALHubLoadInternalEvent extends ALHubEvent {
  final List<ALCampaign> campaigns;

  _ALHubLoadInternalEvent(this.campaigns);
}

final class ALHubSelectCampaignEvent extends ALHubEvent {
  final ALCampaign? campaign;

  ALHubSelectCampaignEvent(this.campaign);
}

@immutable
final class ALHubState extends Equatable {
  final List<ALCampaign> campaigns;
  final ALCampaign? selectedCampaign;

  const ALHubState(this.campaigns, {this.selectedCampaign});

  const ALHubState.initial() : campaigns = const [], selectedCampaign = null;

  const ALHubState.loaded(this.campaigns, {this.selectedCampaign});

  @override
  List<Object?> get props => [campaigns, selectedCampaign];
}

class ALHubBloc extends Bloc<ALHubEvent, ALHubState> {
  final BiocentralProjectRepository _projectRepository;
  final ALRepository _alRepository;

  ALHubBloc(this._projectRepository, this._alRepository) : super(const ALHubState.initial()) {
    on<_ALHubLoadInternalEvent>((event, emit) async {
      if (event.campaigns.isEmpty) {
        emit(const ALHubState.initial());
        return;
      }
      final selectedName = state.selectedCampaign?.internalName();
      final selected = selectedName != null
          ? event.campaigns.firstWhereOrNull((c) => c.internalName() == selectedName) ?? event.campaigns.first
          : event.campaigns.first;
      emit(ALHubState.loaded(event.campaigns, selectedCampaign: selected));
    });

    on<ALHubSelectCampaignEvent>((event, emit) {
      emit(ALHubState.loaded(state.campaigns, selectedCampaign: event.campaign));
    });

    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    _alRepository.databaseStream.listen((campaigns) {
      add(_ALHubLoadInternalEvent(campaigns));
    });
  }
}
