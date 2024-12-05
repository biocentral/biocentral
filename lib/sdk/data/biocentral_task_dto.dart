import 'package:biocentral/sdk/biocentral_sdk.dart';

class BiocentralTaskDTO {
  final Map responseMap;

  BiocentralTaskDTO(this.responseMap);

  // Default methods used across multiple plugins
  String? get embedderName {
    return responseMap['embedder_name'];
  }

  BiocentralTaskStatus? get taskStatus {
    return enumFromString(get<String?>('status'), BiocentralTaskStatus.values);
  }

  T? get<T>(String key) => responseMap[key] as T?;
}

enum BiocentralTaskStatus {
  pending,
  running,
  finished,
  failed;

  bool isFinished() {
    return [BiocentralTaskStatus.finished, BiocentralTaskStatus.failed].contains(this);
  }
}
