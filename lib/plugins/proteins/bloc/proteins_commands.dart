import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';

import '../data/protein_client.dart';
import '../domain/protein_repository.dart';

final class LoadProteinsFromFileCommand extends BiocentralCommand<Map<String, Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;

  final PlatformFile? _platformFile;
  final FileData? _fileData;
  final DatabaseImportMode _importMode;

  LoadProteinsFromFileCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required ProteinRepository proteinRepository,
      required PlatformFile? platformFile,
      required FileData? fileData,
      required DatabaseImportMode importMode})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _platformFile = platformFile,
        _fileData = fileData,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, Protein>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: "Loading proteins from file.."));

    if (_platformFile == null && _fileData == null) {
      yield left(state.setErrored(information: "Did not receive any data to load!"));
    } else {
      // TODO Change handleLoad to return Either
      FileData? fileData = _fileData ??
          (await _biocentralProjectRepository.handleLoad(platformFile: _platformFile)).getOrElse((l) => null);
      if (fileData == null) {
        yield left(state.setErrored(information: "Could not retrieve file data!"));
      } else {
        Map<String, Protein> proteins = await _proteinRepository.importEntitiesFromFile(fileData, _importMode);
        yield right(proteins);
        yield left(state.setFinished(
            information: "Finished loading proteins from file!",
            commandProgress:
                BiocentralCommandProgress(current: proteins.values.length, total: proteins.values.length)));
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      "fileName": _fileData?.name ?? _platformFile?.name,
      "fileExtension": _fileData?.extension ?? _platformFile?.extension,
      "importMode": _importMode.name
    };
  }
}

final class LoadCustomAttributesFromFileCommand extends BiocentralCommand<Map<String, Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;

  final PlatformFile? _platformFile;
  final FileData? _fileData;
  final DatabaseImportMode _importMode;

  LoadCustomAttributesFromFileCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required ProteinRepository proteinRepository,
      required PlatformFile? platformFile,
      required FileData? fileData,
      required DatabaseImportMode importMode})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _platformFile = platformFile,
        _fileData = fileData,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, Protein>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: "Loading attributes from file.."));

    if (_platformFile == null && _fileData == null) {
      yield left(state.setErrored(information: "Did not receive any data to load!"));
    } else {
      // TODO Change handleLoad to return Either
      FileData? fileData = _fileData ??
          (await _biocentralProjectRepository.handleLoad(platformFile: _platformFile)).getOrElse((l) => null);
      if (fileData == null) {
        yield left(state.setErrored(information: "Could not retrieve file data!"));
      } else {
        Map<String, Protein> updatedProteins = await _proteinRepository.importCustomAttributesFromFile(fileData);
        yield right(updatedProteins);
        yield left(state.setFinished(
            information: "Finished loading attributes from file!",
            commandProgress:
                BiocentralCommandProgress(current: updatedProteins.length, total: updatedProteins.length)));
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      "fileName": _fileData?.name ?? _platformFile?.name,
      "fileExtension": _fileData?.extension ?? _platformFile?.extension,
      "importMode": _importMode.name
    };
  }
}

final class RetrieveTaxonomyCommand extends BiocentralCommand<Map<String, Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;
  final ProteinClient _proteinClient;

  // TODO Use import mode
  final DatabaseImportMode _importMode;

  RetrieveTaxonomyCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required ProteinRepository proteinRepository,
      required ProteinClient proteinClient,
      required DatabaseImportMode importMode})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _proteinClient = proteinClient,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, Protein>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: "Retrieving taxonomy information.."));
    Set<int> taxonomyIDs = _proteinRepository.getTaxonomyIDs();

    if (taxonomyIDs.isEmpty) {
      yield left(state.setErrored(information: "No taxonomy data available!"));
    } else {
      final taxonomyDataEither = await _proteinClient.retrieveTaxonomy(taxonomyIDs);
      yield* taxonomyDataEither.match((error) async* {
        yield left(state.setErrored(information: "Taxonomy data could not be retrieved! Error: ${error.message}"));
      }, (taxonomyData) async* {
        Map<String, Protein> updatedProteins = await _proteinRepository.addTaxonomyData(taxonomyData);
        yield right(updatedProteins);
        yield left(state.setFinished(
            information: "Finished retrieving taxonomy information!",
            commandProgress:
                BiocentralCommandProgress(current: taxonomyData.keys.length, total: taxonomyData.keys.length)));
      });
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {"importMode": _importMode.name};
  }
}
