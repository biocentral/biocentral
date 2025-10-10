import 'package:biocentral/sdk/model/split_set.dart';
import 'package:collection/collection.dart';

class BiocentralDatabaseColumn {
  final String name;
  final Map<String, dynamic> values;

  BiocentralDatabaseColumn({required this.name, required this.values});

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

  List<String> get ids => List.from(values.keys);

  int get length => values.keys.length;
}