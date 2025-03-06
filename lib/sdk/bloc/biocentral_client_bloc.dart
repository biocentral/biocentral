import 'dart:async';

import 'package:biocentral/sdk/bloc/biocentral_state.dart';
import 'package:biocentral/sdk/data/biocentral_client.dart';
import 'package:biocentral/sdk/data/biocentral_server_data.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

sealed class BiocentralClientEvent {}

final class BiocentralClientConnectEvent extends BiocentralClientEvent {
  final BiocentralServerData server;

  BiocentralClientConnectEvent({required this.server});
}

final class BiocentralClientDisconnectEvent extends BiocentralClientEvent {
  final BiocentralServerData server;

  BiocentralClientDisconnectEvent({required this.server});
}

final class BiocentralClientLoadDataEvent extends BiocentralClientEvent {
  BiocentralClientLoadDataEvent();
}

final class BiocentralClientDownloadLocalServerEvent extends BiocentralClientEvent {
  final String os;
  final String serverURL;

  BiocentralClientDownloadLocalServerEvent(this.os, this.serverURL);
}

final class BiocentralClientLaunchLocalServerEvent extends BiocentralClientEvent {
  final String executableFilePath;

  BiocentralClientLaunchLocalServerEvent(this.executableFilePath);
}

final class BiocentralClientLaunchExistingLocalServerEvent extends BiocentralClientEvent {
  BiocentralClientLaunchExistingLocalServerEvent();
}

@immutable
final class BiocentralClientState extends BiocentralCommandState<BiocentralClientState> {
  final BiocentralServerData? connectedServer;

  final Set<BiocentralServerData> availableServersToConnect;

  const BiocentralClientState(
      super.stateInformation, super.status, this.connectedServer, this.availableServersToConnect);

  const BiocentralClientState.idle()
      : connectedServer = null,
        availableServersToConnect = const {},
        super.idle();

  @override
  List<Object?> get props => [
        super.stateInformation,
        super.status,
        connectedServer,
        availableServersToConnect,
      ];

  @override
  BiocentralClientState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return BiocentralClientState(
      stateInformation,
      status,
      connectedServer,
      availableServersToConnect,
    );
  }

  @override
  BiocentralClientState copyWith({Map<String, dynamic>? copyMap}) {
    return BiocentralClientState(
      stateInformation,
      status,
      copyMap?['connectedServer'] ?? connectedServer,
      copyMap?['availableServersToConnect'] ?? availableServersToConnect,
    );
  }

  BiocentralClientState disconnect() {
    return BiocentralClientState(
      stateInformation,
      status,
      null,
      availableServersToConnect,
    );
  }
}

class BiocentralClientBloc extends Bloc<BiocentralClientEvent, BiocentralClientState> {
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;

  BiocentralClientBloc(this._biocentralClientRepository, this._biocentralProjectRepository)
      : super(const BiocentralClientState.idle()) {
    on<BiocentralClientLoadDataEvent>((event, emit) async {
      // Get available servers
      emit(state.setOperating(information: 'Searching for available servers..'));
      final availableServers = await _biocentralClientRepository.getAvailableServers();
      if (availableServers.isEmpty) {
        emit(state.setErrored(information: 'Could not find any available servers!'));
      } else {
        emit(state.copyWith(copyMap: {'availableServersToConnect': availableServers}));
      }
      emit(state.setIdle());
    });

    on<BiocentralClientConnectEvent>((event, emit) async {
      emit(state.setOperating(information: 'Connecting to server..'));

      await _connectToServer(event.server, emit);
    });

    on<BiocentralClientDisconnectEvent>((event, emit) async {
      emit(state.setOperating(information: 'Disconnecting from server..'));
      emit(state.setFinished(information: 'Disconnected from server!').disconnect());
    });
  }

  Future<void> _connectToServer(BiocentralServerData server, Emitter<BiocentralClientState> emit) async {
    final connectedEither = await _biocentralClientRepository.connectToServer(server);
    await connectedEither.match((error) async {
      emit(state.setErrored(information: 'Could not connect to server!').disconnect());
    }, (u) async {
      emit(
        state.setFinished(information: 'Finished connecting to server!').copyWith(
          copyMap: {
            'connectedServer': server,
          },
        ),
      );
    });
  }
}
