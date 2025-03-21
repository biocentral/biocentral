import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';
import 'package:biocentral/plugins/prediction_models/model/prediction_model.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:fpdart/fpdart.dart';

final class PredictionModelsClientFactory extends BiocentralClientFactory<PredictionModelsClient> {
  @override
  PredictionModelsClient create(BiocentralServerData? server, BiocentralHubServerClient hubServerClient) {
    return PredictionModelsClient(server, hubServerClient);
  }
}

class PredictionModelsClient extends BiocentralClient {
  const PredictionModelsClient(super._server, super._hubServerClient);

  Future<Either<BiocentralException, List<String>>> getAvailableBiotrainerProtocols() async {
    final responseEither = await doGetRequest(PredictionModelsServiceEndpoints.protocols);
    return responseEither.match((error) => left(error), (responseMap) {
      final List<String> availableProtocols = List<String>.from(responseMap['protocols']);
      return right(availableProtocols);
    });
  }

  Future<Either<BiocentralException, List<BiocentralConfigOption>>> getBiotrainerConfigOptionsByProtocol(
    String protocol,
  ) async {
    final responseEither = await doGetRequest(PredictionModelsServiceEndpoints.configOptions + protocol.trim());
    return responseEither.match((error) => left(error), (responseMap) {
      final List<dynamic> configOptions = responseMap['options'];
      return right(configOptions.map((configOption) => BiocentralConfigOption.fromMap(configOption)).toList());
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

  Future<Either<BiocentralException, PredictionModel>> resumeTraining(
      String taskID, PredictionModel initialModel) async {
    final responseEither = await resumeTask(taskID);
    return responseEither.flatMap((dtos) {
      PredictionModel? currentModel = initialModel;
      for (final dto in dtos) {
        currentModel = _updateFunction(currentModel, dto);
      }
      if (currentModel == null) {
        return left(BiocentralParsingException(message: 'Could not parse resumed model from server dtos!'));
      }
      return right(currentModel);
    });
  }

  PredictionModel? _updateFunction(PredictionModel? currentModel, BiocentralDTO biocentralDTO) {
    // TODO IF fromDTO returns null, current model will never update again
    return currentModel?.updateFromDTO(biocentralDTO);
  }

  Stream<PredictionModel?> biotrainerTrainingTaskStream(String taskID, PredictionModel initialModel) async* {
    yield* taskUpdateStream<PredictionModel?>(taskID, initialModel, _updateFunction);
  }

  Future<Either<BiocentralException, Map<StorageFileType, dynamic>>> getModelFiles(
    String modelHash,
  ) async {
    final responseEither = await doPostRequest(
      PredictionModelsServiceEndpoints.modelFiles,
      {'model_hash': modelHash},
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
