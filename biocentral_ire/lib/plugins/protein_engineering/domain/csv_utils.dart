/// Values in a measured column that mean the variant was tested but did not express.
const didNotExpressMarkers = {'dne', 'did not express', 'not expressed', 'no expression'};

/// A parsed CSV file: lowercase header names and the data rows below them.
class CsvTable {
  final String delimiter;
  final List<String> header;
  final List<List<String>> rows;

  CsvTable({required this.delimiter, required List<String> header, required List<List<String>> rows})
    : header = List.unmodifiable(header),
      rows = List.unmodifiable(rows.map((row) => List<String>.unmodifiable(row)));

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
  final source = content.replaceFirst('\uFEFF', '');
  if (source.trim().isEmpty) return null;
  var quoted = false;
  var commas = 0;
  var semicolons = 0;
  for (var i = 0; i < source.length; i++) {
    if (source[i] == '"') quoted = !quoted;
    if (!quoted && source[i] == ',') commas++;
    if (!quoted && source[i] == ';') semicolons++;
    if (!quoted && (source[i] == '\n' || source[i] == '\r')) {
      break;
    }
  }
  final delimiter = semicolons > commas ? ';' : ',';
  final rows = <List<String>>[];
  var row = <String>[];
  var field = StringBuffer();
  quoted = false;
  void finishRow() {
    row.add(field.toString().trim());
    if (row.any((value) => value.isNotEmpty)) rows.add(row);
    row = [];
    field = StringBuffer();
  }

  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    if (char == '"') {
      if (quoted && i + 1 < source.length && source[i + 1] == '"') {
        field.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (!quoted && char == delimiter) {
      row.add(field.toString().trim());
      field = StringBuffer();
    } else if (!quoted && (char == '\n' || char == '\r')) {
      finishRow();
      if (char == '\r' && i + 1 < source.length && source[i + 1] == '\n') i++;
    } else {
      field.write(char);
    }
  }
  if (quoted) throw const FormatException('CSV contains an unterminated quoted field.');
  finishRow();
  if (rows.isEmpty) return null;
  final header = rows.first.map((name) => name.toLowerCase()).toList();
  if (header.toSet().length != header.length) throw const FormatException('CSV contains duplicate column names.');
  for (var index = 1; index < rows.length; index++) {
    if (rows[index].length > header.length) {
      throw FormatException('Row ${index + 1} has more fields than the header. Check the delimiter and quoted values.');
    }
  }
  return CsvTable(delimiter: delimiter, header: header, rows: rows.skip(1).toList());
}

/// A measured value: a number, or a "did not express" marker. Null if [raw] is neither.
/// With ";" as delimiter, a decimal comma is accepted.
({bool didNotExpress, double? value})? parseMeasuredValue(String raw, String delimiter) {
  if (didNotExpressMarkers.contains(raw.toLowerCase())) {
    return (didNotExpress: true, value: null);
  }
  final value = double.tryParse(delimiter == ';' ? raw.replaceAll(',', '.') : raw);
  return value == null || !value.isFinite ? null : (didNotExpress: false, value: value);
}

/// Encodes one CSV record, preserving delimiters and quotes inside field values.
String encodeCsvRecord(Iterable<String> values) =>
    values.map((value) => value.contains(RegExp('[",\r\n]')) ? '"${value.replaceAll('"', '""')}"' : value).join(',');
