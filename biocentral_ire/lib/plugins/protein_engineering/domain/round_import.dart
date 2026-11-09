import 'package:biocentral/plugins/protein_engineering/domain/csv_utils.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';

/// The outcome of reading a filled-in bench CSV: what can be imported, and what is wrong.
class MeasurementImport {
  final List<MeasuredVariant> newMeasurements;

  /// Problems that make the file unsafe to import, e.g. "Row 4: "abc" is not a number."
  final List<String> errors;

  /// Rows whose variant already has a measurement; never overwritten.
  final int alreadyMeasured;

  /// Rows with an empty measured value, i.e. not measured yet.
  final int blank;

  MeasurementImport({
    required List<MeasuredVariant> newMeasurements,
    required List<String> errors,
    required this.alreadyMeasured,
    required this.blank,
  }) : newMeasurements = List.unmodifiable(newMeasurements),
       errors = List.unmodifiable(errors);

  bool get canImport => errors.isEmpty && newMeasurements.isNotEmpty;

  Set<int> get rounds => {for (final variant in newMeasurements) variant.roundFound};
}

/// Every suggested variant of every round, as the measurement it would become.
List<MeasuredVariant> _suggestedVariants(EngineeringCampaign campaign) {
  final variants = <MeasuredVariant>[];
  for (final round in campaign.rounds) {
    for (final entityId in round.result.suggestions.toSet()) {
      try {
        final substitutions = parseMutationDescriptor(entityId);
        final sequence = applySubstitutions(round.parentSequence, substitutions);
        if (sequence != null) {
          variants.add(
            MeasuredVariant(
              seqId: entityId,
              sequence: sequence,
              parentSequence: round.parentSequence,
              substitutions: substitutions,
              roundFound: round.sentConfig.iteration,
            ),
          );
        }
      } on UnresolvableVariantException {
        // Can't be matched by sequence; skipped like in the round view.
      }
    }
  }
  return variants;
}

/// Reads a CSV in the format written by "Export for the bench", from any round or several
/// rounds combined. Rows are matched by sequence, or by variant label if that is unambiguous.
/// Only variants without a measurement are filled in.
MeasurementImport parseMeasurementsCsv(String content, EngineeringCampaign campaign) {
  final table = readCsvTable(content);
  if (table == null) {
    return MeasurementImport(newMeasurements: [], errors: ['The file is empty.'], alreadyMeasured: 0, blank: 0);
  }
  final sequenceColumn = table.column(['sequence']);
  final variantColumn = table.column(['variant']);
  final measuredColumn = table.column(['measured']);
  if (measuredColumn < 0 || (sequenceColumn < 0 && variantColumn < 0)) {
    return MeasurementImport(
      newMeasurements: [],
      errors: ['Missing columns: the file needs a "measured" column and a "sequence" or "variant" column.'],
      alreadyMeasured: 0,
      blank: 0,
    );
  }

  final suggested = _suggestedVariants(campaign);
  final bySequence = {for (final variant in suggested) variant.sequence: variant};
  final byLabel = <String, List<MeasuredVariant>>{};
  for (final variant in bySequence.values) {
    byLabel.putIfAbsent(formatSubstitutions(variant.substitutions), () => []).add(variant);
  }

  final newMeasurements = <MeasuredVariant>[];
  final errors = <String>[];
  final seen = <String>{};
  var alreadyMeasured = 0;
  var blank = 0;

  for (var i = 0; i < table.rows.length; i++) {
    final rowName = CsvTable.rowName(i);
    String field(int column) => CsvTable.cell(table.rows[i], column);

    final rawValue = field(measuredColumn);
    if (rawValue.isEmpty) {
      blank++;
      continue;
    }

    final sequence = field(sequenceColumn).toUpperCase();
    final label = field(variantColumn);
    MeasuredVariant? base;
    if (sequence.isNotEmpty) {
      base = bySequence[sequence];
      if (base == null) {
        errors.add('$rowName: the sequence is not one of the suggested variants.');
        continue;
      }
    } else {
      final matches = byLabel[label] ?? [];
      if (matches.length != 1) {
        errors.add(
          matches.isEmpty
              ? '$rowName: "$label" is not one of the suggested variants.'
              : '$rowName: "$label" was suggested in several rounds; add its sequence.',
        );
        continue;
      }
      base = matches.single;
    }

    if (!seen.add(base.sequence)) {
      errors.add('$rowName: ${formatSubstitutions(base.substitutions)} appears more than once.');
      continue;
    }

    final measured = parseMeasuredValue(rawValue, table.delimiter);
    if (measured == null) {
      errors.add('$rowName: "$rawValue" is not a number or "DNE".');
      continue;
    }

    if (campaign.measurements.containsKey(base.sequence)) {
      alreadyMeasured++;
      continue;
    }

    newMeasurements.add(
      MeasuredVariant(
        seqId: base.seqId,
        sequence: base.sequence,
        parentSequence: base.parentSequence,
        substitutions: base.substitutions,
        roundFound: base.roundFound,
        fitness: measured.value,
      ),
    );
  }

  return MeasurementImport(
    newMeasurements: newMeasurements,
    errors: errors,
    alreadyMeasured: alreadyMeasured,
    blank: blank,
  );
}
