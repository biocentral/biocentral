import 'dart:async';

import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// Sections available in the engineering workspace.
enum EngineeringSection { overview, rounds, history, lineage, mutations, newCampaign, settings }

sealed class EngineeringHubEvent {}

final class _CampaignsChanged extends EngineeringHubEvent {
  final List<EngineeringCampaign> campaigns;
  _CampaignsChanged(this.campaigns);
}

final class EngineeringCampaignSelected extends EngineeringHubEvent {
  final String id;
  EngineeringCampaignSelected(this.id);
}

final class EngineeringSectionSelected extends EngineeringHubEvent {
  final EngineeringSection section;
  final int? roundIndex;
  EngineeringSectionSelected(this.section, {this.roundIndex});
}

/// Immutable repository snapshot and coordinated navigation state.
final class EngineeringHubState extends Equatable {
  final List<EngineeringCampaign> campaigns;
  final String? selectedId;
  final EngineeringSection section;
  final int? roundIndex;

  const EngineeringHubState({
    required this.campaigns,
    this.selectedId,
    this.section = EngineeringSection.overview,
    this.roundIndex,
  });

  EngineeringCampaign? get selectedCampaign {
    for (final campaign in campaigns) {
      if (campaign.id == selectedId) return campaign;
    }
    return null;
  }

  @override
  List<Object?> get props => [campaigns, selectedId, section, roundIndex];
}

/// Observes campaign revisions without depending on other Blocs.
class EngineeringHubBloc extends Bloc<EngineeringHubEvent, EngineeringHubState> {
  late final StreamSubscription<List<EngineeringCampaign>> _subscription;

  EngineeringHubBloc(EngineeringRepository repository)
    : super(
        EngineeringHubState(
          campaigns: repository.toStreamable(),
          selectedId: repository.toStreamable().firstOrNull?.id,
        ),
      ) {
    on<_CampaignsChanged>((event, emit) {
      final retained = event.campaigns.any((campaign) => campaign.id == state.selectedId);
      emit(
        EngineeringHubState(
          campaigns: event.campaigns,
          selectedId: retained ? state.selectedId : event.campaigns.firstOrNull?.id,
          section: retained ? state.section : EngineeringSection.overview,
          roundIndex: retained ? state.roundIndex : null,
        ),
      );
    });
    on<EngineeringCampaignSelected>((event, emit) {
      if (!state.campaigns.any((campaign) => campaign.id == event.id)) return;
      emit(EngineeringHubState(campaigns: state.campaigns, selectedId: event.id));
    });
    on<EngineeringSectionSelected>((event, emit) {
      final count = state.selectedCampaign?.rounds.length ?? 0;
      emit(
        EngineeringHubState(
          campaigns: state.campaigns,
          selectedId: state.selectedId,
          section: event.section,
          roundIndex: count == 0 ? null : (event.roundIndex ?? state.roundIndex)?.clamp(0, count - 1),
        ),
      );
    });
    _subscription = repository.databaseStream.listen((campaigns) => add(_CampaignsChanged(campaigns)));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
