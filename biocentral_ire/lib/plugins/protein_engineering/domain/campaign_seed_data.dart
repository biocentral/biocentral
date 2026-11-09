import 'package:biocentral/plugins/protein_engineering/domain/csv_utils.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';

/// Measurements a new campaign starts with, relative to its wildtype.
class SeedData {
  final List<SeedMeasurement> measurements;

  /// The wildtype's own value, if the data contains it.
  final double? wildtypeFitness;

  /// Problems that make the data unsafe to use, e.g. "Row 4: "abc" is not a number."
  final List<String> errors;

  /// Rows without a value, i.e. not measured.
  final int blank;

  SeedData({
    required List<SeedMeasurement> measurements,
    this.wildtypeFitness,
    List<String> errors = const [],
    this.blank = 0,
  }) : measurements = List.unmodifiable(measurements),
       errors = List.unmodifiable(errors);

  const SeedData._empty() : measurements = const [], wildtypeFitness = null, errors = const [], blank = 0;

  static const empty = SeedData._empty();

  int get count => measurements.length + (wildtypeFitness == null ? 0 : 1);
}

const _valueColumnNames = ['measured', 'value', 'fitness', 'label'];
const _wildtypeLabels = {'wt', 'wildtype', 'wild type', 'wild-type'};

/// Reads measurements from a CSV with a "sequence" or "variant" column and a value column
/// ("measured", "value", "fitness" or "label"). Variants are written relative to the wildtype,
/// e.g. "A12V" or "A12V + D88N" (also "A12V:D88N"); sequences are preferred when both are given.
SeedData parseSeedDataCsv(String content, String wildtypeSequence) {
  SeedData failed(String error) => SeedData(measurements: const [], errors: [error]);

  final table = readCsvTable(content);
  if (table == null) {
    return failed('The file is empty.');
  }
  final sequenceColumn = table.column(['sequence']);
  final variantColumn = table.column(['variant']);
  final valueColumn = table.column(_valueColumnNames);
  if (valueColumn < 0 || (sequenceColumn < 0 && variantColumn < 0)) {
    return failed(
      'Missing columns: the file needs a "sequence" or "variant" column and a value column '
      '(${_valueColumnNames.map((name) => '"$name"').join(', ')}).',
    );
  }

  final measurements = <SeedMeasurement>[];
  final errors = <String>[];
  final seen = <String>{};
  double? wildtypeFitness;
  var blank = 0;

  for (var i = 0; i < table.rows.length; i++) {
    final rowName = CsvTable.rowName(i);
    String field(int column) => CsvTable.cell(table.rows[i], column);

    final rawValue = field(valueColumn);
    if (rawValue.isEmpty) {
      blank++;
      continue;
    }

    final (sequence, error) = _resolveSequence(field(sequenceColumn), field(variantColumn), wildtypeSequence);
    if (error != null) {
      errors.add('$rowName: $error');
      continue;
    }
    if (!seen.add(sequence!)) {
      errors.add('$rowName: this variant appears more than once.');
      continue;
    }

    final measured = parseMeasuredValue(rawValue, table.delimiter);
    if (measured == null) {
      errors.add('$rowName: "$rawValue" is not a number or "DNE".');
      continue;
    }

    if (sequence == wildtypeSequence) {
      if (measured.didNotExpress) {
        errors.add('$rowName: the wildtype needs a value, not "did not express".');
        continue;
      }
      wildtypeFitness = measured.value;
      continue;
    }
    measurements.add(
      SeedMeasurement(
        substitutions: parseMutationDescriptor(wildtypeRelativeDescriptor(wildtypeSequence, sequence)!),
        fitness: measured.value,
      ),
    );
  }

  return SeedData(measurements: measurements, wildtypeFitness: wildtypeFitness, errors: errors, blank: blank);
}

/// The full sequence a row describes, or an error explaining why it can't be used.
(String?, String?) _resolveSequence(String rawSequence, String rawVariant, String wildtype) {
  if (rawSequence.isNotEmpty) {
    final sequence = rawSequence.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (sequence.length != wildtype.length) {
      return (null, 'the sequence has ${sequence.length} residues, the wildtype ${wildtype.length}.');
    }
    final invalidIndex = findInvalidResidueIndex(sequence);
    if (invalidIndex != null) {
      return (null, 'position ${invalidIndex + 1} ("${sequence[invalidIndex]}") is not a standard amino acid.');
    }
    return (sequence, null);
  }

  if (_wildtypeLabels.contains(rawVariant.toLowerCase())) {
    return (wildtype, null);
  }
  final tokens = rawVariant.split(RegExp(r'[:+]')).map((token) => token.trim()).where((token) => token.isNotEmpty);
  final substitutions = <Substitution>[];
  try {
    for (final token in tokens) {
      substitutions.addAll(parseMutationDescriptor(token.toUpperCase()));
    }
  } on UnresolvableVariantException {
    return (null, '"$rawVariant" is not a variant like "A12V" or "A12V + D88N".');
  }
  if (substitutions.isEmpty) {
    return (null, 'neither a sequence nor a variant is given.');
  }
  final sequence = applySubstitutions(wildtype, substitutions);
  if (sequence == null) {
    return (null, '"$rawVariant" does not match the wildtype (check positions and original residues).');
  }
  return (sequence, null);
}

/// An existing campaign's measurements as starting data for a new campaign. Every variant becomes
/// round-0 data relative to the wildtype, since the new campaign starts without rounds.
SeedData seedDataFromCampaign(EngineeringCampaign campaign) {
  final wildtype = campaign.wildtypeSequence;
  final measurements = <SeedMeasurement>[];
  double? wildtypeFitness = campaign.wildtypeFitness;
  for (final variant in campaign.measurements.values) {
    if (variant.sequence == wildtype) {
      wildtypeFitness = variant.fitness ?? wildtypeFitness;
      continue;
    }
    final descriptor = wildtypeRelativeDescriptor(wildtype, variant.sequence);
    if (descriptor == null) {
      continue; // Different length; can't be expressed as substitutions.
    }
    measurements.add(SeedMeasurement(substitutions: parseMutationDescriptor(descriptor), fitness: variant.fitness));
  }
  return SeedData(measurements: measurements, wildtypeFitness: wildtypeFitness);
}
