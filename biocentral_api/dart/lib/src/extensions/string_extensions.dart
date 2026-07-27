import '../model/common_embedder.dart';
import '../model/protocol.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension CommonEmbedderDisplay on CommonEmbedder {
  String displayName() {
    final wN = wireName;
    final n = name.capitalize();
    if (wN.contains('/')) {
      return '$n ($wN)';
    }
    return n.toLowerCase();
  }
}

extension TrainingType on Protocol {
  String trainingType() {
    if (name.toLowerCase().contains('value')) {
      return 'Regression';
    }
    return 'Classification';
  }
}
