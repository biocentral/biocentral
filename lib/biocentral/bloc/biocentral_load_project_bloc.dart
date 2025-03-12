import 'dart:async';

import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:biocentral/sdk/util/path_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class BiocentralLoadProjectEvent {}

final class BiocentralLoadProjectFromDirectoryEvent extends BiocentralLoadProjectEvent {
  final String projectDir;

  BiocentralLoadProjectFromDirectoryEvent(this.projectDir);
}

@immutable
final class BiocentralLoadProjectState extends BiocentralCommandState<BiocentralLoadProjectState> {
  const BiocentralLoadProjectState(super.stateInformation, super.status);

  const BiocentralLoadProjectState.idle() : super.idle();

  @override
  BiocentralLoadProjectState newState(
      BiocentralCommandStateInformation stateInformation, BiocentralCommandStatus status) {
    return BiocentralLoadProjectState(stateInformation, status);
  }

  @override
  List<Object?> get props => [stateInformation, status];
}

class BiocentralLoadProjectBloc extends Bloc<BiocentralLoadProjectEvent, BiocentralLoadProjectState> {
  final BiocentralProjectRepository _projectRepository;
  final List<Bloc> _loadProjectBlocs;
  final List<BiocentralPluginDirectory> _pluginDirectories;

  String? lastProjectDir;

  BiocentralLoadProjectBloc(this._projectRepository, this._loadProjectBlocs, this._pluginDirectories)
      : super(const BiocentralLoadProjectState.idle()) {
    on<BiocentralLoadProjectFromDirectoryEvent>((event, emit) async {
      if (kIsWeb) {
        return emit(state.setFinished(information: 'Web - nothing to load'));
      }

      if (lastProjectDir == event.projectDir) {
        return; // Nothing to do
      }
      _projectRepository.enterProjectLoadingContext();
      lastProjectDir = event.projectDir;

      emit(state.setOperating(information: 'Scanning project directory..'));
      final PathScanResult scanResult = PathScanner.scanDirectory(event.projectDir);

      // Handle top-level files
      final commandLogFile = scanResult.baseFiles
          .where((file) => file.name.contains('command_log') && file.extension == 'json')
          .firstOrNull;
      if(commandLogFile != null) {
        emit(state.setOperating(information: 'Loading command log..'));
        _projectRepository.loadCommandLog(commandLogFile);
      }

      final typedCommandBlocMap = convertListToTypeMap(_loadProjectBlocs);

      StreamSubscription? currentSubscription;
      try {
        final completer = Completer<void>();

        for (final pluginDirectory in _pluginDirectories) {
          emit(state.setOperating(information: 'Loading ${pluginDirectory.path}..'));

          await Future.delayed(const Duration(milliseconds: 50)); // For visual purposes

          final pluginScanResult = scanResult.subdirectoryResults[pluginDirectory.path];
          if (pluginScanResult == null) {
            // Nothing to load here
            continue;
          }

          final commandBloc = typedCommandBlocMap[pluginDirectory.commandBlocType];
          if (commandBloc == null) {
            return emit(
              state.setErrored(
                information: 'Could not find correct way to handle loading for directory ${pluginDirectory.path}!',
              ),
            );
          }

          final pluginFiles = pluginScanResult.baseFiles;
          final pluginSubdirs = pluginScanResult.getAllSubdirectoryFiles();

          final List<void Function()> loadFunctions =
              pluginDirectory.createDirectoryLoadingEvents(pluginFiles, pluginSubdirs, commandBloc);

          if (loadFunctions.isNotEmpty) {
            final int totalLoads = loadFunctions.length;
            int completedLoads = 0;
            currentSubscription = commandBloc.stream.listen(
              (commandBlocState) {
                if (commandBlocState.isErrored()) {
                  if (!completer.isCompleted) {
                    completer.completeError('Error in component: ${commandBlocState.stateInformation}');
                  }
                } else if (commandBlocState.isFinished()) {
                  completedLoads++;

                  emit(state.setOperating(information: 'Loading progress: $completedLoads/$totalLoads')); // TODO

                  if (completedLoads == totalLoads && !completer.isCompleted) {
                    completer.complete();
                  }
                }
              },
              onError: (error) {
                if (!completer.isCompleted) {
                  completer.completeError(error);
                }
              },
            ); // LISTEN

            // TODO Might be problematic to call multiple events at once
            for (final function in loadFunctions) {
              function();
            }

            // Wait for loading to be done
            try {
              await completer.future;
              currentSubscription.cancel();
              emit(state.setOperating(information: 'Loaded all files in ${pluginDirectory.path}!'));
            } catch (e) {
              currentSubscription.cancel();
              emit(state.setErrored(information: e.toString()));
            }
          }
        }
      } catch (e) {
        currentSubscription?.cancel();
        emit(state.setErrored(information: e.toString()));
      } finally {
        currentSubscription?.cancel();
        _projectRepository.exitProjectLoadingContext();
      }

      currentSubscription?.cancel();
      emit(state.setFinished(information: 'Project loading completed successfully!'));
    });
  }
}
