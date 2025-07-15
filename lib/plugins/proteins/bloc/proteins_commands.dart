import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/data/protein_client.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';

final class LoadProteinsFromFileCommand extends BiocentralCommand<Map<String, Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;

  final XFile? _xFile;
  final LoadedFileData? _fileData;
  final DatabaseImportMode _importMode;

  LoadProteinsFromFileCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required ProteinRepository proteinRepository,
    required XFile? xFile,
    required LoadedFileData? fileData,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _xFile = xFile,
        _fileData = fileData,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, Protein>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Loading proteins from file..'));

    if (_xFile == null && _fileData == null) {
      yield left(state.setErrored(information: 'Did not receive any data to load!'));
    } else {
      // TODO Change handleLoad to return Either
      final LoadedFileData? fileData =
          _fileData ?? (await _biocentralProjectRepository.handleLoad(xFile: _xFile)).getOrElse((l) => null);
      if (fileData == null) {
        yield left(state.setErrored(information: 'Could not retrieve file data!'));
      } else {
        final Map<String, Protein> proteins = await _proteinRepository.importEntitiesFromFile(fileData, _importMode);
        yield right(proteins);
        yield left(
          state.setFinished(
            information: 'Finished loading proteins from file!',
            commandProgress: BiocentralCommandProgress(current: proteins.values.length, total: proteins.values.length),
          ),
        );
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'fileName': _fileData?.name ?? _xFile?.name,
      'fileExtension': _fileData?.extension ?? _xFile?.extension,
      'importMode': _importMode.name,
    };
  }

  @override
  String get typeName => 'LoadProteinsFromFileCommand';
}

final class LoadCustomAttributesFromFileCommand extends BiocentralCommand<Map<String, Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;

  final XFile? _xFile;
  final LoadedFileData? _fileData;
  final DatabaseImportMode _importMode;

  LoadCustomAttributesFromFileCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required ProteinRepository proteinRepository,
    required XFile? xFile,
    required LoadedFileData? fileData,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _xFile = xFile,
        _fileData = fileData,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, Protein>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Loading attributes from file..'));

    if (_xFile == null && _fileData == null) {
      yield left(state.setErrored(information: 'Did not receive any data to load!'));
    } else {
      // TODO Change handleLoad to return Either
      final LoadedFileData? fileData =
          _fileData ?? (await _biocentralProjectRepository.handleLoad(xFile: _xFile)).getOrElse((l) => null);
      if (fileData == null) {
        yield left(state.setErrored(information: 'Could not retrieve file data!'));
      } else {
        final Map<String, Protein> updatedProteins = await _proteinRepository.importCustomAttributesFromFile(fileData);
        yield right(updatedProteins);
        yield left(
          state.setFinished(
            information: 'Finished loading attributes from file!',
            commandProgress: BiocentralCommandProgress(current: updatedProteins.length, total: updatedProteins.length),
          ),
        );
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'fileName': _fileData?.name ?? _xFile?.name,
      'fileExtension': _fileData?.extension ?? _xFile?.extension,
      'importMode': _importMode.name,
    };
  }

  @override
  String get typeName => 'LoadCustomAttributesFromFileCommand';
}

final class RetrieveTaxonomyCommand extends BiocentralCommand<Map<String, Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;
  final ProteinClient _proteinClient;

  // TODO Use import mode
  final DatabaseImportMode _importMode;

  RetrieveTaxonomyCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required ProteinRepository proteinRepository,
    required ProteinClient proteinClient,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _proteinClient = proteinClient,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, Protein>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Retrieving taxonomy information..'));
    final Set<int> taxonomyIDs = _proteinRepository.getTaxonomyIDs();

    if (taxonomyIDs.isEmpty) {
      yield left(state.setErrored(information: 'No taxonomy data available!'));
    } else {
      final taxonomyDataEither = await _proteinClient.retrieveTaxonomy(taxonomyIDs);
      yield* taxonomyDataEither.match((error) async* {
        yield left(state.setErrored(information: 'Taxonomy data could not be retrieved! Error: ${error.message}'));
      }, (taxonomyData) async* {
        final Map<String, Protein> updatedProteins = await _proteinRepository.addTaxonomyData(taxonomyData);
        yield right(updatedProteins);
        yield left(
          state.setFinished(
            information: 'Finished retrieving taxonomy information!',
            commandProgress:
                BiocentralCommandProgress(current: taxonomyData.keys.length, total: taxonomyData.keys.length),
          ),
        );
      });
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'importMode': _importMode.name};
  }

  @override
  String get typeName => 'RetrieveTaxonomyCommand';
}

final class ProteinPredictCommand extends BiocentralCommand<Map<String, Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;
  final ProteinClient _proteinClient;

  final Set<String> _selectedModels;

  // TODO Use import mode
  final DatabaseImportMode _importMode;

  ProteinPredictCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required ProteinRepository proteinRepository,
    required ProteinClient proteinClient,
    required Set<String> selectedModels,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _proteinClient = proteinClient,
        _selectedModels = selectedModels,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, Protein>>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: 'Predicting protein features..'));

    final proteinMap = _proteinRepository.databaseToMap();

    if (proteinMap.isEmpty) {
      yield left(state.setErrored(information: 'No protein data available!'));
    } else {
      final predictionEither = await _proteinClient.predictProtein(proteinMap, _selectedModels.toList());
      yield* predictionEither.match((error) async* {
        yield left(state.setErrored(information: 'Prediction task could not be started! Error: ${error.message}'));
      }, (taskID) async* {
        Map<String, dynamic> currentPredictions = {};
        await for (final (dto, predictions) in _proteinClient.predictionTaskStream(taskID)) {
          if (predictions == null) {
            continue;
          }
          currentPredictions = predictions;
        }
        if (currentPredictions.isEmpty) {
          yield left(state.setErrored(information: 'Did not receive any predictions!'));
        } else {
          Map<String, Protein> updatedProteins = {};
          for (final (modelName, predictions) in currentPredictions.entriesRecord) {
            updatedProteins = await _proteinRepository.addCustomAttribute(
              '$modelName-predicted',
              // TODO Adapt Prediction API
              Map.from(
                predictions.map((entityID, modelPredictions) => MapEntry(entityID, modelPredictions[0]["prediction"])),
              ),
            );
          }
          yield right(updatedProteins);
          yield left(
            state.setFinished(
              information: 'Finished predicting protein properties!',
              commandProgress:
                  BiocentralCommandProgress(current: currentPredictions.length, total: currentPredictions.length),
            ),
          );
        }
      });
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'selectedModels': _selectedModels.toList(), 'importMode': _importMode.name};
  }

  @override
  String get typeName => 'ProteinPredictCommand';
}
