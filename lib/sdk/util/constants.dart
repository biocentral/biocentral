class Constants {
  static const Duration showLastStateMessageDuration = Duration(seconds: 5); // seconds

  static const int maxDoublePrecision = 3; // max 2 digits after comma

  static const int discreteColumnThreshold = 10; // handle columns with more than 10 discrete values as numerical

  static const int discreteSelectionThreshold = 5;

  static const String localHostServerURL = 'http://localhost:9540';

  static const Duration autoSaveDebounceTime = Duration(seconds: 2);
}
