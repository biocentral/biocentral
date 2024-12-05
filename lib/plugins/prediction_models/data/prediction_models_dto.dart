import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_task_dto.dart';

import 'package:biocentral/plugins/prediction_models/data/prediction_models_service_api.dart';

extension PredictionModelsDTO on BiocentralTaskDTO {
  String? get logFile => get<String>('log_file');
}
