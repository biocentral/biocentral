import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

class SequenceColumnWizardFactory extends ColumnWizardFactory {
  @override
  ColumnWizard create({required String columnName, required Map<String, dynamic> valueMap}) {
    return SequenceColumnWizard(columnName, valueMap.map((k, v) => MapEntry(k, v as Sequence)));
  }

  @override
  TypeDetector getTypeDetector() {
    return TypeDetector(Sequence, (value) => value is Sequence);
  }
}

class SequenceColumnWizard extends ColumnWizard with CounterStats {
  @override
  final Map<String, Sequence> valueMap;

  @override
  Type get type => Sequence;

  SequenceColumnWizard(super.columnName, this.valueMap);

  Map<String, double>? _composition;

  Future<Map<String, double>> composition() async {
    if(_composition != null) {
      return _composition!;
    }

    final Map<String, int> counts = {};
    int totalCount = 0;

    for (Sequence sequence in valueMap.values) {
      for (String token in sequence.toString().split('')) {
        counts[token] = (counts[token] ?? 0) + 1;
        totalCount++;
      }
    }

    final Map<String, double> compositionResult = counts.map((k, v) => MapEntry(k, v / totalCount));
    _composition = compositionResult;

    return _composition!;
  }

  Map<int, int>? _lengthCount;

  /// Returns number of sequences for each found sequence length in the dataset
  Future<Map<int, int>> lengthCount() async {
    if(_lengthCount != null) {
      return _lengthCount!;
    }

    final Map<int, int> lengthCount = {};
    for(final sequence in valueMap.values) {
      final length = sequence.seq.length;
      lengthCount.putIfAbsent(length, () => 0);
      final updatedCount = lengthCount[length]! + 1;
      lengthCount[length] = updatedCount;
    }
    _lengthCount = lengthCount;

    return _lengthCount!;
  }
}
