import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/protein_engineering/bloc/engineering_commands.dart';
import 'package:biocentral/plugins/protein_engineering/bloc/engineering_hub_bloc.dart';
import 'package:biocentral/plugins/protein_engineering/domain/amino_acid_restrictions.dart';
import 'package:biocentral/plugins/protein_engineering/domain/campaign_seed_data.dart';
import 'package:biocentral/plugins/protein_engineering/domain/csv_utils.dart';
import 'package:biocentral/plugins/protein_engineering/domain/engineering_repository.dart';
import 'package:biocentral/plugins/protein_engineering/domain/fasta_utils.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/domain/sequence_validation.dart';
import 'package:biocentral/plugins/protein_engineering/domain/structure_sequence.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/engineering_actions.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/engineering_model_selection.dart';
import 'package:biocentral/plugins/protein_engineering/presentation/widgets/engineering_restrictions_editor.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Collects a campaign draft before dispatching a single creation command.
class NewEngineeringCampaignView extends StatefulWidget {
  final EngineeringCampaign? source;
  final ValueChanged<EngineeringCampaign> onCreated;
  final ValueChanged<EngineeringCampaign> onSourceSelected;

  const NewEngineeringCampaignView({required this.onCreated, required this.onSourceSelected, this.source, super.key});

  @override
  State<NewEngineeringCampaignView> createState() => _NewEngineeringCampaignViewState();
}

class _NewEngineeringCampaignViewState extends State<NewEngineeringCampaignView> {
  final _stepForms = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  late final _name = TextEditingController(text: widget.source == null ? '' : '${widget.source!.config.name} copy');
  late final _identifier = TextEditingController(text: widget.source?.wildtypeId ?? 'wildtype');
  late final _sequence = TextEditingController(text: widget.source?.wildtypeSequence ?? '');
  late final _fitness = TextEditingController(text: widget.source?.wildtypeFitness?.toString() ?? '');
  late final _measurement = TextEditingController(text: widget.source?.measurementName ?? 'Fitness');
  late final _unit = TextEditingController(text: widget.source?.measurementUnit ?? '');
  late final _seed = TextEditingController(text: (widget.source?.config.seed ?? biocentralDefaultSeed).toString());
  late final _embedder = TextEditingController(
    text: widget.source?.config.embedderName ?? 'facebook/esm2_t33_650M_UR50D',
  );
  final List<(TextEditingController, TextEditingController)> _seedRows = [];
  late ActiveLearningModelType _model = widget.source?.config.modelType ?? ActiveLearningModelType.GAUSSIAN_PROCESS;
  late ActiveLearningOptimizationMode _direction =
      widget.source?.config.optimizationMode ?? ActiveLearningOptimizationMode.MAXIMIZE;
  late AminoAcidRestrictions? _restrictions =
      widget.source?.aminoAcidRestrictions ?? const AminoAcidRestrictions.empty();
  late final Map<String, EngineeringInput> _inputs = {...?widget.source?.inputs};
  late String? _structureId = widget.source?.structureInputId;
  EngineeringInput? _seedInput;
  String? _error;
  int _step = 0;
  bool _loading = false;
  String? _submittedId;

  @override
  void dispose() {
    for (final controller in [_name, _identifier, _sequence, _fitness, _measurement, _unit, _seed, _embedder]) {
      controller.dispose();
    }
    for (final row in _seedRows) {
      row.$1.dispose();
      row.$2.dispose();
    }
    super.dispose();
  }

  String get _wildtype => _sequence.text.replaceAll(RegExp(r'\s'), '').toUpperCase();

  Future<void> _pick(String kind) async {
    setState(() => _loading = true);
    try {
      final picked = await FilePicker.platform.pickFiles(withData: true);
      if (!mounted || picked == null) return;
      final file = picked.files.single;
      final bytes = file.bytes;
      if (bytes == null) throw const FormatException('Could not read the selected file.');
      final input = EngineeringInput(name: file.name, format: kind, bytes: bytes);
      if (kind == 'fasta') {
        final entry = parseFirstFastaEntry(utf8.decode(bytes));
        if (entry == null) throw const FormatException('No FASTA sequence found.');
        _identifier.text = entry.id;
        _sequence.text = entry.sequence;
      } else if (kind == 'mmcif') {
        final parsed = await MmcifParser.parse(utf8.decode(bytes));
        if (!mounted) return;
        if (_wildtype.isEmpty) {
          throw const FormatException('Choose the wildtype sequence before uploading a structure.');
        }
        if (matchWildtypeStructure(parsed.structure, _wildtype) == null) {
          throw const FormatException('No structure chain matches the wildtype sequence.');
        }
        _structureId = input.id;
      } else {
        _seedInput = input;
      }
      _inputs[input.id] = input;
      setState(() => _error = null);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _validateTrainingMeasurements() {
    var hasMeasurement =
        double.tryParse(_fitness.text)?.isFinite == true ||
        (widget.source?.wildtypeSequence == _wildtype &&
            widget.source!.measurements.values.any((value) => value.fitness != null));
    final sources = [
      if (_seedInput != null) utf8.decode(_seedInput!.bytes),
      if (_seedRows.isNotEmpty)
        'variant,measured\n${_seedRows.map((row) => encodeCsvRecord([row.$1.text, row.$2.text])).join('\n')}',
    ];
    for (final content in sources) {
      final data = parseSeedDataCsv(content, _wildtype);
      if (data.errors.isNotEmpty) throw FormatException(data.errors.join('\n'));
      hasMeasurement =
          hasMeasurement || data.wildtypeFitness != null || data.measurements.any((value) => value.fitness != null);
    }
    if (!hasMeasurement) {
      throw const FormatException(
        'Add a numeric wildtype measurement or at least one measured mutant. '
        'The model needs measured training data to suggest the first round. Did not express does not count as a numeric measurement.',
      );
    }
  }

  void _continue() {
    if (_step < 2 && !(_stepForms[_step].currentState?.validate() ?? false)) return;
    if (_step > 0 && _restrictions == null) return;
    if (_step == 0) {
      try {
        _validateTrainingMeasurements();
      } on FormatException catch (error) {
        setState(() => _error = error.message);
        return;
      }
    }
    setState(() => _error = null);
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    try {
      final measurements = <String, MeasuredVariant>{};
      final source = widget.source;
      if (source != null && source.wildtypeSequence == _wildtype) {
        for (final value in source.measurements.values) {
          measurements[value.sequence] = MeasuredVariant(
            seqId: value.seqId,
            sequence: value.sequence,
            parentSequence: _wildtype,
            substitutions: value.sequence == _wildtype
                ? []
                : parseMutationDescriptor(wildtypeRelativeDescriptor(_wildtype, value.sequence)!),
            roundFound: 0,
            fitness: value.fitness,
            inputId: value.inputId,
          );
        }
      }
      final sources = <(String, String?)>[
        if (_seedInput != null) (utf8.decode(_seedInput!.bytes), _seedInput!.id),
        if (_seedRows.isNotEmpty)
          ('variant,measured\n${_seedRows.map((row) => encodeCsvRecord([row.$1.text, row.$2.text])).join('\n')}', null),
      ];
      double? wildtypeFitness = _fitness.text.trim().isEmpty ? null : double.parse(_fitness.text);
      for (final (content, inputId) in sources) {
        final data = parseSeedDataCsv(content, _wildtype);
        if (data.errors.isNotEmpty) throw FormatException(data.errors.join('\n'));
        wildtypeFitness = data.wildtypeFitness ?? wildtypeFitness;
        for (final value in data.measurements) {
          final sequence = applySubstitutions(_wildtype, value.substitutions)!;
          measurements[sequence] = MeasuredVariant(
            seqId: wildtypeRelativeDescriptor(_wildtype, sequence)!,
            sequence: sequence,
            parentSequence: _wildtype,
            substitutions: value.substitutions,
            roundFound: 0,
            fitness: value.fitness,
            inputId: inputId,
          );
        }
      }
      if (wildtypeFitness != null) {
        measurements[_wildtype] = MeasuredVariant(
          seqId: 'WT',
          sequence: _wildtype,
          parentSequence: _wildtype,
          substitutions: [],
          roundFound: 0,
          fitness: wildtypeFitness,
        );
      }
      if (!measurements.values.any((value) => value.fitness != null)) {
        throw const FormatException('Add at least one numeric wildtype or mutant measurement before creating a campaign.');
      }
      final campaign = EngineeringCampaign(
        config: ActiveLearningEngineeringCampaignConfig(
          (builder) => builder
            ..name = _name.text.trim()
            ..wildtypeSequence = _wildtype
            ..embedderName = _embedder.text.trim()
            ..modelType = _model
            ..optimizationMode = _direction
            ..seed = int.parse(_seed.text),
        ),
        wildtypeId: _identifier.text.trim(),
        wildtypeSequence: _wildtype,
        measurementName: _measurement.text.trim(),
        measurementUnit: _unit.text.trim(),
        wildtypeFitness: wildtypeFitness,
        measurements: measurements,
        aminoAcidRestrictions: _restrictions!,
        inputs: _inputs,
        structureInputId: _structureId,
        sourceCampaignId: source?.id,
      );
      final repository = context.read<EngineeringRepository>();
      submitEngineeringCommand(context, NewEngineeringCampaignCommand(repository: repository, campaign: campaign));
      _submittedId = campaign.id;
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<BiocentralCommandBloc, bool>((bloc) => bloc.state.isBusy());
    return BlocListener<EngineeringHubBloc, EngineeringHubState>(
      listener: (context, state) {
        for (final campaign in state.campaigns) {
          if (campaign.id == _submittedId) {
            _submittedId = null;
            widget.onCreated(campaign);
            break;
          }
        }
      },
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(40, 32, 40, 0),
              child: BiocentralPageHeader(title: 'New campaign'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: BiocentralNotice(message: _error!, icon: Icons.error_outline),
              ),
            Expanded(
              child: BiocentralWizard(
                currentStep: _step,
                continueLabel: _step == 2 ? 'Launch campaign' : 'Continue',
                onBack: _step == 0 ? null : () => setState(() => _step--),
                onContinue: busy || _loading ? null : _continue,
                steps: [
                  Step(
                    title: const Text('Start'),
                    isActive: _step == 0,
                    content: Form(
                      key: _stepForms[0],
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: widget.source?.id,
                            decoration: const InputDecoration(labelText: 'Start from an existing campaign'),
                            items: [
                              // The draft owns its source snapshot even if that campaign is deleted.
                              if (widget.source != null &&
                                  !context.read<EngineeringHubBloc>().state.campaigns.any(
                                    (campaign) => campaign.id == widget.source!.id,
                                  ))
                                DropdownMenuItem(value: widget.source!.id, child: Text(widget.source!.config.name)),
                              for (final campaign in context.read<EngineeringHubBloc>().state.campaigns)
                                DropdownMenuItem(value: campaign.id, child: Text(campaign.config.name)),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                widget.onSourceSelected(
                                  context.read<EngineeringHubBloc>().state.campaigns.firstWhere(
                                    (campaign) => campaign.id == value,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Protein>(
                            decoration: const InputDecoration(labelText: 'Choose a protein from the project'),
                            items: [
                              for (final protein in context.read<ProteinRepository>().databaseToMap().values)
                                DropdownMenuItem(value: protein, child: Text(protein.id)),
                            ],
                            onChanged: (protein) {
                              if (protein != null) {
                                setState(() {
                                  _identifier.text = protein.id;
                                  _sequence.text = protein.sequence.seq;
                                });
                              }
                            },
                          ),
                          _field(_name, 'Campaign name', required: true),
                          _field(_identifier, 'Wildtype identifier', required: true),
                          _field(
                            _sequence,
                            'Wildtype sequence',
                            lines: 4,
                            validator: (value) => _wildtype.isEmpty || findInvalidResidueIndex(_wildtype) != null
                                ? 'Enter a standard amino acid sequence.'
                                : null,
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: _loading ? null : () => _pick('fasta'),
                                child: const Text('Load FASTA'),
                              ),
                              OutlinedButton(
                                onPressed: _loading ? null : () => _pick('mmcif'),
                                child: const Text('Upload structure'),
                              ),
                              OutlinedButton(
                                onPressed: _loading ? null : () => _pick('csv'),
                                child: const Text('Import seed measurements'),
                              ),
                            ],
                          ),
                          if (_seedInput != null) Text(_seedInput!.name),
                          _field(_fitness, 'Wildtype measurement', validator: _finiteOrEmpty),
                          const Text(
                            'Provide a numeric wildtype measurement or at least one measured mutant '
                            '(below or via CSV). The model needs measured training data for the first round.',
                          ),
                          for (final row in _seedRows)
                            Row(
                              children: [
                                Expanded(child: _field(row.$1, 'Variant (e.g. A12V)')),
                                const SizedBox(width: 12),
                                Expanded(child: _field(row.$2, 'Measured value or DNE')),
                                IconButton(
                                  onPressed: () => setState(() {
                                    _seedRows.remove(row);
                                    row.$1.dispose();
                                    row.$2.dispose();
                                  }),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          TextButton.icon(
                            onPressed: () =>
                                setState(() => _seedRows.add((TextEditingController(), TextEditingController()))),
                            icon: const Icon(Icons.add),
                            label: const Text('Add measurement'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Goal'),
                    isActive: _step == 1,
                    content: Form(
                      key: _stepForms[1],
                      child: Column(
                        children: [
                          _field(_measurement, 'Measurement name', required: true),
                          _field(_unit, 'Measurement unit'),
                          DropdownButtonFormField(
                            initialValue: _direction,
                            items: [
                              for (final mode in [
                                ActiveLearningOptimizationMode.MAXIMIZE,
                                ActiveLearningOptimizationMode.MINIMIZE,
                              ])
                                DropdownMenuItem(value: mode, child: Text(mode.name)),
                            ],
                            onChanged: (value) => setState(() => _direction = value!),
                          ),
                          const SizedBox(height: 20),
                          EngineeringModelSelection(
                            embedderName: _embedder.text,
                            modelType: _model,
                            onEmbedderChanged: (value) => setState(() => _embedder.text = value),
                            onModelTypeChanged: (value) => setState(() => _model = value),
                          ),
                          _field(
                            _seed,
                            'Random seed',
                            validator: (value) => int.tryParse(value ?? '') == null ? 'Enter an integer.' : null,
                          ),
                          EngineeringRestrictionsEditor(
                            initialValue: _restrictions ?? const AminoAcidRestrictions.empty(),
                            sequenceLength: _wildtype.length,
                            onChanged: (value) => _restrictions = value,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Review'),
                    isActive: _step == 2,
                    content: BiocentralSectionCard(
                      child: Text(
                        '${_name.text}\n${_wildtype.length} residues\n${_measurement.text} (${_unit.text})\n${_embedder.text}\nSeed ${_seed.text}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _finiteOrEmpty(String? value) =>
      value == null || value.trim().isEmpty || double.tryParse(value)?.isFinite == true
      ? null
      : 'Enter a finite number.';

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int lines = 1,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
      validator: validator ?? (value) => required && (value == null || value.trim().isEmpty) ? 'Required.' : null,
    ),
  );
}
