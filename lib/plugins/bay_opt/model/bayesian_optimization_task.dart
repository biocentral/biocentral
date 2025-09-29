// Define an enum for task types
enum TaskType {
  findOptimalValues,
  findHighestProbability,
}

// Extension to get display string for UI
extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.findOptimalValues:
        return 'Find proteins with optimal values for feature...';
      case TaskType.findHighestProbability:
        return 'Find proteins with the highest probability to have feature...';
    }
  }
}