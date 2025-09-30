// Define an enum for task types
enum BayOptTaskType {
  findOptimalValues,
  findHighestProbability;

  String get displayName {
    switch (this) {
      case BayOptTaskType.findOptimalValues:
        return 'Find proteins with optimal values for feature...';
      case BayOptTaskType.findHighestProbability:
        return 'Find proteins with the highest probability to have feature...';
    }
  }
}
