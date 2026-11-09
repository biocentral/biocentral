/// Values in a measured column that mean the variant was tested but did not express.
const didNotExpressMarkers = {'dne', 'did not express', 'not expressed', 'no expression'};

/// A parsed CSV file: lowercase header names and the data rows below them.
class CsvTable {
  final String delimiter;
  final List<String> header;
  final List<List<String>> rows;

  const CsvTable({required this.delimiter, required this.header, required this.rows});

  /// Index of the first header that is one of [names], or -1.
  int column(List<String> names) => header.indexWhere(names.contains);

  /// The trimmed cell, or '' if the row is shorter or [column] is -1.
  static String cell(List<String> row, int column) => column >= 0 && column < row.length ? row[column] : '';

  /// "Row N" as a spreadsheet shows it: the header is row 1.
  static String rowName(int rowIndex) => 'Row ${rowIndex + 2}';
}

/// Parses [content], or returns null if it has no lines. Handles Excel's byte order mark,
/// quoted fields, and ";" as delimiter (spreadsheets in some locales save that way).
CsvTable? readCsvTable(String content) {
  final lines = content
      .replaceFirst('\uFEFF', '')
      .split(RegExp(r'\r?\n'))
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    return null;
  }
  final delimiter = lines.first.contains(';') && !lines.first.contains(',') ? ';' : ',';
  return CsvTable(
    delimiter: delimiter,
    header: _splitCsvLine(lines.first, delimiter).map((name) => name.toLowerCase()).toList(),
    rows: [for (final line in lines.skip(1)) _splitCsvLine(line, delimiter)],
  );
}

/// A measured value: a number, or a "did not express" marker. Null if [raw] is neither.
/// With ";" as delimiter, a decimal comma is accepted.
({bool didNotExpress, double? value})? parseMeasuredValue(String raw, String delimiter) {
  if (didNotExpressMarkers.contains(raw.toLowerCase())) {
    return (didNotExpress: true, value: null);
  }
  final value = double.tryParse(delimiter == ';' ? raw.replaceAll(',', '.') : raw);
  return value == null ? null : (didNotExpress: false, value: value);
}

/// Splits one CSV line, honoring double-quoted fields (as written by Excel and others).
List<String> _splitCsvLine(String line, String delimiter) {
  final fields = <String>[];
  final current = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == delimiter && !inQuotes) {
      fields.add(current.toString().trim());
      current.clear();
    } else {
      current.write(char);
    }
  }
  fields.add(current.toString().trim());
  return fields;
}
