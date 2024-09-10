import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';

import '../data/ppi_client.dart';
import '../domain/ppi_repository.dart';
import '../model/ppi_database_test.dart';

final class LoadPPIsFromFileCommand extends BiocentralCommand<Map<String, ProteinProteinInteraction>> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final PPIRepository _ppiRepository;

  final PlatformFile? _platformFile;
  final FileData? _fileData;
  final DatabaseImportMode _importMode;

  LoadPPIsFromFileCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required PPIRepository ppiRepository,
      required PlatformFile? platformFile,
      required FileData? fileData,
      required DatabaseImportMode importMode})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _ppiRepository = ppiRepository,
        _platformFile = platformFile,
        _fileData = fileData,
        _importMode = importMode;

  @override
  Stream<Either<T, Map<String, ProteinProteinInteraction>>> execute<T extends BiocentralCommandState<T>>(
      T state) async* {
    yield left(state.setOperating(information: "Loading interactions from file.."));

    if (_platformFile == null && _fileData == null) {
      yield left(state.setErrored(information: "Did not receive any data to load!"));
    } else {
      // TODO Change handleLoad to return Either
      FileData? fileData = _fileData ??
          (await _biocentralProjectRepository.handleLoad(platformFile: _platformFile)).getOrElse((l) => null);
      if (fileData == null) {
        yield left(state.setErrored(information: "Could not retrieve file data!"));
      } else {
        Map<String, ProteinProteinInteraction> interactions =
            await _ppiRepository.importEntitiesFromFile(fileData, _importMode);
        yield right(interactions);
        yield left(state.setFinished(
            information: "Finished loading interactions from file!",
            commandProgress:
                BiocentralCommandProgress(current: interactions.values.length, total: interactions.values.length)));
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      // TODO Values are not correct for asset datasets
      "fileName": _fileData?.name ?? _platformFile?.name,
      "fileExtension": _fileData?.extension ?? _platformFile?.extension,
      "importMode": _importMode.name
    };
  }
}

final class ImportPPIsCommand extends BiocentralCommand<Map<String, ProteinProteinInteraction>> {
  final PPIClient _ppiClient;

  final String _loadedDataset;
  final String _datasetFormat;

  ImportPPIsCommand({required PPIClient ppiClient, required String loadedDataset, required String datasetFormat})
      : _ppiClient = ppiClient,
        _loadedDataset = loadedDataset,
        _datasetFormat = datasetFormat;

  @override
  Stream<Either<T, Map<String, ProteinProteinInteraction>>> execute<T extends BiocentralCommandState<T>>(
      T state) async* {
    yield left(state.setOperating(information: "Importing interaction dataset.."));

    if (_loadedDataset == "") {
      yield left(state.setErrored(information: "Could not read dataset or file is empty!"));
    } else {
      final importedInteractionsEither = await _ppiClient.importInteractions(_loadedDataset, _datasetFormat);
      yield* importedInteractionsEither.match((error) async* {
        yield left(state.setErrored(information: error.message));
      }, (importedInteractions) async* {
        yield right(importedInteractions);

        yield left(state.setFinished(
            information: "Imported ${importedInteractions.length} interactions from $_datasetFormat dataset!",
            commandProgress:
                BiocentralCommandProgress(current: importedInteractions.length, total: importedInteractions.length)));
      });
    }
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {
      "loadedDatasetLength": _loadedDataset.length,
      "datasetFormat": _datasetFormat,
    };
  }
}

final class RemoveDuplicatedPPIsCommand extends BiocentralCommand<int> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final PPIRepository _ppiRepository;

  RemoveDuplicatedPPIsCommand({
    required BiocentralProjectRepository biocentralProjectRepository,
    required PPIRepository ppiRepository,
  })  : _biocentralProjectRepository = biocentralProjectRepository,
        _ppiRepository = ppiRepository;

  @override
  Stream<Either<T, int>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: "Removing duplicated interactions.."));

    int numberDuplicates = await _ppiRepository.removeDuplicates();
    yield right(numberDuplicates);
    yield left(state.setFinished(
        information: "Removed duplicated interactions!",
        commandProgress: BiocentralCommandProgress(current: numberDuplicates, total: numberDuplicates)));
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {};
  }
}

final class RunPPIDatabaseTestCommand extends BiocentralCommand<BiocentralTestResult> {
  final BiocentralProjectRepository _biocentralProjectRepository;
  final PPIRepository _ppiRepository;
  final PPIClient _ppiClient;
  final PPIDatabaseTest _testToRun;

  RunPPIDatabaseTestCommand(
      {required BiocentralProjectRepository biocentralProjectRepository,
      required PPIRepository ppiRepository,
      required PPIClient ppiClient,
      required PPIDatabaseTest testToRun})
      : _biocentralProjectRepository = biocentralProjectRepository,
        _ppiRepository = ppiRepository,
        _ppiClient = ppiClient,
        _testToRun = testToRun;

  @override
  Stream<Either<T, BiocentralTestResult>> execute<T extends BiocentralCommandState<T>>(T state) async* {
    yield left(state.setOperating(information: "Running dataset test.."));

    String datasetHash = await _ppiRepository.getHash();
    final transferEither = await _ppiClient.transferFile(
        datasetHash, StorageFileType.sequences, () async => _ppiRepository.convertToString("fasta"));

    yield* transferEither.match((error) async* {
      yield left(state.setErrored(information: "Could not transfer file to server!"));
    }, (u) async* {
      final testResultEither = await _ppiClient.runDatasetTest(datasetHash, _testToRun);
      yield* testResultEither.match((error) async* {
        yield left(state.setErrored(information: error.message));
      }, (testResult) async* {
        List<PPIDatabaseTest> executedTests = _ppiRepository.addFinishedTest(_testToRun..testResult = testResult);
        yield right(testResult);
        yield left(state
            .setFinished(information: "Done running dataset test!")
            .copyWith(copyMap: {"executedTests": executedTests}));
      });
    });
  }

  @override
  Map<String, dynamic> getConfigMap() {
    return {"testToRun": _testToRun};
  }
}
