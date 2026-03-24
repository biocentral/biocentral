// Define an enum for task types
enum ALTaskType {
  findOptimalValues,
  findHighestProbability;

  String get displayName {
    switch (this) {
      case ALTaskType.findOptimalValues:
        return 'Find proteins with optimal values for feature...';
      case ALTaskType.findHighestProbability:
        return 'Find proteins with the highest probability to have feature...';
    }
  }
}
