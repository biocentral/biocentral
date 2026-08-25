import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class BiocentralPluginBlocEvent {}

final class BiocentralPluginReloadEvent extends BiocentralPluginBlocEvent {
  final Set<BiocentralPlugin> selectedPlugins;
  final BuildContext currentContext;

  BiocentralPluginReloadEvent(this.selectedPlugins, this.currentContext);
}

@immutable
final class BiocentralPluginState extends Equatable {
  final BiocentralPluginManager pluginManager;
  final BiocentralPluginStatus status;

  const BiocentralPluginState(this.pluginManager, this.status);

  const BiocentralPluginState.loaded(this.pluginManager) : status = BiocentralPluginStatus.loaded;

  const BiocentralPluginState.loading(this.pluginManager) : status = BiocentralPluginStatus.loading;

  @override
  List<Object?> get props => [pluginManager, status];
}

enum BiocentralPluginStatus { loading, loaded }

class BiocentralPluginBloc extends Bloc<BiocentralPluginBlocEvent, BiocentralPluginState> {
  BiocentralPluginBloc(EventBus eventBus, BiocentralPluginManager pluginManager)
      : super(BiocentralPluginState.loaded(pluginManager)) {
    on<BiocentralPluginReloadEvent>((event, emit) async {
      emit(BiocentralPluginState.loading(state.pluginManager));
      await Future.delayed(const Duration(seconds: 1));

      final BuildContext? context = event.currentContext.mounted ? event.currentContext : null;
      if (context == null) {
        // TODO HANDLE ERROR AND IMPROVE CONTEXT HANDLING
      } else {
        final BiocentralPluginManager updatedManager = BiocentralPluginManager(
          eventBus: eventBus,
          projectRepository: context.read<BiocentralProjectRepository>(),
          companion: context.read<BiocentralPythonCompanion>(),
          context: context,
          availablePlugins: state.pluginManager.allAvailablePlugins,
          selectedPlugins: event.selectedPlugins,
        );
        emit(BiocentralPluginState.loaded(updatedManager));
      }
    });
  }
}
