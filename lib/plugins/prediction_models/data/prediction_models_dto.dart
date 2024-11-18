import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_dto.dart';

import 'prediction_models_service_api.dart';

extension PredictionModelsData on BiocentralDTO {
  String? get logFile => get<String>('log_file');

  BiotrainerTrainingStatus? get trainingStatus {
    return enumFromString(get<String>('status') ?? '', BiotrainerTrainingStatus.values);
  }
}
