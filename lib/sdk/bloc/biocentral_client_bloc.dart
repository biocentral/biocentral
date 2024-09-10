import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../data/biocentral_client.dart';
import '../data/biocentral_local_server.dart';
import '../data/biocentral_server_data.dart';
import '../domain/biocentral_project_repository.dart';
import '../util/biocentral_exception.dart';
import '../util/logging.dart';
import 'biocentral_state.dart';

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

  final Map<String, String> serverDownloadURLs;
  final Map<String, String> downloadedExecutablePaths;

  final String? extractedExecutablePath;

  const BiocentralClientState(
      super.stateInformation,
      super.status,
      this.connectedServer,
      this.availableServersToConnect,
      this.serverDownloadURLs,
      this.downloadedExecutablePaths,
      this.extractedExecutablePath);

  const BiocentralClientState.idle()
      : connectedServer = null,
        availableServersToConnect = const {},
        serverDownloadURLs = const {},
        downloadedExecutablePaths = const {},
        extractedExecutablePath = null,
        super.idle();

  @override
  List<Object?> get props => [
        super.stateInformation,
        super.status,
        connectedServer,
        availableServersToConnect,
        serverDownloadURLs,
        downloadedExecutablePaths,
        extractedExecutablePath
      ];

  @override
  BiocentralClientState newState(BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return BiocentralClientState(stateInformation, status, connectedServer, availableServersToConnect,
        serverDownloadURLs, downloadedExecutablePaths, extractedExecutablePath);
  }

  @override
  BiocentralClientState copyWith({Map<String, dynamic>? copyMap}) {
    return BiocentralClientState(
        stateInformation,
        status,
        copyMap?["connectedServer"] ?? connectedServer,
        copyMap?["availableServersToConnect"] ?? availableServersToConnect,
        copyMap?["serverDownloadURLs"] ?? serverDownloadURLs,
        copyMap?["downloadedExecutablePaths"] ?? downloadedExecutablePaths,
        copyMap?["extractedExecutablePath"] ?? extractedExecutablePath);
  }

  BiocentralClientState disconnect() {
    return BiocentralClientState(stateInformation, status, null, availableServersToConnect, serverDownloadURLs,
        downloadedExecutablePaths, extractedExecutablePath);
  }
}

class BiocentralClientBloc extends Bloc<BiocentralClientEvent, BiocentralClientState> {
  final BiocentralClientRepository _biocentralClientRepository;
  final BiocentralProjectRepository _biocentralProjectRepository;

  final String _serverDirectoryName = "biocentral_server";
  final String _serverExecutableName = "biocentral_server";

  BiocentralClientBloc(this._biocentralClientRepository, this._biocentralProjectRepository)
      : super(const BiocentralClientState.idle()) {
    on<BiocentralClientLoadDataEvent>((event, emit) async {
      // Get available servers
      emit(state.setOperating(information: "Searching for available servers.."));
      final availableServers = await _biocentralClientRepository.getAvailableServers();
      if (availableServers.isEmpty) {
        emit(state.setErrored(information: "Could not find any available servers!"));
      } else {
        emit(state.copyWith(copyMap: {"availableServersToConnect": availableServers}));
      }
      // Get executable download URLs
      if (state.serverDownloadURLs.isEmpty) {
        emit(state.setOperating(information: "Searching for available downloads.."));
        final urlEither = await _biocentralClientRepository.getLocalServerDownloadURLs();
        urlEither.match(
            (error) => emit(state.setErrored(information: "Could not download server release information!")),
            (result) => emit(state.copyWith(copyMap: {"serverDownloadURLs": result})));
      }
      // Check if .zips already exist in project directory:
      matchingFunction(filePath) {
        return state.serverDownloadURLs.keys
            .map((os) => filePath.toLowerCase().split("/").last.contains(os.toLowerCase()) ? os.toLowerCase() : null)
            .firstOrNull;
      }

      final Map<String, String> matchingZips =
          await _biocentralProjectRepository.getMatchingFilesInProjectDirectory(matchingFunction);
      if (matchingZips.isNotEmpty) {
        final Map<String, String> mergedPathMaps = Map.from(state.downloadedExecutablePaths)..addAll(matchingZips);
        emit(state.copyWith(copyMap: {"downloadedExecutablePaths": mergedPathMaps}));
      }
      // Check if executable already exists in project directory:
      if (_biocentralProjectRepository.doesPathExistInProjectDirectory(_getDefaultExecutableName())) {
        emit(state.setOperating(information: "Searching for available server executables.."));
        emit(state.copyWith(copyMap: {
          "extractedExecutablePath":
              _biocentralProjectRepository.getPathWithProjectDirectory(_getDefaultExecutableName())
        }));
      }
      emit(state.setIdle());
    });

    on<BiocentralClientDownloadLocalServerEvent>((event, emit) async {
      if (kIsWeb) {
        await launchUrlString(event.serverURL);
        emit(state.setFinished(
            information: "Download started in browser! Please extract the file "
                "afterwards and start the executable, then check the connection tab again."));
      } else {
        final String fileName = event.serverURL.split("/").last;

        emit(state.setOperating(information: "Downloading server executable.."));

        bool downloadCompleted = false;
        final byteStreamController = StreamController<List<int>>();

        try {
          // Write to disk in chunks
          final saveCompleter = Completer<Either<BiocentralException, String>>();
          final saveFuture = _biocentralProjectRepository
              .handleStreamSave(
            fileName: fileName,
            byteStream: byteStreamController.stream,
          )
              .then((result) {
            saveCompleter.complete(result);
            return result;
          });

          await for (final result in _biocentralClientRepository.downloadServerRelease(event.serverURL)) {
            await result.fold(
              (error) async {
                await byteStreamController.close();
                emit(state.setErrored(information: error.message));
              },
              (progress) async {
                byteStreamController.add(progress.bytes);

                emit(state.updateOperating(commandProgress: BiocentralCommandProgress.fromDownloadProgress(progress)));

                if (progress.isDone()) {
                  // Download complete
                  await byteStreamController.close();

                  final saveEither = await saveCompleter.future;
                  await saveEither.fold(
                    (error) async {
                      emit(state.setErrored(information: "Could not save downloaded file! Error: ${error.message}"));
                    },
                    (fullPath) async {
                      downloadCompleted = true;

                      emit(state.setFinished(
                          information: "Finished download of local server file",
                          commandProgress: BiocentralCommandProgress.fromDownloadProgress(progress)));
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!emit.isDone) {
                        Map<String, String> updatedExecutablePaths = Map.from(state.downloadedExecutablePaths);
                        updatedExecutablePaths[event.os] = fullPath;
                        emit(state.setIdle().copyWith(copyMap: {"downloadedExecutablePaths": updatedExecutablePaths}));
                      }
                    },
                  );
                }
              },
            );
          }

          // In case the download stream completes before the save operation
          if (!saveCompleter.isCompleted) {
            final saveResult = await saveFuture;
            saveCompleter.complete(saveResult);
          }
        } catch (e) {
          // Clean up the partial file if the download didn't complete
          if (!downloadCompleted) {
            final cleanUpEither = await _biocentralProjectRepository.cleanUpFailedDownload(fileName: fileName);
            cleanUpEither.match(
                (error) => logger.d("Error during clean up of partial downloaded file: ${error.message}"),
                (u) => logger.d("Cleaned up partial download file: $fileName"));
          }
          emit(state.setErrored(information: "An error occurred during download: $e"));
        } finally {
          byteStreamController.close();
        }
      }
    });

    on<BiocentralClientLaunchLocalServerEvent>((event, emit) async {
      emit(state.setOperating(information: "Extracting files.."));
      final extractionEither = await _biocentralProjectRepository.handleArchiveExtraction(
          archiveFilePath: event.executableFilePath, outDirectoryName: _serverDirectoryName);
      await extractionEither.match((error) async {
        emit(state.setErrored(information: "An error occurred during extraction. Error: ${error.message}"));
      }, (result) async {
        final String extractedExecutablePath =
            _biocentralProjectRepository.getPathWithProjectDirectory("$result/biocentral_server");

        emit(state
            .setOperating(information: "Launching local server..")
            .copyWith(copyMap: {"extractedExecutablePath": extractedExecutablePath}));

        final startEither = await BiocentralLocalServer().start(
            extractedExecutablePath: extractedExecutablePath,
            workingDirectory: _biocentralProjectRepository.getPathWithProjectDirectory(result));
        await startEither.match((l) async {
          emit(state.setErrored(information: l.message));
        }, (services) async {
          final localServerData = BiocentralServerData.local(availableServices: services);
          Set<BiocentralServerData> availableServers = Set.from(state.availableServersToConnect);
          availableServers.add(localServerData);
          emit(state.copyWith(copyMap: {"availableServersToConnect": availableServers}));
          await _connectToServer(localServerData, emit);
        });
      });
    });

    on<BiocentralClientLaunchExistingLocalServerEvent>((event, emit) async {
      emit(state.setOperating(information: "Launching server.."));

      if (state.extractedExecutablePath != null) {
        final startEither = await BiocentralLocalServer().start(
            extractedExecutablePath: state.extractedExecutablePath!,
            workingDirectory: _biocentralProjectRepository.getPathWithProjectDirectory(_serverDirectoryName));
        await startEither.match((l) async {
          emit(state.setErrored(information: l.message));
        }, (services) async {
          final localServerData = BiocentralServerData.local(availableServices: services);
          Set<BiocentralServerData> availableServers = Set.from(state.availableServersToConnect);
          availableServers.add(localServerData);
          emit(state.copyWith(copyMap: {"availableServersToConnect": availableServers}));
          await _connectToServer(localServerData, emit);
        });
      }
    });

    on<BiocentralClientConnectEvent>((event, emit) async {
      emit(state.setOperating(information: "Connecting to server.."));

      await _connectToServer(event.server, emit);
    });

    on<BiocentralClientDisconnectEvent>((event, emit) async {
      emit(state.setOperating(information: "Disconnecting from server.."));
      emit(state.setFinished(information: "Disconnected from server!").disconnect());
    });
  }

  Future<void> _connectToServer(BiocentralServerData server, Emitter<BiocentralClientState> emit) async {
    final connectedEither = await _biocentralClientRepository.connectToServer(server);
    await connectedEither.match((error) async {
      emit(state.setErrored(information: "Could not connect to server!").disconnect());
    }, (u) async {
      emit(state.setFinished(information: "Finished connecting to server!").copyWith(copyMap: {
        "connectedServer": server,
      }));
    });
  }

  String _getDefaultExecutableName() {
    return "$_serverDirectoryName/$_serverExecutableName";
  }
}
