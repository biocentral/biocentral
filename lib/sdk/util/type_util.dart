Enum? enumFromString<Enum>(String? name, List<Enum> values) {
  if (name == null) {
    return null;
  }
  try {
    return values.firstWhere((element) => element.toString().toLowerCase().contains(name.toLowerCase()));
  } catch (e) {
    return null;
  }
}

Map<String, String> convertToStringMap(Map? map) {
  Map<String, String> result = {};

  if (map != null) {
    result = Map.fromEntries(map.entries.map((entry) => MapEntry(entry.key.toString(), entry.value.toString())));
  }

  return result;
}

Map<Type, T> convertListToTypeMap<T>(List<T>? values) {
  final Map<Type, T> result = {};
  for (T value in values ?? []) {
    result[value.runtimeType] = value;
  }
  return result;
}

extension RecordEntries<K, V> on Map<K, V> {
  /// Returns an [Iterable] of key-value pairs as records.
  ///
  /// Example:
  /// ```dart
  /// final map = {'a': 1, 'b': 2};
  /// for (final (key, value) in map.entriesRecord) {
  ///   print('$key: $value'); // Types are inferred: key as String, value as int
  /// }
  /// ```
  Iterable<(K, V)> get entriesRecord => entries.map((entry) => (entry.key, entry.value));
}

extension FilterNull on Map {
  Map<K, V> filterNull<K, V>() {
    final Map<K, V> result = {};
    for(final entry in entries) {
      if(entry.key != null && entry.value != null) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

mixin ComparableEnum on Enum implements Comparable<Enum> {
  @override
  int compareTo(Enum? other) {
    if (other == null) {
      return -1;
    }
    if (runtimeType == other.runtimeType) {
      return index.compareTo(other.index);
    }
    return -1;
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

dynamic copyMapExtractor(Map<String, dynamic>? copyMap, String key, dynamic defaultValue) {
  if (copyMap == null) {
    return defaultValue;
  }
  if (copyMap.containsKey(key)) {
    return copyMap[key];
  }
  return defaultValue;
}
