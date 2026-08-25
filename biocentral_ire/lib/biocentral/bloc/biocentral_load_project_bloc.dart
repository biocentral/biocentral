import 'dart:async';

import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_command_log_repository.dart';
import 'package:biocentral/sdk/plugin/biocentral_plugin_directory.dart';
import 'package:biocentral/sdk/util/path_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class BiocentralLoadProjectEvent {}

final class BiocentralLoadProjectFromDirectoryEvent extends BiocentralLoadProjectEvent {
  final String projectDir;
  final BuildContext context;

  BiocentralLoadProjectFromDirectoryEvent(this.projectDir, this.context);
}

@immutable
final class BiocentralLoadProjectState extends Equatable {
  final BiocentralCommandMetaData metaData; // MetaData to log load progress
  final BiocentralLoadProjectStatus status;

  const BiocentralLoadProjectState(this.metaData, this.status);

  BiocentralLoadProjectState.initial()
      : metaData = BiocentralCommandMetaData.initialize(),
        status = BiocentralLoadProjectStatus.idle;

  @override
  List<Object?> get props => [metaData, status];
}

enum BiocentralLoadProjectStatus { idle, loading, errored, done }

class BiocentralLoadProjectBloc extends Bloc<BiocentralLoadProjectEvent, BiocentralLoadProjectState> {
  final BiocentralProjectRepository _projectRepository;
  final BiocentralCommandLogRepository _commandLogRepository;
  final BiocentralCommandBloc _commandBloc;
  final List<BiocentralPluginDirectory> _pluginDirectories;

  String? lastProjectDir;

  BiocentralLoadProjectBloc(
      this._projectRepository, this._commandLogRepository, this._commandBloc, this._pluginDirectories)
      : super(BiocentralLoadProjectState.initial()) {
    on<BiocentralLoadProjectFromDirectoryEvent>((event, emit) async {
      if (kIsWeb) {
        return emit(
          BiocentralLoadProjectState(
            state.metaData
                .finish(const BiocentralCommandProgress(information: 'Web - nothing to load', current: 0, total: 0)),
            BiocentralLoadProjectStatus.done,
          ),
        );
      }

      if (lastProjectDir == event.projectDir) {
        return; // Nothing to do
      }

      try {
        _projectRepository.enterProjectLoadingContext();
        _commandLogRepository.enterProjectLoadingContext();
        lastProjectDir = event.projectDir;

        emit(
          BiocentralLoadProjectState(
            state.metaData.logInfo('Scanning project directory..'),
            BiocentralLoadProjectStatus.loading,
          ),
        );
        final PathScanResult scanResult = PathScanner.scanDirectory(event.projectDir);

        // Handle top-level files
        final commandLogFile = scanResult.baseFiles
            .where((file) => file.name.contains('command_log') && file.extension == 'json')
            .firstOrNull;
        if (commandLogFile != null) {
          emit(
            BiocentralLoadProjectState(
              state.metaData.logInfo('Loading command log..'),
              BiocentralLoadProjectStatus.loading,
            ),
          );
          final commandLogLoadedEither = await _projectRepository.handleLoad(xFile: commandLogFile);

          await _commandLogRepository.loadCommandLog(commandLogLoadedEither);
        }

        for (final pluginDirectory in _pluginDirectories) {
          emit(
            BiocentralLoadProjectState(
              state.metaData.logInfo('Loading ${pluginDirectory.path}..'),
              BiocentralLoadProjectStatus.loading,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50)); // For visual purposes

          final pluginScanResult = scanResult.subdirectoryResults[pluginDirectory.path];

          final pluginFiles = pluginScanResult?.baseFiles ?? [];
          final pluginSubdirs = pluginScanResult?.getAllSubdirectoryFiles() ?? {};

          final List<void Function(BuildContext)> loadFunctions =
              pluginDirectory.createDirectoryLoadingEvents(pluginFiles, pluginSubdirs);

          if (loadFunctions.isNotEmpty) {
            int completedLoads = 0;
            final totalLoads = loadFunctions.length;

            for (final function in loadFunctions) {
              try {
                if (!event.context.mounted) {
                  // Error
                  throw Exception('Error loading file in ${pluginDirectory.path}: Context not mounted!');
                }
                await _executeLoadingFunction(function, event.context);
                completedLoads++;
                emit(
                  BiocentralLoadProjectState(
                    state.metaData.logInfo('Loading progress for ${pluginDirectory.path}: $completedLoads/$totalLoads'),
                    BiocentralLoadProjectStatus.loading,
                  ),
                );
              } catch (e) {
                throw Exception('Error loading file in ${pluginDirectory.path}: ${e.toString()}');
              }
            }
            emit(
              BiocentralLoadProjectState(
                state.metaData.logInfo('Loaded all files in ${pluginDirectory.path}!'),
                BiocentralLoadProjectStatus.loading,
              ),
            );
          }
        }
        return emit(
          BiocentralLoadProjectState(
            state.metaData.finish(
              const BiocentralCommandProgress(
                information: 'Project loading completed successfully!',
                current: 0,
                total: 0,
              ),
            ),
            BiocentralLoadProjectStatus.done,
          ),
        );
      } catch (e) {
        return emit(
          BiocentralLoadProjectState(
            state.metaData.logError(e.toString()),
            BiocentralLoadProjectStatus.errored,
          ),
        );
      } finally {
        _projectRepository.exitProjectLoadingContext();
        _commandLogRepository.exitProjectLoadingContext();
      }
    });
  }

  Future<void> _executeLoadingFunction(void Function(BuildContext) loadFunction, BuildContext context) async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = _commandBloc.stream.listen(
      (commandBlocState) {
        if (commandBlocState.isFinished()) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        } else if (commandBlocState.isErrored()) {
          if (!completer.isCompleted) {
            completer.completeError(
              commandBlocState.currentCommandLog?.metaData.error ?? 'Loading failed with unknown error',
            );
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
      loadFunction(context);
      await completer.future;
    } finally {
      await subscription.cancel();
    }
  }
}
