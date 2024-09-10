import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:fpdart/fpdart.dart';

import 'prediction_models_service_api.dart';

final class PredictionModelsClientFactory extends BiocentralClientFactory<PredictionModelsClient> {
  @override
  PredictionModelsClient create(BiocentralServerData? server) {
    return PredictionModelsClient(server);
  }
}

class PredictionModelsClient extends BiocentralClient {
  PredictionModelsClient(super._server);

  Future<Either<BiocentralException, List<String>>> getAvailableBiotrainerProtocols() async {
    final responseEither = await doGetRequest(PredictionModelsServiceEndpoints.protocolsEndpoint);
    return responseEither.match((error) => left(error), (responseMap) {
      List<String> availableProtocols = List<String>.from(responseMap["protocols"]);
      return right(availableProtocols);
    });
  }

  Future<Either<BiocentralException, List<BiotrainerOption>>> getBiotrainerConfigOptionsByProtocol(
      String protocol) async {
    final responseEither = await doGetRequest(PredictionModelsServiceEndpoints.configOptionsEndpoint + protocol.trim());
    return responseEither.match((error) => left(error), (responseMap) {
      List<dynamic> configOptions = responseMap["options"];
      return right(configOptions.map((configOption) => BiotrainerOption.fromMap(configOption)).toList());
    });
  }

  Future<Either<BiocentralException, Unit>> verifyBiotrainerConfig(String configFile) async {
    final responseEither =
        await doPostRequest(PredictionModelsServiceEndpoints.verifyConfigEndpoint, {"config_file": configFile});
    // EMPTY STRING "" -> NO ERROR
    return responseEither.flatMap((responseMap) => right(unit));
  }

  Future<Either<BiocentralException, String>> startTraining(String configFile, String databaseHash) async {
    final responseEither = await doPostRequest(PredictionModelsServiceEndpoints.startTrainingEndpoint,
        {"config_file": configFile, "database_hash": databaseHash});
    return responseEither.flatMap((responseMap) => right(responseMap["model_hash"]));
  }

  Future<Either<BiocentralException, BiotrainerTrainingStatusDTO>> getTrainingStatus(String modelHash) async {
    final responseEither = await doGetRequest("${PredictionModelsServiceEndpoints.trainingStatusEndpoint}/$modelHash");
    return responseEither.flatMap((responseMap) => BiotrainerTrainingStatusDTO.fromResponseBody(responseMap));
  }

  Stream<String> biotrainerTrainingStatusStream(String modelHash) async* {
    const int maxRequests = 3000; // TODO Listening for only 60 Minutes
    bool finished = false;
    for (int i = 0; i < maxRequests; i++) {
      if (finished) {
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
      final biotrainerTrainingStatusDTOEither = await getTrainingStatus(modelHash);
      final biotrainerTrainingStatusDTO =
          biotrainerTrainingStatusDTOEither.getOrElse((l) => BiotrainerTrainingStatusDTO.failed());
      if (biotrainerTrainingStatusDTO.trainingStatus == BiotrainerTrainingStatus.failed) {
        finished = true;
        continue;
      }
      if (biotrainerTrainingStatusDTO.trainingStatus == BiotrainerTrainingStatus.finished) {
        finished = true;
      }
      yield biotrainerTrainingStatusDTO.logFile;
    }
  }

  Future<Either<BiocentralException, Map<StorageFileType, dynamic>>> getModelFiles(
      String databaseHash, String modelHash) async {
    final responseEither = await doPostRequest(
        PredictionModelsServiceEndpoints.modelFilesEndpoint, {"database_hash": databaseHash, "model_hash": modelHash});
    return responseEither.flatMap((responseMap) => right((responseMap as Map<String, dynamic>)
        .map((key, value) => MapEntry(enumFromString<StorageFileType>(key, StorageFileType.values)!, value))));
  }

  @override
  String getServiceName() {
    return "prediction_models_service";
  }
}
