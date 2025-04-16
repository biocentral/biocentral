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

      try {
        _projectRepository.enterProjectLoadingContext();
        lastProjectDir = event.projectDir;

        emit(state.setOperating(information: 'Scanning project directory..'));
        final PathScanResult scanResult = PathScanner.scanDirectory(event.projectDir);

        // Handle top-level files
        final commandLogFile = scanResult.baseFiles
            .where((file) => file.name.contains('command_log') && file.extension == 'json')
            .firstOrNull;
        if (commandLogFile != null) {
          emit(state.setOperating(information: 'Loading command log..'));
          await _projectRepository.loadCommandLog(commandLogFile);
        }
        final commandLogs = _projectRepository.getCommandLog();

        final typedCommandBlocMap = convertListToTypeMap(_loadProjectBlocs);

        for (final pluginDirectory in _pluginDirectories) {
          emit(state.setOperating(information: 'Loading ${pluginDirectory.path}..'));
          await Future.delayed(const Duration(milliseconds: 50)); // For visual purposes

          final pluginScanResult = scanResult.subdirectoryResults[pluginDirectory.path];

          final commandBloc = typedCommandBlocMap[pluginDirectory.commandBlocType];
          if (commandBloc == null) {
            throw Exception(
              'Could not find correct way to handle loading for directory ${pluginDirectory.path}!',
            );
          }

          final pluginFiles = pluginScanResult?.baseFiles ?? [];
          final pluginSubdirs = pluginScanResult?.getAllSubdirectoryFiles() ?? {};

          final List<void Function()> loadFunctions =
              pluginDirectory.createDirectoryLoadingEvents(pluginFiles, pluginSubdirs, commandLogs, commandBloc);

          if (loadFunctions.isNotEmpty) {
            int completedLoads = 0;
            final totalLoads = loadFunctions.length;

            for (final function in loadFunctions) {
              try {
                await _executeLoadingFunction(function, commandBloc);
                completedLoads++;
                emit(state.setOperating(
                    information: 'Loading progress for ${pluginDirectory.path}: $completedLoads/$totalLoads'));
              } catch (e) {
                throw Exception('Error loading file in ${pluginDirectory.path}: ${e.toString()}');
              }
            }

            emit(state.setOperating(information: 'Loaded all files in ${pluginDirectory.path}!'));
          }
        }

        emit(state.setFinished(information: 'Project loading completed successfully!'));
      } catch (e) {
        emit(state.setErrored(information: e.toString()));
      } finally {
        _projectRepository.exitProjectLoadingContext();
      }
    });
  }

  Future<void> _executeLoadingFunction(Function() loadFunction, Bloc commandBloc) async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = commandBloc.stream.listen(
      (commandBlocState) {
        if (commandBlocState.isFinished()) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        } else if (commandBlocState.isErrored()) {
          if (!completer.isCompleted) {
            completer.completeError(commandBlocState.stateInformation);
          }
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    try {
      loadFunction();
      await completer.future;
    } finally {
      await subscription.cancel();
    }
  }
}
