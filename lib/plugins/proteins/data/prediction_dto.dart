import 'package:biocentral/sdk/data/biocentral_task_dto.dart';

extension PredictionDTO on BiocentralDTO {
  Map<String, dynamic>? get predictions => get<Map<String, dynamic>>('predictions');
}
