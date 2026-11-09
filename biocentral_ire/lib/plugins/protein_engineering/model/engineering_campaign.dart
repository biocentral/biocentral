import 'dart:convert';
import 'dart:math';

import 'package:biocentral/plugins/protein_engineering/domain/amino_acid_restrictions.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// Creates a persistent identity independent of editable scientific configuration.
String newEngineeringId() {
  final random = Random.secure();
  return List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

/// Exact original input bytes, addressed by their SHA-256 digest.
class EngineeringInput {
  final String name;
  final String format;
  final List<int> bytes;

  EngineeringInput({required this.name, required this.format, required List<int> bytes})
    : bytes = List.unmodifiable(bytes);

  String get id => sha256.convert(bytes).toString();

  Map<String, dynamic> serialize() => {'id': id, 'name': name, 'format': format, 'bytes': base64Encode(bytes)};

  factory EngineeringInput.deserialize(Map<String, dynamic> json) {
    final input = EngineeringInput(
      name: json['name'] as String,
      format: json['format'] as String,
      bytes: base64Decode(json['bytes'] as String),
    );
    if (input.id != json['id']) throw const FormatException('Input content does not match its SHA-256 digest.');
    return input;
  }
}

/// An immutable campaign revision, including historical scientific inputs.
class EngineeringCampaign {
  final String id;
  final int revision;
  final String? sourceCampaignId;
  final ActiveLearningEngineeringCampaignConfig config;
  final String wildtypeId;
  final String wildtypeSequence;
  final double? _initialWildtypeFitness;
  final String measurementName;
  final String measurementUnit;
  final Map<String, MeasuredVariant> measurements;
  final List<EngineeringRound> rounds;
  final AminoAcidRestrictions aminoAcidRestrictions;
  final Map<String, EngineeringInput> inputs;
  final String? structureInputId;

  EngineeringCampaign({
    required this.config,
    required this.wildtypeId,
    required this.wildtypeSequence,
    required this.measurementName,
    required this.measurementUnit,
    String? id,
    this.revision = 0,
    this.sourceCampaignId,
    double? wildtypeFitness,
    Map<String, MeasuredVariant> measurements = const {},
    List<EngineeringRound> rounds = const [],
    this.aminoAcidRestrictions = const AminoAcidRestrictions.empty(),
    Map<String, EngineeringInput> inputs = const {},
    this.structureInputId,
  }) : id = id ?? newEngineeringId(),
       _initialWildtypeFitness = wildtypeFitness,
       measurements = Map.unmodifiable(measurements),
       rounds = List.unmodifiable(rounds),
       inputs = Map.unmodifiable(inputs) {
    _validate();
  }

  /// The currently applied wildtype measurement, including later corrections.
  double? get wildtypeFitness =>
      measurements.containsKey(wildtypeSequence) ? measurements[wildtypeSequence]!.fitness : _initialWildtypeFitness;

  void _validate() {
    if (id.isEmpty ||
        revision < 0 ||
        wildtypeId.isEmpty ||
        wildtypeSequence.isEmpty ||
        findInvalidResidueIndex(wildtypeSequence) != null ||
        config.wildtypeSequence != wildtypeSequence ||
        config.seed == null ||
        config.name.trim().isEmpty ||
        _initialWildtypeFitness?.isFinite == false) {
      throw const FormatException('Campaign identity, wildtype, seed, or initial fitness is invalid.');
    }
    for (final entry in inputs.entries) {
      if (entry.key != entry.value.id) {
        throw const FormatException('Campaign input key does not match its content hash.');
      }
    }
    final references = [
      if (structureInputId != null) structureInputId!,
      ...measurements.values.map((value) => value.inputId).whereType<String>(),
      ...rounds.expand((round) => round.inputIds),
    ];
    if (references.any((id) => !inputs.containsKey(id))) throw const FormatException('A campaign input is missing.');
    for (final entry in measurements.entries) {
      final measurement = entry.value;
      if (entry.key != measurement.sequence ||
          measurement.sequence.length != wildtypeSequence.length ||
          findInvalidResidueIndex(measurement.sequence) != null ||
          measurement.fitness?.isFinite == false ||
          measurement.parentSequence.length != wildtypeSequence.length ||
          measurement.roundFound < 0 ||
          applySubstitutions(measurement.parentSequence, measurement.substitutions) != measurement.sequence) {
        throw const FormatException('A measurement has inconsistent sequence, substitutions, or fitness.');
      }
    }
    if (rounds.map((round) => round.id).toSet().length != rounds.length ||
        rounds.map((round) => round.sentConfig.iteration).toSet().length != rounds.length) {
      throw const FormatException('Campaign contains duplicate rounds.');
    }
    for (final restrictions in [aminoAcidRestrictions, ...rounds.map((round) => round.restrictions)]) {
      if (restrictions.globallyExcluded.difference(standardAminoAcids).isNotEmpty ||
          restrictions.positionRestrictions.any(
            (rule) =>
                rule.excludedAminoAcids.difference(standardAminoAcids).isNotEmpty ||
                rule.positions.any((position) => position < 1 || position > wildtypeSequence.length),
          )) {
        throw const FormatException('Mutation restrictions contain invalid amino acids or positions.');
      }
    }
    for (final round in rounds) {
      if (round.parentSequence.length != wildtypeSequence.length ||
          round.campaignConfig.wildtypeSequence != wildtypeSequence) {
        throw const FormatException('Round inputs do not match the campaign wildtype.');
      }
    }
  }

  String internalName() => id;

  String? get wildtypeStructureMmcif => structureInputId == null ? null : utf8.decode(inputs[structureInputId]!.bytes);

  /// Replaces an applied scientific value while preserving identity and history.
  EngineeringCampaign copyWith({
    int? revision,
    Map<String, MeasuredVariant>? measurements,
    List<EngineeringRound>? rounds,
    AminoAcidRestrictions? aminoAcidRestrictions,
    Map<String, EngineeringInput>? inputs,
    String? structureInputId,
  }) => EngineeringCampaign(
    id: id,
    revision: revision ?? this.revision + 1,
    sourceCampaignId: sourceCampaignId,
    config: config,
    wildtypeId: wildtypeId,
    wildtypeSequence: wildtypeSequence,
    measurementName: measurementName,
    measurementUnit: measurementUnit,
    wildtypeFitness: wildtypeFitness,
    measurements: measurements ?? this.measurements,
    rounds: rounds ?? this.rounds,
    aminoAcidRestrictions: aminoAcidRestrictions ?? this.aminoAcidRestrictions,
    inputs: inputs ?? this.inputs,
    structureInputId: structureInputId ?? this.structureInputId,
  );

  Map<String, dynamic> serialize() => {
    'id': id,
    'revision': revision,
    'sourceCampaignId': sourceCampaignId,
    'config': config.serialize(),
    'wildtypeId': wildtypeId,
    'wildtypeSequence': wildtypeSequence,
    'wildtypeFitness': wildtypeFitness,
    'measurementName': measurementName,
    'measurementUnit': measurementUnit,
    'measurements': measurements.values.map((value) => value.serialize()).toList(),
    'rounds': rounds.map((value) => value.serialize()).toList(),
    'aminoAcidRestrictions': aminoAcidRestrictions.serialize(),
    'inputs': inputs.values.map((value) => value.serialize()).toList(),
    'structureInputId': structureInputId,
  };

  factory EngineeringCampaign.deserialize(Map<String, dynamic> json) {
    final inputs = {
      for (final value in json['inputs'] as List)
        (value as Map<String, dynamic>)['id'] as String: EngineeringInput.deserialize(value),
    };
    final structureId = json['structureInputId'] as String?;
    if (structureId != null && !inputs.containsKey(structureId)) {
      throw const FormatException('Campaign structure input is missing.');
    }
    final campaign = EngineeringCampaign(
      id: json['id'] as String,
      revision: json['revision'] as int,
      sourceCampaignId: json['sourceCampaignId'] as String?,
      config: EngineeringCampaignConfigSerial.deserialize(json['config'] as Map<String, dynamic>),
      wildtypeId: json['wildtypeId'] as String,
      wildtypeSequence: json['wildtypeSequence'] as String,
      wildtypeFitness: (json['wildtypeFitness'] as num?)?.toDouble(),
      measurementName: json['measurementName'] as String,
      measurementUnit: json['measurementUnit'] as String,
      measurements: {
        for (final entry in json['measurements'] as List)
          (entry as Map<String, dynamic>)['sequence'] as String: MeasuredVariant.deserialize(entry),
      },
      rounds: (json['rounds'] as List)
          .map((entry) => EngineeringRound.deserialize(entry as Map<String, dynamic>))
          .toList(),
      aminoAcidRestrictions: AminoAcidRestrictions.deserialize(json['aminoAcidRestrictions'] as Map<String, dynamic>),
      inputs: inputs,
      structureInputId: structureId,
    );
    if (campaign.inputs.length != (json['inputs'] as List).length ||
        campaign.measurements.length != (json['measurements'] as List).length) {
      throw const FormatException('Campaign contains duplicate input or measurement entries.');
    }
    return campaign;
  }
}

/// An immutable result paired with the exact inputs submitted for that round.
class EngineeringRound {
  final String id;
  final ActiveLearningEngineeringCampaignConfig campaignConfig;
  final ActiveLearningEngineeringIterationConfig sentConfig;
  final ActiveLearningIterationResult result;
  final String parentSequence;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final AminoAcidRestrictions restrictions;
  final List<String> inputIds;
  final String? taskId;

  EngineeringRound({
    required this.campaignConfig,
    required this.sentConfig,
    required this.result,
    required this.parentSequence,
    required this.startedAt,
    required this.restrictions,
    String? id,
    this.finishedAt,
    List<String> inputIds = const [],
    this.taskId,
  }) : id = id ?? newEngineeringId(),
       inputIds = List.unmodifiable(inputIds) {
    if (this.id.isEmpty ||
        sentConfig.iteration < 1 ||
        result.iteration != sentConfig.iteration ||
        parentSequence.isEmpty ||
        findInvalidResidueIndex(parentSequence) != null) {
      throw const FormatException('Round identity, iteration, or parent sequence is invalid.');
    }
  }

  Map<String, dynamic> serialize() => {
    'id': id,
    'campaignConfig': campaignConfig.serialize(),
    'sentConfig': sentConfig.serialize(),
    'result': result.serialize(),
    'parentSequence': parentSequence,
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'restrictions': restrictions.serialize(),
    'inputIds': inputIds,
    'taskId': taskId,
  };

  factory EngineeringRound.deserialize(Map<String, dynamic> json) => EngineeringRound(
    id: json['id'] as String,
    campaignConfig: EngineeringCampaignConfigSerial.deserialize(json['campaignConfig'] as Map<String, dynamic>),
    sentConfig: EngineeringIterationConfigSerial.deserialize(json['sentConfig'] as Map<String, dynamic>),
    result: ALIterationResultSerial.deserialize(json['result'] as Map<String, dynamic>),
    parentSequence: json['parentSequence'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String),
    finishedAt: json['finishedAt'] == null ? null : DateTime.parse(json['finishedAt'] as String),
    restrictions: AminoAcidRestrictions.deserialize(json['restrictions'] as Map<String, dynamic>),
    inputIds: (json['inputIds'] as List).cast<String>(),
    taskId: json['taskId'] as String?,
  );
}

/// An applied measurement; null fitness explicitly means did not express.
class MeasuredVariant extends Equatable {
  final String seqId;
  final String sequence;
  final String parentSequence;
  final List<Substitution> substitutions;
  final double? fitness;
  final int roundFound;
  final String? inputId;

  MeasuredVariant({
    required this.seqId,
    required this.sequence,
    required this.parentSequence,
    required List<Substitution> substitutions,
    required this.roundFound,
    this.fitness,
    this.inputId,
  }) : substitutions = List.unmodifiable(substitutions);

  @override
  List<Object?> get props => [seqId, sequence, parentSequence, substitutions, fitness, roundFound, inputId];

  bool get didNotExpress => fitness == null;

  Map<String, dynamic> serialize() => {
    'seqId': seqId,
    'sequence': sequence,
    'parentSequence': parentSequence,
    'substitutions': substitutions
        .map((value) => {'position': value.position, 'from': value.from, 'to': value.to})
        .toList(),
    'fitness': fitness,
    'roundFound': roundFound,
    'inputId': inputId,
  };

  factory MeasuredVariant.deserialize(Map<String, dynamic> json) => MeasuredVariant(
    seqId: json['seqId'] as String,
    sequence: json['sequence'] as String,
    parentSequence: json['parentSequence'] as String,
    substitutions: (json['substitutions'] as List).map((entry) {
      final value = entry as Map<String, dynamic>;
      return Substitution(position: value['position'] as int, from: value['from'] as String, to: value['to'] as String);
    }).toList(),
    roundFound: json['roundFound'] as int,
    fitness: (json['fitness'] as num?)?.toDouble(),
    inputId: json['inputId'] as String?,
  );
}

/// Encodes the single supported campaign file format; no legacy loading is attempted.
String encodeEngineeringCampaigns(Iterable<EngineeringCampaign> campaigns) =>
    jsonEncode({'schemaVersion': 1, 'campaigns': campaigns.map((campaign) => campaign.serialize()).toList()});

/// Validates the document version before decoding any campaigns.
List<EngineeringCampaign> decodeEngineeringCampaigns(String content) {
  final json = jsonDecode(content) as Map<String, dynamic>;
  if (json['schemaVersion'] is! int || json['schemaVersion'] != 1) {
    throw const FormatException('Unsupported campaign format. Expected schemaVersion 1.');
  }
  final campaigns = (json['campaigns'] as List)
      .map((entry) => EngineeringCampaign.deserialize(entry as Map<String, dynamic>))
      .toList();
  if (campaigns.map((campaign) => campaign.id).toSet().length != campaigns.length) {
    throw const FormatException('Duplicate campaign identities.');
  }
  return campaigns;
}

/// A seed measurement described relative to the new campaign's wildtype.
class SeedMeasurement {
  final List<Substitution> substitutions;
  final double? fitness;

  SeedMeasurement({required List<Substitution> substitutions, required this.fitness})
    : substitutions = List.unmodifiable(substitutions);
}
