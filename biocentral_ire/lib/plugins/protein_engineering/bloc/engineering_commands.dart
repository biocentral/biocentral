import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:cross_file/cross_file.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:biocentral/plugins/protein_engineering/domain/amino_acid_restrictions.dart';
import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral/plugins/protein_engineering/domain/structure_sequence.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';

/// An atomic scientific change with complete before/after provenance.
abstract class EngineeringChangeCommand extends BiocentralCommand<EngineeringCampaign> {
  final EngineeringRepository repository;
  final EngineeringCampaign? before;
  final EngineeringCampaign after;

  EngineeringChangeCommand({required this.repository, required this.after, this.before});

  @override
  Stream<BiocentralCommandLog<EngineeringCampaign>> execute() async* {
    final log = initLog();
    yield log;
    await validate();
    if (repository.campaign(after.id)?.revision != before?.revision) {
      yield log.errored(error: 'Campaign changed since this operation was prepared.');
      return;
    }
    yield log.finish(
      result: BiocentralCommandResult(after, {'campaignId': after.id, 'revision': after.revision}),
      finalProgress: const BiocentralCommandProgress(information: 'Change ready', current: 1, total: 1),
    );
  }

  /// Validates inputs before calculating an unapplied campaign revision.
  Future<void> validate() async {}

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    if (resultLog?.result?.result is EngineeringCampaign) {
      repository.replace(after, expectedRevision: before?.revision);
    }
  }
}

/// Creates a campaign, optionally recording the campaign used to prefill its draft.
final class NewEngineeringCampaignCommand extends EngineeringChangeCommand {
  NewEngineeringCampaignCommand({required super.repository, required EngineeringCampaign campaign})
    : super(after: campaign);

  @override
  Future<void> validate() async {
    final content = after.wildtypeStructureMmcif;
    if (content != null) {
      final parsed = await MmcifParser.parse(content);
      if (matchWildtypeStructure(parsed.structure, after.wildtypeSequence) == null) {
        throw const FormatException('The uploaded structure does not match the final wildtype sequence.');
      }
    }
  }

  @override
  Map<String, dynamic> getConfigMap() => {'campaign': after.serialize()};

  @override
  String get typeName => 'NewEngineeringCampaignCommand';
}

/// Applies a complete restriction draft as one logged scientific operation.
final class UpdateEngineeringRestrictionsCommand extends EngineeringChangeCommand {
  UpdateEngineeringRestrictionsCommand({
    required super.repository,
    required EngineeringCampaign campaign,
    required AminoAcidRestrictions restrictions,
  }) : super(
         before: campaign,
         after: campaign.copyWith(aminoAcidRestrictions: restrictions),
       );

  @override
  Map<String, dynamic> getConfigMap() => {
    'campaignId': after.id,
    'expectedRevision': before!.revision,
    'before': before!.aminoAcidRestrictions.serialize(),
    'after': after.aminoAcidRestrictions.serialize(),
  };

  @override
  String get typeName => 'UpdateEngineeringRestrictionsCommand';
}

/// Applies measurements and corrections, retaining the original imported input.
final class AddEngineeringMeasurementsCommand extends EngineeringChangeCommand {
  AddEngineeringMeasurementsCommand({
    required super.repository,
    required EngineeringCampaign campaign,
    required List<MeasuredVariant> measurements,
    EngineeringInput? input,
  }) : super(before: campaign, after: _updated(campaign, measurements, input));

  static EngineeringCampaign _updated(
    EngineeringCampaign campaign,
    List<MeasuredVariant> measurements,
    EngineeringInput? input,
  ) {
    for (final measurement in measurements) {
      if (measurement.sequence.length != campaign.wildtypeSequence.length ||
          findInvalidResidueIndex(measurement.sequence) != null ||
          measurement.fitness?.isFinite == false) {
        throw const FormatException('Measurements must have a valid sequence and finite fitness.');
      }
    }
    return campaign.copyWith(
      measurements: {
        ...campaign.measurements,
        for (final value in measurements)
          value.sequence: MeasuredVariant(
            seqId: value.seqId,
            sequence: value.sequence,
            parentSequence: value.parentSequence,
            substitutions: value.substitutions,
            roundFound: value.roundFound,
            fitness: value.fitness,
            inputId: input?.id ?? value.inputId,
          ),
      },
      inputs: {...campaign.inputs, if (input != null) input.id: input},
    );
  }

  @override
  Map<String, dynamic> getConfigMap() => {
    'campaignId': after.id,
    'expectedRevision': before!.revision,
    'measurements': [
      for (final entry in after.measurements.entries)
        if (!identical(before!.measurements[entry.key], entry.value))
          {
            'sequence': entry.key,
            'before': before!.measurements[entry.key]?.serialize(),
            'after': entry.value.serialize(),
          },
    ],
    'inputs': [
      for (final entry in after.inputs.entries)
        if (!before!.inputs.containsKey(entry.key)) entry.value.serialize(),
    ],
  };

  @override
  String get typeName => 'AddEngineeringMeasurementsCommand';
}

/// Validates and preserves the exact uploaded reference structure before committing.
final class UploadWildtypeStructureCommand extends BiocentralCommand<EngineeringCampaign> {
  final EngineeringRepository repository;
  final EngineeringCampaign campaign;
  final EngineeringInput input;

  UploadWildtypeStructureCommand({required this.repository, required this.campaign, required this.input});

  @override
  Stream<BiocentralCommandLog<EngineeringCampaign>> execute() async* {
    final log = initLog();
    yield log;
    final parsed = await MmcifParser.parse(utf8.decode(input.bytes));
    if (matchWildtypeStructure(parsed.structure, campaign.wildtypeSequence) == null) {
      yield log.errored(error: 'No uploaded chain matches the campaign wildtype sequence.');
      return;
    }
    final updated = campaign.copyWith(inputs: {...campaign.inputs, input.id: input}, structureInputId: input.id);
    yield log.finish(
      result: BiocentralCommandResult(updated, {'campaignId': updated.id, 'structureInputId': input.id}),
      finalProgress: const BiocentralCommandProgress(information: 'Structure validated', current: 1, total: 1),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final result = resultLog?.result?.result;
    if (result is EngineeringCampaign) repository.replace(result, expectedRevision: campaign.revision);
  }

  @override
  Map<String, dynamic> getConfigMap() => {
    'campaignId': campaign.id,
    'revision': campaign.revision,
    'previousStructureInputId': campaign.structureInputId,
    'input': input.serialize(),
  };

  @override
  String get typeName => 'UploadWildtypeStructureCommand';
}

/// Deletes a campaign after confirmation, retaining the deleted snapshot in Activity.
final class DeleteEngineeringCampaignCommand extends BiocentralCommand<EngineeringCampaign> {
  final EngineeringRepository repository;
  final EngineeringCampaign campaign;

  DeleteEngineeringCampaignCommand({required this.repository, required this.campaign});

  @override
  Stream<BiocentralCommandLog<EngineeringCampaign>> execute() async* {
    yield initLog().finish(
      result: BiocentralCommandResult(campaign, {'campaignId': campaign.id}),
      finalProgress: const BiocentralCommandProgress(information: 'Deletion ready', current: 1, total: 1),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    if (resultLog?.result?.result is EngineeringCampaign) {
      repository.delete(campaign.id, expectedRevision: campaign.revision);
    }
  }

  @override
  Map<String, dynamic> getConfigMap() => {'campaign': campaign.serialize()};

  @override
  String get typeName => 'DeleteEngineeringCampaignCommand';
}

/// Validates a versioned campaign document before atomically importing it.
final class LoadEngineeringCampaignCommand extends BiocentralCommand<List<EngineeringCampaign>> {
  final EngineeringRepository repository;
  final EngineeringInput? input;
  final XFile? file;
  final DatabaseImportMode mode;

  LoadEngineeringCampaignCommand({required this.repository, required this.input, required this.mode}) : file = null;

  LoadEngineeringCampaignCommand.fromFile({required this.repository, required XFile campaignFile, required this.mode})
    : file = campaignFile,
      input = null;

  @override
  Stream<BiocentralCommandLog<List<EngineeringCampaign>>> execute() async* {
    final source = input ?? EngineeringInput(name: file!.name, format: 'json', bytes: await file!.readAsBytes());
    final campaigns = decodeEngineeringCampaigns(utf8.decode(source.bytes));
    for (final campaign in campaigns) {
      final structure = campaign.wildtypeStructureMmcif;
      if (structure != null) {
        final parsed = await MmcifParser.parse(structure);
        if (matchWildtypeStructure(parsed.structure, campaign.wildtypeSequence) == null) {
          throw FormatException('The structure in "${campaign.config.name}" does not match its wildtype.');
        }
      }
    }
    yield initLog().finish(
      result: BiocentralCommandResult(campaigns, {
        'campaignIds': campaigns.map((campaign) => campaign.id).toList(),
        'source': source.serialize(),
        'replacedCampaigns': [
          for (final campaign in campaigns)
            if (mode == DatabaseImportMode.overwrite && repository.campaign(campaign.id) != null)
              repository.campaign(campaign.id)!.serialize(),
        ],
      }),
      finalProgress: const BiocentralCommandProgress(information: 'Campaign file validated', current: 1, total: 1),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final campaigns = resultLog?.result?.result;
    if (campaigns is List<EngineeringCampaign>) repository.importCampaigns(campaigns, mode: mode);
  }

  @override
  Map<String, dynamic> getConfigMap() => {
    'input': input?.serialize(),
    'file': file?.name,
    'mode': mode.name,
    'schemaVersion': 1,
  };

  @override
  String get typeName => 'LoadEngineeringCampaignCommand';
}

/// Exports an applied campaign with its original and historical scientific inputs.
final class ExportEngineeringCampaignCommand extends BiocentralCommand<String> {
  final BiocentralProjectRepository projectRepository;
  final EngineeringCampaign campaign;
  final String fileName;
  final String directory;

  ExportEngineeringCampaignCommand({
    required this.projectRepository,
    required this.campaign,
    required this.fileName,
    required this.directory,
  });

  @override
  Stream<BiocentralCommandLog<String>> execute() async* {
    final log = initLog();
    final saved = await projectRepository.handleExternalSave(
      fileName: fileName,
      dirPath: directory,
      contentFunction: () async => encodeEngineeringCampaigns([campaign]),
    );
    yield saved.match(
      (error) => log.errored(error: error.message),
      (path) => log.finish(
        result: BiocentralCommandResult(path, {'path': path}),
        finalProgress: const BiocentralCommandProgress(information: 'Campaign exported', current: 1, total: 1),
      ),
    );
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {}

  @override
  Map<String, dynamic> getConfigMap() => {
    'campaignId': campaign.id,
    'revision': campaign.revision,
    'schemaVersion': 1,
    'fileName': fileName,
    'directory': directory,
  };

  @override
  String get typeName => 'ExportEngineeringCampaignCommand';
}

/// Runs one round against immutable campaign and iteration snapshots.
final class RunEngineeringRoundCommand extends BiocentralCommand<EngineeringCampaign> {
  final BiocentralAPIRepository apiRepository;
  final EngineeringRepository repository;
  final EngineeringCampaign campaign;
  final ActiveLearningEngineeringIterationConfig iteration;
  final String parentSequence;

  RunEngineeringRoundCommand({
    required this.apiRepository,
    required this.repository,
    required this.campaign,
    required this.iteration,
    required this.parentSequence,
  });

  @override
  Stream<BiocentralCommandLog<EngineeringCampaign>> execute() async* {
    var log = initLog();
    yield log;
    if (repository.campaign(campaign.id)?.revision != campaign.revision) {
      yield log.errored(error: 'Campaign changed before the round was submitted.');
      return;
    }
    final startedAt = DateTime.now();
    final task = await apiRepository.getBiocentralAPI().alEngineeringIteration(
      campaignConfig: campaign.config,
      iterationConfig: iteration,
    );
    yield log = log.logInfo(information: 'Server task ${task.taskId}');
    await for (final (dto, result) in task.run()) {
      if (result != null) {
        final round = EngineeringRound(
          campaignConfig: campaign.config,
          sentConfig: iteration,
          result: result,
          parentSequence: parentSequence,
          startedAt: startedAt,
          finishedAt: DateTime.now(),
          restrictions: campaign.aminoAcidRestrictions,
          inputIds: campaign.inputs.keys.toList(),
          taskId: task.taskId,
        );
        final updated = campaign.copyWith(rounds: [...campaign.rounds, round]);
        yield log.finish(
          result: BiocentralCommandResult(updated, {'round': round.serialize()}),
          finalProgress: const BiocentralCommandProgress(information: 'Round finished', current: 1, total: 1),
        );
        return;
      }
      final progress = dto?.embeddingProgress;
      log = progress == null
          ? log.logInfo(information: 'Running round…')
          : log.logProgress(
              progress: BiocentralCommandProgress(
                information: 'Encoding variants…',
                current: progress.current,
                total: progress.total,
              ),
            );
      yield log;
    }
    yield log.errored(error: 'Task ended without a round result.');
  }

  @override
  void acceptResult(BiocentralCommandLog? resultLog) {
    final result = resultLog?.result?.result;
    if (result is EngineeringCampaign) repository.replace(result, expectedRevision: campaign.revision);
  }

  @override
  Map<String, dynamic> getConfigMap() => {
    'campaignId': campaign.id,
    'revision': campaign.revision,
    'campaignConfig': campaign.config.serialize(),
    'iterationConfig': iteration.serialize(),
    'parentSequence': parentSequence,
    'restrictions': campaign.aminoAcidRestrictions.serialize(),
    'inputIds': campaign.inputs.keys.toList(),
  };

  @override
  String get typeName => 'RunEngineeringRoundCommand';
}
