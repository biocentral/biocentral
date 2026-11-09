class ParsedFastaEntry {
  final String id;
  final String sequence;

  const ParsedFastaEntry({required this.id, required this.sequence});
}

/// Reads only the first record and uppercases its sequence.
/// Returns null if the header, identifier or sequence is missing.
ParsedFastaEntry? parseFirstFastaEntry(String content) {
  final headerStart = content.indexOf('>');
  if (headerStart == -1) {
    return null;
  }
  final afterHeader = content.substring(headerStart + 1);
  final lines = afterHeader.split('\n');
  if (lines.isEmpty) {
    return null;
  }
  final header = lines.first.trim();
  final id = header.split(RegExp(r'\s')).first;

  final sequenceLines = <String>[];
  for (final line in lines.skip(1)) {
    if (line.startsWith('>')) {
      break;
    }
    sequenceLines.add(line.trim());
  }
  final sequence = sequenceLines.join().toUpperCase();
  if (id.isEmpty || sequence.isEmpty) {
    return null;
  }
  return ParsedFastaEntry(id: id, sequence: sequence);
}
