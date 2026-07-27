import 'package:biocentral/sdk/biocentral_sdk.dart';

class BiocentralDTO {
  final Map responseMap;

  BiocentralDTO(this.responseMap);

  T? get<T>(String key) => responseMap[key] as T?;
}

extension BiocentralTaskDTO on BiocentralDTO {
  // Default methods used across multiple plugins
  BiocentralTaskStatus? get taskStatus {
    return enumFromString(get<String?>('status'), BiocentralTaskStatus.values);
  }
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
