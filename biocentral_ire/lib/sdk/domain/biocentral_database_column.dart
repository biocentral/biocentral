import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/model/split_set.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';

class BiocentralDatabaseColumn {
  final String name;
  final Map<String, dynamic> values;

  BiocentralDatabaseColumn({required this.name, required this.values});

  List<String> get ids => List.from(values.keys);

  int get length => values.keys.length;

  int get numberNotNull => values.values.where((v) => v != null && v.toString().trim().isNotEmpty).length;

  int get numberNull => values.values.where((v) => v == null || v.toString().trim().isEmpty).length;

  bool get isBinary => uniqueValues().length == 2;

  bool get isNumeric => values.values.all((v) => v == null || num.tryParse(v) != null);

  Set<String> uniqueValues() {
    return values.values.map((v) => v.toString()).toSet();
  }
}

extension SetColumn on BiocentralDatabaseColumn {
  Set<SplitSet> detectSplitSets() {
    final splitSets = <SplitSet>{};
    for(final (value) in values.values) {
      final splitSet = SplitSet.values.firstWhereOrNull((splitSet) => splitSet.name == value.toString());
      if(splitSet != null) {
        splitSets.add(splitSet);
      }
      if(splitSets.length == SplitSet.values.length) {
        break; // all split sets are available, we can already stop here
      }
    }
    return splitSets;
  }

  String formatAsSplitSets() {
    final Map<SplitSet, int> splitDistribution = {};
    for(final (value) in values.values) {
      final splitSet = SplitSet.values.firstWhereOrNull((splitSet) => splitSet.name == value.toString());
      if(splitSet == null) {
        return 'Failed to detect splits!';
      }
      splitDistribution.putIfAbsent(splitSet, () => 0);
      final currentValue = splitDistribution[splitSet] ?? 0;
      splitDistribution[splitSet] = (currentValue + 1);
    }
    String result = '';
    for(final (splitSet, n) in splitDistribution.entriesRecord) {
      result += '${splitSet.name}: $n ';
    }
    return result;
  }
}

extension TrainingColumn on BiocentralDatabaseColumn {
  Set<Protocol> detectPotentialTrainingProtocols({Map<String, String>? sequences}) {
    final result = Protocol.values.toSet();
    for(final (key, value) in values.entriesRecord) {
      if(result.isEmpty || value == null || value.toString().isEmpty) {
        return {}; // Early stopping
      }
      final maybeSequence = sequences?[key];
      if(maybeSequence != null && maybeSequence.isNotEmpty) {
        // TODO residuesToValue: Split ;
        if(value.toString().length != maybeSequence.length) {
          // Mismatch between N residues and N targets
          result.remove(Protocol.residueToClass);
          result.remove(Protocol.residueToValue);
        }
      }
      final maybeDouble = double.tryParse(value);
      if(maybeDouble == null) {
        result.remove(Protocol.residuesToValue);
        result.remove(Protocol.sequenceToValue);
      }
    }
    return result;
  }
}

extension ActiveLearningColumn on BiocentralDatabaseColumn {
  bool isPartiallyUnlabeled() => numberNull > 0 && numberNotNull > 0;
}

extension ColumnWizardConversion on BiocentralDatabaseColumn {
  Future<ColumnWizard> toColumnWizard(BiocentralColumnWizardRepository columnWizardRepository) async {
    return columnWizardRepository.getColumnWizardForColumn(column: this);
  }
}
