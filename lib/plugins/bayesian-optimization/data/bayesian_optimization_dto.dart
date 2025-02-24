import 'package:biocentral/sdk/util/type_util.dart';

class BayesianOptimizationDTO {
  final Map responseMap;

  String? get utility => get<String>('utility');

  String? get prediction => get<String>('prediction');

  String? get uncertainty => get<String>('uncertainty');

  BayesianOptimizationDTO(this.responseMap);

  // Default methods used across multiple plugins
  String? get embedderName {
    return responseMap['embedder_name'];
  }

  BayesianOptimizationTaskStatus? get taskStatus {
    return enumFromString(
      get<String?>('status'),
      BayesianOptimizationTaskStatus.values,
    );
  }

  T? get<T>(String key) => responseMap[key] as T?;
}

//TODO: These states are temporory.
enum BayesianOptimizationTaskStatus {
  pending,
  running,
  finished,
  failed;

  bool isFinished() {
    return [
      BayesianOptimizationTaskStatus.finished,
      BayesianOptimizationTaskStatus.failed,
    ].contains(this);
  }
}
