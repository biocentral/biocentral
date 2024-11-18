import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_dto.dart';
import 'package:fpdart/fpdart.dart';

import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';

import '../model/prediction_model.dart';

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
      final List<String> availableProtocols = List<String>.from(responseMap['protocols']);
      return right(availableProtocols);
    });
  }

  Future<Either<BiocentralException, List<BiotrainerOption>>> getBiotrainerConfigOptionsByProtocol(
      String protocol,) async {
    final responseEither = await doGetRequest(PredictionModelsServiceEndpoints.configOptionsEndpoint + protocol.trim());
    return responseEither.match((error) => left(error), (responseMap) {
      final List<dynamic> configOptions = responseMap['options'];
      return right(configOptions.map((configOption) => BiotrainerOption.fromMap(configOption)).toList());
    });
  }

  Future<Either<BiocentralException, Unit>> verifyBiotrainerConfig(String configFile) async {
    final responseEither =
        await doPostRequest(PredictionModelsServiceEndpoints.verifyConfigEndpoint, {'config_file': configFile});
    // EMPTY STRING "" -> NO ERROR
    return responseEither.flatMap((responseMap) => right(unit));
  }

  Future<Either<BiocentralException, String>> startTraining(String configFile, String databaseHash) async {
    final responseEither = await doPostRequest(PredictionModelsServiceEndpoints.startTrainingEndpoint,
        {'config_file': configFile, 'database_hash': databaseHash},);
    return responseEither.flatMap((responseMap) => right(responseMap['model_hash']));
  }

  Future<Either<BiocentralException, BiotrainerTrainingResult?>> _getTrainingStatus(String modelHash) async {
    final responseEither = await doGetRequest('${PredictionModelsServiceEndpoints.trainingStatusEndpoint}/$modelHash');
    return responseEither.flatMap((responseMap) => BiotrainerTrainingResult.fromDTO(BiocentralDTO(responseMap)));
  }

  Stream<PredictionModel> biotrainerTrainingStatusStream(String modelHash, PredictionModel initialModel) async* {
    const int maxRequests = 1800; // TODO Listening for only 60 Minutes
    bool finished = false;
    PredictionModel currentModel = initialModel;
    for (int i = 0; i < maxRequests; i++) {
      if (finished) {
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
      final biotrainerTrainingResultEither = await _getTrainingStatus(modelHash);

      if(biotrainerTrainingResultEither.isLeft() || biotrainerTrainingResultEither.getRight().isNone()) {
        finished = true;
        continue;
      }
      final biotrainerTrainingResult = biotrainerTrainingResultEither.getRight().getOrElse(() => null);
      if(biotrainerTrainingResult == null) {
        finished = true;
        continue;
      }
      if (biotrainerTrainingResult.trainingStatus == BiotrainerTrainingStatus.finished) {
        finished = true;
      }
      currentModel = currentModel.updateTrainingResult(biotrainerTrainingResult);
      yield currentModel;
    }
  }

  Future<Either<BiocentralException, Map<StorageFileType, dynamic>>> getModelFiles(
      String databaseHash, String modelHash,) async {
    final responseEither = await doPostRequest(
        PredictionModelsServiceEndpoints.modelFilesEndpoint, {'database_hash': databaseHash, 'model_hash': modelHash},);
    return responseEither.flatMap((responseMap) => right((responseMap as Map<String, dynamic>)
        .map((key, value) => MapEntry(enumFromString<StorageFileType>(key, StorageFileType.values)!, value)),),);
  }

  @override
  String getServiceName() {
    return 'prediction_models_service';
  }
}
