import 'package:biocentral_api/src/model/task_dto.dart';

/// A handler that extracts a result from a list of TaskDTOs and can optionally
/// report progress.
abstract class DtoHandler<T> {
  /// Return a non-null value once the task produced a final result.
  /// Return null to continue polling.
  T? handle(List<TaskDTO> dtos);

  /// Optional hook for progress updates.
  void updateProgress(List<TaskDTO> dtos) {}
}
