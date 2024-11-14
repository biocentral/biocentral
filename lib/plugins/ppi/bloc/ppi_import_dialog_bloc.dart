import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/plugins/ppi/data/ppi_client.dart';

mixin class PPIImportDialogEvent {}

final class PPIImportDialogLoadFormatsEvent extends PPIImportDialogEvent {
  PPIImportDialogLoadFormatsEvent();
}

class PPIImportDialogSelectEvent extends BiocentralSimpleMultiTypeUIUpdateEvent with PPIImportDialogEvent {
  PPIImportDialogSelectEvent(super.updates);
}

@immutable
final class PPIImportDialogState extends BiocentralSimpleMultiTypeUIState<PPIImportDialogState> {
  final Map<String, String>? availableFormatsWithDocs;

  final String? selectedFormat;
  final FileData? selectedFile;
  final PPIImportDialogStatus status;

  const PPIImportDialogState(this.availableFormatsWithDocs, this.selectedFormat, this.selectedFile, this.status);

  const PPIImportDialogState.initial()
      : availableFormatsWithDocs = const {},
        selectedFormat = null,
        selectedFile = null,
        status = PPIImportDialogStatus.initial;

  const PPIImportDialogState.loading()
      : availableFormatsWithDocs = const {},
        selectedFormat = null,
        selectedFile = null,
        status = PPIImportDialogStatus.loading;

  const PPIImportDialogState.loaded(this.availableFormatsWithDocs)
      : selectedFormat = null,
        selectedFile = null,
        status = PPIImportDialogStatus.loaded;

  const PPIImportDialogState.selected(this.availableFormatsWithDocs, this.selectedFormat, this.selectedFile)
      : status = PPIImportDialogStatus.selected;

  @override
  List<Object?> get props => [selectedFormat, selectedFile, availableFormatsWithDocs, status];

  @override
  PPIImportDialogState updateFromUIEvent(BiocentralSimpleMultiTypeUIUpdateEvent event) {
    return PPIImportDialogState.selected(
        availableFormatsWithDocs, getValueFromEvent(selectedFormat, event), getValueFromEvent(selectedFile, event),);
  }
}

enum PPIImportDialogStatus { initial, loading, loaded, selected }

class ShowAutoDetectedFormat {
  final String format;

  ShowAutoDetectedFormat(this.format);
}

class PPIImportDialogBloc extends Bloc<PPIImportDialogEvent, PPIImportDialogState>
    with Effects<ShowAutoDetectedFormat> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralClientRepository _biocentralClientRepository;

  PPIImportDialogBloc(this._biocentralProjectRepository, this._biocentralClientRepository)
      : super(const PPIImportDialogState.initial()) {
    on<PPIImportDialogLoadFormatsEvent>((event, emit) async {
      emit(const PPIImportDialogState.loading());

      final availableFormatsWithDocsEither =
          await _biocentralClientRepository.getServiceClient<PPIClient>().getAvailableDatasetFormats();
      // TODO ERROR + STATE HANDLING!
      availableFormatsWithDocsEither.match(
          (error) => null, (availableFormatsWithDocs) => emit(PPIImportDialogState.loaded(availableFormatsWithDocs)),);
    });

    on<PPIImportDialogSelectEvent>((event, emit) async {
      final PlatformFile? selectedFile = event.updates.whereType<PlatformFile?>().firstOrNull;

      if (selectedFile != null) {
        final loadEither = await _biocentralProjectRepository.handleLoad(platformFile: selectedFile);
        await loadEither.match((l) => null, (fileData) async {
          emit(PPIImportDialogState.selected(state.availableFormatsWithDocs, state.selectedFormat, fileData));
          final String? header = fileData?.content.split('\n').first;
          // Auto-detect format from header of file
          if (header != null) {
            final detectedFormatEither =
                await _biocentralClientRepository.getServiceClient<PPIClient>().autoDetectFormat(header);
            detectedFormatEither.match((error) => null, (detectedFormat) {
              emit(PPIImportDialogState.selected(state.availableFormatsWithDocs, detectedFormat, fileData));
              emitEffect(ShowAutoDetectedFormat(detectedFormat));
            });
          }
        });
      } else {
        emit(state.updateFromUIEvent(event));
      }
    });
  }
}
