import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
  BiocentralPluginBloc(BiocentralPluginManager pluginManager) : super(BiocentralPluginState.loaded(pluginManager)) {
    on<BiocentralPluginReloadEvent>((event, emit) async {
      emit(BiocentralPluginState.loading(state.pluginManager));
      await Future.delayed(const Duration(seconds: 1));

      final BuildContext? context = event.currentContext.mounted ? event.currentContext : null;
      final BiocentralPluginManager updatedManager = BiocentralPluginManager(
          context: context,
          availablePlugins: state.pluginManager.allAvailablePlugins,
          selectedPlugins: event.selectedPlugins,);
      emit(BiocentralPluginState.loaded(updatedManager));
    });
  }
}
