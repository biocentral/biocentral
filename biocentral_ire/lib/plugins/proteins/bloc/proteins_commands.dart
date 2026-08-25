import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';

final class LoadProteinsFromFileCommand extends BiocentralCommand<BiocentralDatabaseUpdate<Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;

  final XFile? _xFile;
  final BiocentralAssetDataset? _assetDataset;
  final DatabaseImportMode _importMode;

  LoadProteinsFromFileCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required ProteinRepository proteinRepository,
    required XFile? xFile,
    required BiocentralAssetDataset? assetDataset,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _xFile = xFile,
        _assetDataset = assetDataset,
        _importMode = importMode;

  String _getFileContentFromAssetDataset(ByteData dataset) {
    final buffer = dataset.buffer;
    final Uint8List bytes = buffer.asUint8List(dataset.offsetInBytes, dataset.lengthInBytes);
    return String.fromCharCodes(bytes);
  }

  Future<LoadedFileData?> _handleAssetDatasetLoad() async {
    if (_assetDataset != null) {
      final ByteData dataset = await rootBundle.load(_assetDataset.path);

      final String fileContent = _getFileContentFromAssetDataset(dataset);

      final fileData = LoadedFileData(content: fileContent, name: '', extension: '');
      return fileData;
    }
    return null;
  }

  @override
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>> log = initLog();
    yield log = log.logInfo(information: 'Loading proteins from file..');

    if (_xFile == null && _assetDataset == null) {
      yield log.errored(error: 'Did not receive any data to load!');
      return;
    }

    // TODO Change handleLoad to return Either
    final LoadedFileData? fileData = (await _handleAssetDatasetLoad()) ??
        (await _biocentralProjectRepository.handleLoad(xFile: _xFile)).getOrElse((l) => null);
    if (fileData == null) {
      yield log.errored(error: 'Could not retrieve file data!');
      return;
    }
    final update = await _proteinRepository.importEntitiesFromFile(fileData, _importMode);

    yield log.finish(
      result: BiocentralCommandResult(update, update.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished loading proteins from file!',
        current: update.result.length,
        total: update.result.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is BiocentralDatabaseUpdate) {
      _proteinRepository.acceptDatabaseUpdate(commandResult as BiocentralDatabaseUpdate<Protein>);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'fileName': _assetDataset?.name ?? _xFile?.name,
      'fileExtension': _assetDataset?.path ?? _xFile?.extension,
      'importMode': _importMode.name,
    };
  }

  @override
  String get typeName => 'LoadProteinsFromFileCommand';
}

final class ExportProteinsCommand extends BiocentralCommand<String> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final ProteinRepository _proteinRepository;

  final String? _filePath;

  ExportProteinsCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required ProteinRepository proteinRepository,
      required String filePath})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _proteinRepository = proteinRepository,
        _filePath = filePath;

  @override
  Stream<BiocentralCommandLog<String>> execute() async* {
    BiocentralCommandLog<String> log = initLog();
    yield log = log.logInfo(information: 'Exporting proteins..');

    final saveEither = await _biocentralProjectRepository.handleExternalSave(
      fileName: 'proteins.fasta',
      contentFunction: () async => _proteinRepository.convertToString('fasta'),
      dirPath: _filePath, // TODO THIS WILL NOT WORK CORRECTLY IF A FILE WAS CHOSEN
    );
    yield saveEither.match(
      (l) => log.errored(error: l.message),
      (r) => log.finish(
        result: BiocentralCommandResult(r!, {'filePath': r}),
        finalProgress: BiocentralCommandProgress(
          information: 'Finished exporting proteins!',
          current: _proteinRepository.databaseToList().length,
          total: _proteinRepository.databaseToList().length,
        ),
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    // Nothing to do
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      'filePath': _filePath,
    };
  }

  @override
  String get typeName => 'ExportProteinsCommand';
}

final class LoadCustomAttributesFromFileCommand extends BiocentralCommand<BiocentralDatabaseUpdate<Protein>> {
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
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>> log = initLog();
    yield log = log.logInfo(information: 'Loading attributes from file..');

    if (_xFile == null && _fileData == null) {
      yield log.errored(error: 'Did not receive any data to load!');
      return;
    }
    // TODO Change handleLoad to return Either
    final LoadedFileData? fileData =
        _fileData ?? (await _biocentralProjectRepository.handleLoad(xFile: _xFile)).getOrElse((l) => null);
    if (fileData == null) {
      yield log.errored(error: 'Could not retrieve file data!');
      return;
    }
    final update = await _proteinRepository.importCustomAttributesFromFile(fileData);
    yield log.finish(
      result: BiocentralCommandResult(update, update.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished loading attributes from file!',
        current: update.result.length,
        total: update.result.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is BiocentralDatabaseUpdate) {
      _proteinRepository.acceptDatabaseUpdate(commandResult as BiocentralDatabaseUpdate<Protein>);
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

final class RetrieveTaxonomyCommand extends BiocentralCommand<BiocentralDatabaseUpdate<Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralAPIRepository _apiRepository;
  final ProteinRepository _proteinRepository;

  // TODO Use import mode
  final DatabaseImportMode _importMode;

  RetrieveTaxonomyCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralAPIRepository apiRepository,
    required ProteinRepository proteinRepository,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _apiRepository = apiRepository,
        _proteinRepository = proteinRepository,
        _importMode = importMode;

  static int checkNumberOfIDsAvailable(Map<String, Protein> proteinMap) {
    final Set<int> taxonomyIDs = ProteinRepository.getTaxonomyIDs(proteinMap);
    return taxonomyIDs.length;
  }

  @override
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>> log = initLog();
    yield log = log.logInfo(information: 'Retrieving taxonomy information..');

    final Set<int> taxonomyIDs = ProteinRepository.getTaxonomyIDs(_proteinRepository.databaseToMap());

    if (taxonomyIDs.isEmpty) {
      yield log.errored(error: 'No taxonomy data available!');
      return;
    }
    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final taxonomyItems = await biocentralAPI.taxonomy(taxonomyIds: taxonomyIDs.toList());
    if (taxonomyItems == null) {
      yield log.errored(error: 'Taxonomy data could not be retrieved!');
      return;
    }
    final taxonomyData = Map.fromEntries(
      taxonomyItems.map(
        (item) => MapEntry(item.taxonomyId, Taxonomy(id: item.taxonomyId, name: item.name, family: item.family)),
      ),
    );
    final update = await _proteinRepository.addTaxonomyData(taxonomyData);

    yield log.finish(
      result: BiocentralCommandResult(update, update.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished retrieving taxonomy information!',
        current: taxonomyData.keys.length,
        total: taxonomyData.keys.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is BiocentralDatabaseUpdate) {
      _proteinRepository.acceptDatabaseUpdate(commandResult as BiocentralDatabaseUpdate<Protein>);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'importMode': _importMode.name};
  }

  @override
  String get typeName => 'RetrieveTaxonomyCommand';
}

final class ProteinPredictCommand extends BiocentralCommand<BiocentralDatabaseUpdate<Protein>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final BiocentralAPIRepository _apiRepository;
  final ProteinRepository _proteinRepository;

  final Set<String> _selectedModels;

  // TODO Use import mode
  final DatabaseImportMode _importMode;

  ProteinPredictCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required BiocentralAPIRepository apiRepository,
    required ProteinRepository proteinRepository,
    required Set<String> selectedModels,
    required DatabaseImportMode importMode,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _apiRepository = apiRepository,
        _proteinRepository = proteinRepository,
        _selectedModels = selectedModels,
        _importMode = importMode;

  @override
  Stream<BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>>> execute() async* {
    BiocentralCommandLog<BiocentralDatabaseUpdate<Protein>> log = initLog();
    yield log = log.logInfo(information: 'Predicting protein features..');

    final proteinMap = _proteinRepository.databaseToMap();
    final sequenceData = proteinMap.map((k, v) => MapEntry(k, v.sequence.seq));

    if (proteinMap.isEmpty) {
      yield log.errored(error: 'No protein data available!');
      return;
    }

    final biocentralAPI = _apiRepository.getBiocentralAPI();
    final biocentralTask =
        await biocentralAPI.predict(modelNames: _selectedModels.toList(), sequenceData: sequenceData);
    Map<String, List<Prediction>> currentPredictions = {};
    await for (final (dto, predictions) in biocentralTask.run()) {
      if (predictions == null) {
        continue;
      }
      currentPredictions =
          Map.fromEntries(predictions.entries.map((entry) => MapEntry(entry.key, entry.value.toList())));
    }

    if (currentPredictions.isEmpty) {
      yield log.errored(error: 'Did not receive any predictions!');
      return;
    }
    final Map<String, Map<String, Prediction>> predictionsByNames = {};
    for (final (entityID, predictions) in currentPredictions.entriesRecord) {
      for (final prediction in predictions) {
        final combinedName = '${prediction.modelName}-${prediction.predictionName}-predicted';
        predictionsByNames.putIfAbsent(combinedName, () => {});
        predictionsByNames[combinedName]![entityID] = prediction;
      }
    }

    // TODO Improve handling and generation of Database Update
    Map<String, Protein> updatedProteins = {};
    BiocentralDatabaseUpdate<Protein> update = BiocentralDatabaseUpdate.empty(_importMode);
    for (final (combinedName, predictionMap) in predictionsByNames.entriesRecord) {
      update = await _proteinRepository.addCustomAttributes(
        combinedName,
        // TODO Improve prediction class support
        predictionMap.map((k, v) => MapEntry(k, v.value.toString())),
      );
    }

    yield log.finish(
      result: BiocentralCommandResult(update, update.serialize()),
      finalProgress: BiocentralCommandProgress(
        information: 'Finished predicting protein properties!',
        current: updatedProteins.length, // TODO IMPROVE
        total: updatedProteins.length,
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final commandResult = resultLog?.result?.result;
    if (commandResult != null && commandResult is BiocentralDatabaseUpdate) {
      _proteinRepository.acceptDatabaseUpdate(commandResult as BiocentralDatabaseUpdate<Protein>);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {'selectedModels': _selectedModels.toList(), 'importMode': _importMode.name};
  }

  @override
  String get typeName => 'ProteinPredictCommand';
}

/*
TODO COLUMN WIZARD
on<ProteinsCommandAddColumnEvent>((event, emit) async {
      final ColumnWizardOperationCommand columnWizardOperationCommand = ColumnWizardOperationCommand(
        database: _proteinRepository,
        newColumnName: event.newColumnName,
        originalColumnName: event.originalColumnName,
        operationHistory: event.operationHistory,
      );
      await columnWizardOperationCommand
          .executeWithLogging(_biocentralProjectRepository, state)
          .forEach((either) async {
        await either.match((l) async {
          emit(l);
        }, (r) async {
          syncWithDatabases(r);
        });
      });
    });
 */
