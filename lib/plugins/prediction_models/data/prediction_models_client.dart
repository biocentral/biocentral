import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:fpdart/fpdart.dart';

import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';

final class PredictionModelsClientFactory extends BiocentralClientFactory<PredictionModelsClient> {
  @override
  PredictionModelsClient create(BiocentralServerData? server) {
    return PredictionModelsClient(server);
  }
}

class PredictionModelsClient extends BiocentralClient {
  PredictionModelsClient(super._server);

  Future<Either<BiocentralException, List<String>>> getAvailableBiotrainerProtocols() async {
    final responseEither = await doGetRequest(PredictionModelsServiceEndpoints.protocols);
    return responseEither.match((error) => left(error), (responseMap) {
      final List<String> availableProtocols = List<String>.from(responseMap['protocols']);
      return right(availableProtocols);
    });
  }

  Future<Either<BiocentralException, List<BiotrainerOption>>> getBiotrainerConfigOptionsByProtocol(
    String protocol,
  ) async {
    final responseEither = await doGetRequest(PredictionModelsServiceEndpoints.configOptions + protocol.trim());
    return responseEither.match((error) => left(error), (responseMap) {
      final List<dynamic> configOptions = responseMap['options'];
      return right(configOptions.map((configOption) => BiotrainerOption.fromMap(configOption)).toList());
    });
  }

  Future<Either<BiocentralException, Unit>> verifyBiotrainerConfig(String configFile) async {
    final responseEither =
        await doPostRequest(PredictionModelsServiceEndpoints.verifyConfig, {'config_file': configFile});
    // EMPTY STRING "" -> NO ERROR
    return responseEither.flatMap((responseMap) => right(unit));
  }

  Future<Either<BiocentralException, String>> startTraining(String configFile, String databaseHash) async {
    final responseEither = await doPostRequest(
      PredictionModelsServiceEndpoints.startTraining,
      {'config_file': configFile, 'database_hash': databaseHash},
    );
    return responseEither.flatMap((responseMap) => right(responseMap['task_id']));
  }

  Stream<PredictionModel?> biotrainerTrainingTaskStream(String taskID, PredictionModel initialModel) async* {
    PredictionModel? updateFunction(PredictionModel? currentModel, BiocentralTaskDTO biocentralDTO) =>
        currentModel?.updateTrainingResult(BiotrainerTrainingResult.fromDTO(biocentralDTO).getOrElse((e) => null));
    yield* taskUpdateStream<PredictionModel?>(taskID, initialModel, updateFunction);
  }

  Future<Either<BiocentralException, Map<StorageFileType, dynamic>>> getModelFiles(
    String databaseHash,
    String modelHash,
  ) async {
    final responseEither = await doPostRequest(
      PredictionModelsServiceEndpoints.modelFiles,
      {'database_hash': databaseHash, 'model_hash': modelHash},
    );
    return responseEither.flatMap(
      (responseMap) => right(
        (responseMap as Map<String, dynamic>)
            .map((key, value) => MapEntry(enumFromString<StorageFileType>(key, StorageFileType.values)!, value)),
      ),
    );
  }

  @override
  String getServiceName() {
    return 'prediction_models_service';
  }
}
