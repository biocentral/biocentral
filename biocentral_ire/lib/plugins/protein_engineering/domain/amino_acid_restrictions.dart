import 'package:equatable/equatable.dart';

/// Amino acids that must not be introduced at a set of 1-based positions.
class PositionRestriction extends Equatable {
  final Set<int> positions;
  final Set<String> excludedAminoAcids;

  PositionRestriction({required Set<int> positions, required Set<String> excludedAminoAcids})
    : positions = Set.unmodifiable(positions),
      excludedAminoAcids = Set.unmodifiable(excludedAminoAcids);

  @override
  List<Object?> get props => [positions, excludedAminoAcids];

  factory PositionRestriction.deserialize(Map<String, dynamic> jsonMap) {
    return PositionRestriction(
      positions: {for (final position in jsonMap['positions'] as List<dynamic>? ?? []) position as int},
      excludedAminoAcids: {for (final aa in jsonMap['excludedAminoAcids'] as List<dynamic>? ?? []) aa as String},
    );
  }

  Map<String, dynamic> serialize() {
    return {'positions': (positions.toList()..sort()), 'excludedAminoAcids': (excludedAminoAcids.toList()..sort())};
  }
}

/// Recorded mutation exclusions, global and per-position.
///
/// These settings are retained for provenance; backend enforcement is not implemented.
class AminoAcidRestrictions extends Equatable {
  final Set<String> globallyExcluded;
  final List<PositionRestriction> positionRestrictions;

  AminoAcidRestrictions({
    Set<String> globallyExcluded = const {},
    List<PositionRestriction> positionRestrictions = const [],
  }) : globallyExcluded = Set.unmodifiable(globallyExcluded),
       positionRestrictions = List.unmodifiable(
         positionRestrictions.where((rule) => rule.positions.isNotEmpty && rule.excludedAminoAcids.isNotEmpty),
       );

  const AminoAcidRestrictions.empty() : globallyExcluded = const {}, positionRestrictions = const [];

  @override
  List<Object?> get props => [globallyExcluded, positionRestrictions];

  bool get isEmpty =>
      globallyExcluded.isEmpty &&
      positionRestrictions.every((rule) => rule.positions.isEmpty || rule.excludedAminoAcids.isEmpty);

  factory AminoAcidRestrictions.deserialize(Map<String, dynamic>? jsonMap) {
    if (jsonMap == null) {
      return const AminoAcidRestrictions.empty();
    }
    return AminoAcidRestrictions(
      globallyExcluded: {for (final aa in jsonMap['globallyExcluded'] as List<dynamic>? ?? []) aa as String},
      positionRestrictions: [
        for (final rule in jsonMap['positionRestrictions'] as List<dynamic>? ?? [])
          PositionRestriction.deserialize(rule as Map<String, dynamic>),
      ],
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'globallyExcluded': (globallyExcluded.toList()..sort()),
      'positionRestrictions': positionRestrictions.map((rule) => rule.serialize()).toList(),
    };
  }
}

class PositionParseException implements Exception {
  final String message;

  PositionParseException(this.message);

  @override
  String toString() => message;
}

/// Parses "34, 52, 67, 120-135" into 1-based positions, checked against [sequenceLength].
Set<int> parsePositions(String text, {required int sequenceLength}) {
  final positions = <int>{};
  for (final rawToken in text.split(RegExp(r'[,;\s]+'))) {
    final token = rawToken.trim();
    if (token.isEmpty) {
      continue;
    }
    final range = RegExp(r'^(\d+)-(\d+)$').firstMatch(token);
    final start = range != null ? int.parse(range.group(1)!) : int.tryParse(token);
    final end = range != null ? int.parse(range.group(2)!) : start;
    if (start == null || end == null) {
      throw PositionParseException('"$token" is not a position or range like 120-135.');
    }
    if (start > end) {
      throw PositionParseException('Range "$token" ends before it starts.');
    }
    if (start < 1 || end > sequenceLength) {
      throw PositionParseException('"$token" is outside the sequence (1-$sequenceLength).');
    }
    for (var position = start; position <= end; position++) {
      positions.add(position);
    }
  }
  return positions;
}

/// Formats positions compactly, joining consecutive runs: {1, 2, 3, 7} -> "1-3, 7".
String formatPositions(Set<int> positions) {
  final sorted = positions.toList()..sort();
  final parts = <String>[];
  var i = 0;
  while (i < sorted.length) {
    var j = i;
    while (j + 1 < sorted.length && sorted[j + 1] == sorted[j] + 1) {
      j++;
    }
    parts.add(j > i ? '${sorted[i]}-${sorted[j]}' : '${sorted[i]}');
    i = j + 1;
  }
  return parts.join(', ');
}
