import 'package:biocentral/plugins/active_learning/domain/al_repository.dart';
import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

sealed class ALHubEvent {}

final class _ALHubLoadInternalEvent extends ALHubEvent {
  final List<ALCampaign> campaigns;

  _ALHubLoadInternalEvent(this.campaigns);
}


@immutable
final class ALHubState extends Equatable {
  final List<ALCampaign> campaigns;

  const ALHubState(this.campaigns);

  const ALHubState.initial() : campaigns = const [];

  const ALHubState.loaded(this.campaigns);

  @override
  List<Object?> get props => [campaigns];
}

class ALHubBloc extends Bloc<ALHubEvent, ALHubState> {
  final BiocentralProjectRepository _projectRepository;
  final ALRepository _alRepository;

  ALHubBloc(this._projectRepository, this._alRepository) : super(const ALHubState.initial()) {
    on<_ALHubLoadInternalEvent>((event, emit) async {
      emit(ALHubState.loaded(event.campaigns));
    });

    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    _alRepository.databaseStream.listen((campaigns) {
      add(_ALHubLoadInternalEvent(campaigns));
    });
  }
}
