import 'dart:async';
import 'dart:math';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/custom_models/bloc/models_commands.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/bloc/biocentral_command_availability.dart';
import 'package:biocentral/sdk/domain/biocentral_database_column.dart';
import 'package:biocentral/sdk/model/split_set.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_command_widget.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_ratio_slider.dart';
import 'package:biocentral/sdk/util/widget_util.dart';
import 'package:biocentral_api/biocentral_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biocentral/plugins/proteins/domain/protein_repository.dart';
import 'package:biocentral/plugins/custom_models/model/set_generator.dart';

class SplitDataCommandDisplay extends StatefulWidget {
  const SplitDataCommandDisplay({super.key});

  @override
  State<SplitDataCommandDisplay> createState() => _SplitDataCommandDisplayState();
}

class _SplitDataCommandDisplayState extends State<SplitDataCommandDisplay> {
  final Set<SplitSetGenerationMethod> _availableMethods = const {
    SplitSetGenerationMethod.random,
    SplitSetGenerationMethod.existingCluster,
    SplitSetGenerationMethod.newCluster,
  };
  final Map<BiocentralDatabaseColumn, Set<SplitSet>> _availableSourceSets = {};

  Type? _selectedDatabaseType = Protein;
  int? _selectedDatabaseLength;
  SplitSetGenerationMode? _mode;
  BiocentralDatabaseColumn? _selectedSetColumn;
  SplitSet? _subsplitSource;
  SplitSet? _subsplitTarget;
  SplitSetGenerationMethod? _method;
  SplitRatio? _splitRatio;
  String? _selectedClusterColumn;
  double _clusteringThreshold = 0.3;

  // Seed configuration
  bool _useSeed = true;
  int _seed = 42;

  // Target column for evaluation & HBI
  String? _selectedTargetColumn;

  // HBI Evaluation & Plot State
  Timer? _debounceTimer;
  bool _isEvaluatingHBI = false;
  String? _hbiErrorMessage;

  // BootstrappedMetric from Backend
  List<BootstrappedMetric>? _splitHbiMetrics;
  List<BootstrappedMetric>? _clusterHbiMetrics;

  //Cluster distribution data for plotting
  Map<String, List<String>>? _computedClusters;

  final double _eValueThreshold = 1e-3;

  List<String> getDiscoveredClusterColumns() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database is ProteinRepository) {
      return database.getAvailableClusterColumns();
    }
    return [];
  }

  List<String> getAvailableTargetColumns() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database == null) return [];

    final Set<String> discoveredColumns = {};

    // Collect all unique keys present across all entities
    final entities = database.entitiesAsMaps();
    for (final entity in entities) {
      final attributes = entity['attributes'] as Map<String, dynamic>?;
      if (attributes != null) {
        discoveredColumns.addAll(attributes.keys);
      }
      discoveredColumns.addAll(
        entity.keys.where((k) => k != 'id' && k != 'sequence' && k != 'attributes'),
      );
    }

    // Exclude IDs, sequence strings, and partition columns
    return discoveredColumns.where((col) {
      final lower = col.toLowerCase().trim();
      if (lower.startsWith('set_') || lower.startsWith('mmseqs2-cluster-')) return false;
      if (lower == 'sequence' || lower == 'id' || lower == 'proteinid' || lower == 'repid') return false;
      return true;
    }).toList();
  }

  void triggerAutoEvaluation() {
    _debounceTimer?.cancel();

    // Verify all mandatory preconditions are satisfied
    if (_selectedDatabaseType == null ||
        _selectedTargetColumn == null ||
        _mode == null ||
        _method == null ||
        _splitRatio == null) {
      return;
    }
    if (_method == SplitSetGenerationMethod.existingCluster && _selectedClusterColumn == null) {
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _runDualHbiEvaluation();
    });
  }

  Future<void> _runDualHbiEvaluation() async {
    if (!mounted) return;

    setState(() {
      _isEvaluatingHBI = true;
      _hbiErrorMessage = null;
    });

    try {
      final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
      final apiRepository = context.read<BiocentralAPIRepository>();
      if (database == null) return;

      final entities = database.entitiesAsMaps();
      final ids = entities.map((e) => e['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();

      // 1. Resolve existing clusters if applicable
      Map<String, List<String>>? clusters;
      if (_selectedClusterColumn != null) {
        clusters = {};
        for (final e in entities) {
          final id = e['id']?.toString() ?? '';
          final clusterId = _getEntityAttribute(e, _selectedClusterColumn!)?.toString() ?? id;
          clusters.putIfAbsent(clusterId, () => []).add(id);
        }
      }

      // 2. Compute partition mapping
      final splitMapping = SetGenerator(splitRatio: _splitRatio!).splitByMethod(
        method: _method!,
        ids: ids,
        clusters: clusters,
        seed: _useSeed ? _seed : null,
        subsplitSource: _subsplitSource,
        subsplitTarget: _subsplitTarget,
      );

      final isNumeric = _isColumnNumeric(_selectedTargetColumn!);
      final trainSeqs = <String, String>{};
      final querySeqs = <String, String>{};
      final trainLabels = <String, dynamic>{};
      final queryLabels = <String, dynamic>{};
      final allSeqs = <String, String>{};
      final allTargets = <String, dynamic>{};

      for (final e in entities) {
        final id = e['id']?.toString() ?? '';
        final seq = e['sequence']?.toString() ?? '';
        final rawVal = _getEntityAttribute(e, _selectedTargetColumn!);
        final val = isNumeric ? double.tryParse(rawVal?.toString() ?? '') : rawVal?.toString();

        if (id.isEmpty || val == null) continue;

        allSeqs[id] = seq;
        allTargets[id] = val;

        final split = splitMapping[id];
        if (split == SplitSet.train || split == _subsplitSource) {
          trainSeqs[id] = seq;
          trainLabels[id] = val;
        } else if (split == SplitSet.test || split == _subsplitTarget) {
          querySeqs[id] = seq;
          queryLabels[id] = val;
        }
      }

      // 3. Prepare requests matching endpoint_models.py

      final datasetHash = '${_selectedDatabaseType?.toString() ?? 'default'}_${entities.length}';

      // 4. Fire both concurrently
      final api = apiRepository.getBiocentralAPI();
      final splitFuture = api.splitHbi(
        trainSeqs: trainSeqs,
        querySeqs: querySeqs,
        trainLabels: trainLabels,
        queryLabels: queryLabels,
        isNumeric: isNumeric,
        evalueCutoff: _eValueThreshold,
        iterations: 30,
      );

      final clusterFuture = api.clusterHbi(
        datasetHash: datasetHash,
        sequenceData: allSeqs,
        targetData: allTargets,
        sequenceIdentityThreshold: _clusteringThreshold,
        isNumeric: isNumeric,
        iterations: 30,
      );

      final results = await Future.wait([splitFuture, clusterFuture]);
      final splitResponse = results[0] as SplitHBIResponse?;
      final clusterResponse = results[1] as ClusterHBIResponse?;

      if (!mounted) return;
      setState(() {
        _splitHbiMetrics = splitResponse?.metrics.toList();
        _clusterHbiMetrics = clusterResponse?.metrics.toList();
        _computedClusters = clusterResponse?.clusters.toMap().map((k, v) => MapEntry(k, v.toList()));
        _isEvaluatingHBI = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isEvaluatingHBI = false;
        _hbiErrorMessage = 'Failed to compute HBI leakage: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final availableSourceSets = getAvailableSourceSets();
    _availableSourceSets.clear();
    _availableSourceSets.addAll(availableSourceSets);
  }

  SplitDataCommand? collectCommand() {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    final apiRepository = context.read<BiocentralAPIRepository>();
    if (_mode == null || database == null) {
      return null;
    }
    if (_method == SplitSetGenerationMethod.existingCluster && _selectedClusterColumn == null) {
      return null;
    }
    final int? effectiveSeed = _useSeed ? _seed : null;

    if (_mode == SplitSetGenerationMode.generateNew) {
      if (_method != null && _splitRatio != null) {
        return SplitDataCommand(
          database: database,
          apiRepository: apiRepository,
          mode: _mode!,
          method: _method!,
          splitRatio: _splitRatio!,
          seed: effectiveSeed,
          selectedClusterColumn: _selectedClusterColumn,
          clusteringThreshold: _clusteringThreshold,
        );
      }
    } else {
      if (_selectedSetColumn != null && _subsplitSource != null && _subsplitTarget == null) {
        return SplitDataCommand(
          database: database,
          apiRepository: apiRepository,
          mode: _mode!,
          method: _method!,
          splitRatio: _splitRatio!,
          seed: effectiveSeed,
          selectedSetColumn: _selectedSetColumn,
          subsplitSource: _subsplitSource,
          subsplitTarget: _subsplitTarget,
          selectedClusterColumn: _selectedClusterColumn,
          clusteringThreshold: _clusteringThreshold,
        );
      }
    }
    return null;
  }

  void applyConfiguratorHierarchy() {
    // TODO Consider previous mode here
    if (_mode == null) {
      _selectedSetColumn = null;
    }

    if (_mode != SplitSetGenerationMode.subsplitExisting) {
      _subsplitSource = null;
      _subsplitTarget = null;
      _selectedSetColumn = null;
    }
    if (_selectedSetColumn == null) {
      _subsplitSource = null;
      _subsplitTarget = null;
    }
    if (_subsplitSource == null) {
      _subsplitTarget = null;
    }
    if (_method == null) {
      _splitRatio = null;
    }
    if (_mode != null && _method != null) {
      _splitRatio ??= SplitRatio.defaultForMode(_mode!);
    }
    if (_method != SplitSetGenerationMethod.existingCluster) {
      _selectedClusterColumn = null;
    }
    triggerAutoEvaluation();
  }

  Map<BiocentralDatabaseColumn, Set<SplitSet>> getAvailableSourceSets() {
    Set<BiocentralDatabaseColumn>? existingSetColumns;
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database != null) {
      existingSetColumns = database.getSetColumns();
    }

    existingSetColumns ??= {};

    // Get available sets from the selected column for subsplitting
    final availableSourceSets = Map.fromEntries(
      existingSetColumns
          .map((column) => MapEntry(column, column.detectSplitSets()))
          .where((entry) => entry.value.length <= 2),
    );
    return availableSourceSets;
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralCommandWidget(
      icon: const Icon(Icons.splitscreen_outlined),
      name: 'Split your data',
      description: 'Split your data into robust sets (e.g. train/val/test) for model training',
      executeButtonLabel: 'Split',
      parameterSelection: buildParameterSelection,
      collectCommand: collectCommand,
      visualizeResult: BiocentralCommandWidget.visualizeDatabaseResult,
      commandAvailability: BiocentralCommandAvailability.always(),
    );
  }

  Widget buildParameterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          withCondition(condition: true, childFunction: buildDatasetSelection),
          withCondition(condition: _selectedDatabaseType != null, childFunction: buildModeSelection),
          withCondition(
            condition: _mode == SplitSetGenerationMode.subsplitExisting && _availableSourceSets.isNotEmpty,
            childFunction: buildExistingSetSelection,
          ),
          withCondition(
            condition: _mode == SplitSetGenerationMode.subsplitExisting && _selectedSetColumn != null,
            childFunction: buildSourceSetSelection,
          ),
          withCondition(
            condition: _mode == SplitSetGenerationMode.subsplitExisting &&
                _selectedSetColumn != null &&
                _subsplitSource != null,
            childFunction: buildNewSetNameSelection,
          ),
          withCondition(
            condition: _mode == SplitSetGenerationMode.generateNew || _subsplitTarget != null,
            childFunction: buildMethodSelection,
          ),
          withCondition(
            condition: _method == SplitSetGenerationMethod.existingCluster,
            childFunction: buildClusterColumnSelection,
          ),
          withCondition(
            condition: _method == SplitSetGenerationMethod.newCluster,
            childFunction: buildNewClusterConfig,
          ),
          withCondition(
            condition: _method != null,
            childFunction: buildTargetColumnSelection,
          ),
          withCondition(
            condition: _method != null,
            childFunction: buildSeedSlider,
          ),
          withCondition(condition: _method != null, childFunction: buildRatioSlider),
          withCondition(condition: _method != null, childFunction: buildHbiPreviewCard),
        ].withPadding(
          const Padding(
            padding: EdgeInsetsGeometry.all(8.0),
          ),
        ),
      ),
    );
  }

  Widget buildDatasetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Do you want to generate a set for proteins or protein-protein interactions?'),
        BiocentralEntityTypeSelection(
          initialValue: _selectedDatabaseType,
          onChangedCallback: (Type? selected) {
            final availableSourceSets = getAvailableSourceSets();
            setState(() {
              _selectedDatabaseType = selected;
              _availableSourceSets.clear();
              _availableSourceSets.addAll(availableSourceSets);
              applyConfiguratorHierarchy();
            });
          },
        ),
      ],
    );
  }

  Widget buildModeSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Do you want to create new splits or subsplit an existing set?'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<SplitSetGenerationMode>(
                label: const Text('Mode..'),
                initialSelection: _mode,
                dropdownMenuEntries: [
                  const DropdownMenuEntry<SplitSetGenerationMode>(
                    value: SplitSetGenerationMode.generateNew,
                    label: 'Create new splits',
                  ),
                  DropdownMenuEntry<SplitSetGenerationMode>(
                    value: SplitSetGenerationMode.subsplitExisting,
                    label: 'Subsplit existing set',
                    enabled: _availableSourceSets.isNotEmpty,
                  ),
                ],
                onSelected: (SplitSetGenerationMode? value) {
                  setState(() {
                    _mode = value;
                    applyConfiguratorHierarchy();
                  });
                },
              ),
            ),
          ],
        ),
        if (_mode == SplitSetGenerationMode.subsplitExisting && _availableSourceSets.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'No existing set columns found in the database.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
      ],
    );
  }

  Widget buildExistingSetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Select the existing set column to subsplit:'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<BiocentralDatabaseColumn>(
                label: const Text('Existing set column..'),
                dropdownMenuEntries: _availableSourceSets.keys
                    .map(
                      (BiocentralDatabaseColumn column) =>
                          DropdownMenuEntry<BiocentralDatabaseColumn>(value: column, label: column.name),
                    )
                    .toList(),
                onSelected: (BiocentralDatabaseColumn? value) {
                  setState(() {
                    _selectedSetColumn = value;
                    applyConfiguratorHierarchy();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSourceSetSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Select which set to split:'),
        const SizedBox(height: 6),
        BiocentralDropdownMenu<SplitSet>(
          label: const Text('Source set..'),
          dropdownMenuEntries: (_availableSourceSets[_selectedSetColumn] ?? {})
              .where((SplitSet set) => set.isPartition)
              .map((SplitSet set) => DropdownMenuEntry<SplitSet>(value: set, label: set.name))
              .toList(),
          onSelected: (SplitSet? value) {
            setState(() {
              _subsplitSource = value;
              applyConfiguratorHierarchy();
            });
          },
        ),
      ],
    );
  }

  Widget buildNewSetNameSelection() {
    final List<SplitSet> availableNames =
        SplitSet.values.where((set) => set != _subsplitSource && set.isPartition).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Select the name for the new subsplit:'),
        const SizedBox(height: 6),
        BiocentralDropdownMenu<SplitSet>(
          label: const Text('New set name..'),
          dropdownMenuEntries:
              availableNames.map((SplitSet set) => DropdownMenuEntry<SplitSet>(value: set, label: set.name)).toList(),
          onSelected: (SplitSet? value) {
            setState(() {
              _subsplitTarget = value;
              applyConfiguratorHierarchy();
            });
          },
        ),
      ],
    );
  }

  Widget buildMethodSelection() {
    final clusterCols = getDiscoveredClusterColumns();
    final hasClusters = clusterCols.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Which kind of set generation method should be applied?'),
        Row(
          children: [
            Expanded(
              child: BiocentralDropdownMenu<SplitSetGenerationMethod>(
                label: const Text('Method..'),
                initialSelection: _method,
                dropdownMenuEntries: _availableMethods.map((method) {
                  switch (method) {
                    case SplitSetGenerationMethod.random:
                      return const DropdownMenuEntry(
                        value: SplitSetGenerationMethod.random,
                        label: 'Random Split',
                      );
                    case SplitSetGenerationMethod.existingCluster:
                      return DropdownMenuEntry(
                        value: SplitSetGenerationMethod.existingCluster,
                        label: 'Use Existing Clustering',
                        enabled: hasClusters,
                      );
                    case SplitSetGenerationMethod.newCluster:
                      return const DropdownMenuEntry(
                        value: SplitSetGenerationMethod.newCluster,
                        label: 'Create New Clustering',
                      );
                  }
                }).toList(),
                onSelected: (SplitSetGenerationMethod? value) => setState(() {
                  _method = value;
                  if (_method == SplitSetGenerationMethod.existingCluster && clusterCols.isNotEmpty) {
                    _selectedClusterColumn = clusterCols.first;
                  } else {
                    _selectedClusterColumn = null;
                  }
                  applyConfiguratorHierarchy();
                }),
              ),
            ),
          ],
        ),
        if (!hasClusters)
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              'No cluster columns found. Run MMseqs2 in the Proteins tab first.',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget buildClusterColumnSelection() {
    final clusterCols = getDiscoveredClusterColumns();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Select the cluster column to use for grouping:'),
        const SizedBox(height: 6),
        BiocentralDropdownMenu<String>(
          label: const Text('Cluster Column..'),
          initialSelection: _selectedClusterColumn,
          dropdownMenuEntries: clusterCols.map((col) => DropdownMenuEntry<String>(value: col, label: col)).toList(),
          onSelected: (String? value) => setState(() {
            _selectedClusterColumn = value;
            triggerAutoEvaluation();
          }),
        ),
      ],
    );
  }

  Widget buildNewClusterConfig() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sequence Identity Threshold: ${(_clusteringThreshold * 100).toInt()}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _clusteringThreshold,
          min: 0.1,
          divisions: 18,
          label: '${(_clusteringThreshold * 100).toInt()}%',
          onChanged: (double val) {
            setState(() {
              _clusteringThreshold = (val * 100).round() / 100;
              triggerAutoEvaluation();
            });
          },
        ),
        const Text(
          'MMseqs2 will cluster sequences before partitioning.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  dynamic _getEntityAttribute(Map<String, dynamic> entity, String columnName) {
    if (entity.containsKey(columnName)) return entity[columnName];
    final attributes = entity['attributes'] as Map<String, dynamic>?;
    return attributes?[columnName];
  }

  bool _isColumnNumeric(String columnName) {
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database == null) return false;

    final sample = database.entitiesAsMaps();
    int nonNullCount = 0;

    for (final entity in sample) {
      final rawVal = _getEntityAttribute(entity, columnName);
      if (rawVal == null) continue;
      final str = rawVal.toString().trim();
      if (str.isEmpty || str.toLowerCase() == 'null' || str.toLowerCase() == 'nan') continue;

      nonNullCount++;
      if (double.tryParse(str) == null) {
        return false; // Found a text label -> Classification
      }
    }
    // Only numeric if we actually parsed numbers
    return nonNullCount > 0;
  }

  String _calculateRandomBaseline() {
    if (_selectedTargetColumn == null || _method == null || _splitRatio == null) {
      return 'Select target';
    }
    final database = context.read<BiocentralDatabaseRepository>().getFromType(_selectedDatabaseType);
    if (database == null) return 'N/A';

    final entities = database.entitiesAsMaps();
    if (entities.isEmpty) return 'N/A';

    final ids = entities.map((e) => e['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();

    Map<String, List<String>>? clusters;
    if (_selectedClusterColumn != null) {
      clusters = {};
      for (final e in entities) {
        final id = e['id']?.toString() ?? '';
        final clusterId = _getEntityAttribute(e, _selectedClusterColumn!)?.toString() ?? id;
        clusters.putIfAbsent(clusterId, () => []).add(id);
      }
    }

    final splitMapping = SetGenerator(splitRatio: _splitRatio!).splitByMethod(
      method: _method!,
      ids: ids,
      clusters: clusters,
      seed: _useSeed ? _seed : null,
      subsplitSource: _subsplitSource,
      subsplitTarget: _subsplitTarget,
    );

    final isNumeric = _isColumnNumeric(_selectedTargetColumn!);
    final trainEntities = <Map<String, dynamic>>[];
    final testEntities = <Map<String, dynamic>>[];

    for (final e in entities) {
      final id = e['id']?.toString() ?? '';
      final assignedSet = splitMapping[id];
      if (assignedSet == SplitSet.train || assignedSet == _subsplitSource) {
        trainEntities.add(e);
      } else if (assignedSet == SplitSet.test || assignedSet == _subsplitTarget) {
        testEntities.add(e);
      }
      // SplitSet.member is omitted from baseline prior calculation
    }

    if (trainEntities.isEmpty || testEntities.isEmpty) return 'N/A';

    if (isNumeric) {
      final trainVals = trainEntities
          .map((e) => double.tryParse(_getEntityAttribute(e, _selectedTargetColumn!)?.toString() ?? ''))
          .whereType<double>()
          .toList();
      final testVals = testEntities
          .map((e) => double.tryParse(_getEntityAttribute(e, _selectedTargetColumn!)?.toString() ?? ''))
          .whereType<double>()
          .toList();

      if (trainVals.isEmpty || testVals.isEmpty) return 'N/A';
      final trainMean = trainVals.reduce((a, b) => a + b) / trainVals.length;
      final testMse = testVals.map((v) => pow(v - trainMean, 2)).reduce((a, b) => a + b) / testVals.length;
      return 'RMSE: ${sqrt(testMse).toStringAsFixed(3)}';
    } else {
      final trainCounts = <String, int>{};
      for (final e in trainEntities) {
        final raw = _getEntityAttribute(e, _selectedTargetColumn!);
        if (raw == null) continue;
        final val = raw.toString().trim();
        if (val.isNotEmpty && val.toLowerCase() != 'null') {
          trainCounts[val] = (trainCounts[val] ?? 0) + 1;
        }
      }
      if (trainCounts.isEmpty) return 'N/A';

      final majorityClass = trainCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      int testCorrect = 0;
      int testTotal = 0;
      for (final e in testEntities) {
        final raw = _getEntityAttribute(e, _selectedTargetColumn!);
        if (raw == null) continue;
        final val = raw.toString().trim();
        if (val.isNotEmpty && val.toLowerCase() != 'null') {
          testTotal++;
          if (val == majorityClass) testCorrect++;
        }
      }

      if (testTotal == 0) return 'N/A';
      final acc = (testCorrect / testTotal) * 100;
      return 'Acc: ${acc.toStringAsFixed(1)}%';
    }
  }

  String _formatMetric(BootstrappedMetric? metric, bool isNumeric) {
    if (metric == null) return 'N/A';
    if (isNumeric) {
      return '${metric.mean.toStringAsFixed(3)} [${metric.lower.toStringAsFixed(3)}, ${metric.upper.toStringAsFixed(3)}]';
    } else {
      return '${(metric.mean * 100).toStringAsFixed(1)}% [${(metric.lower * 100).toStringAsFixed(1)}%, ${(metric.upper * 100).toStringAsFixed(1)}%]';
    }
  }

  Widget buildHbiPreviewCard() {
    final isSelected = _selectedTargetColumn != null;
    final isNumeric = isSelected ? _isColumnNumeric(_selectedTargetColumn!) : false;
    final baseline = _calculateRandomBaseline();

    final splitMetric = _splitHbiMetrics?.isNotEmpty == true ? _splitHbiMetrics!.first : null;
    final clusterMetric = _clusterHbiMetrics?.isNotEmpty == true ? _clusterHbiMetrics!.first : null;

    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 18, color: Colors.blueGrey),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Homology & Baseline Leakage',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isEvaluatingHBI)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isNumeric ? 'RMSE' : 'Accuracy',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Vertical stack of metrics for sidebar fit
          _buildMetricRow(
            title: 'Random Baseline',
            value: isSelected ? baseline : 'Select target',
            subtitle: isNumeric ? 'Mean Dummy Prior' : 'Majority Class Prior',
          ),
          const Divider(height: 14),
          _buildMetricRow(
            title: 'Split HBI (Train → Test)',
            value: _isEvaluatingHBI
                ? 'Updating...'
                : (isSelected ? _formatMetric(splitMetric, isNumeric) : 'Select target'),
            subtitle: 'Cross-split homology (easy_search)',
            isPending: _isEvaluatingHBI,
          ),
          const Divider(height: 14),
          _buildMetricRow(
            title: 'Cluster HBI (Intra-Cluster)',
            value: _isEvaluatingHBI
                ? 'Updating...'
                : (isSelected ? _formatMetric(clusterMetric, isNumeric) : 'Select target'),
            subtitle: 'Cluster rep → member transfer',
            isPending: _isEvaluatingHBI,
          ),
          if (_computedClusters != null && _computedClusters!.isNotEmpty) ...[
            const Divider(height: 20),
            const Text(
              'Cluster Size Distribution',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            _buildClusterHistogram(_computedClusters!),
          ],
          if (_hbiErrorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _hbiErrorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClusterHistogram(Map<String, List<String>> clusters) {
    // Generate cluster size frequency bins: 1, 2-5, 6-10, 11-20, >20
    final sizes = clusters.values.map((m) => m.length).toList();
    final bins = <String, int>{
      '1': sizes.where((s) => s == 1).length,
      '2–5': sizes.where((s) => s >= 2 && s <= 5).length,
      '6–10': sizes.where((s) => s >= 6 && s <= 10).length,
      '11–20': sizes.where((s) => s >= 11 && s <= 20).length,
      '>20': sizes.where((s) => s > 20).length,
    };
    final maxCount = bins.values.fold<int>(1, (prev, curr) => curr > prev ? curr : prev);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bins.entries.map((entry) {
        final double barHeight = (entry.value / maxCount) * 50.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${entry.value}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Container(
                  height: barHeight.clamp(4.0, 50.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(entry.key, style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricRow({
    required String title,
    required String value,
    required String subtitle,
    bool isPending = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPending ? Colors.orange.shade700 : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildTargetColumnSelection() {
    final targets = getAvailableTargetColumns();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Target Column (for HBI evaluation):'),
        const SizedBox(height: 6),
        BiocentralDropdownMenu<String>(
          label: const Text('Target Column..'),
          initialSelection: _selectedTargetColumn,
          dropdownMenuEntries: targets.map((col) => DropdownMenuEntry<String>(value: col, label: col)).toList(),
          onSelected: (String? value) => setState(() {
            _selectedTargetColumn = value;
            triggerAutoEvaluation();
          }),
        ),
      ],
    );
  }

  Widget buildSeedSlider() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _useSeed,
                  onChanged: (bool? val) {
                    setState(() {
                      _useSeed = val ?? false;
                      triggerAutoEvaluation();
                    });
                  },
                ),
                Text(
                  _useSeed ? 'Random Seed: $_seed' : 'Random Seed: None (non-deterministic)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (_useSeed)
              IconButton(
                tooltip: 'Roll Random Seed',
                icon: const Icon(Icons.casino_outlined, size: 20),
                onPressed: () {
                  setState(() {
                    _seed = Random().nextInt(1025);
                    triggerAutoEvaluation();
                  });
                },
              ),
          ],
        ),
        if (_useSeed)
          Slider(
            value: _seed.toDouble(),
            max: 1024,
            divisions: 1024,
            label: '$_seed',
            onChanged: (double val) {
              setState(() {
                _seed = val.round();
                triggerAutoEvaluation();
              });
            },
          ),
        const Text(
          'Fix a seed (0–1024) to make split partitions fully reproducible.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildRatioSlider() {
    Widget slider;
    if (_mode == SplitSetGenerationMode.subsplitExisting) {
      slider = BiocentralRatioSlider(
        ratio1: _splitRatio!.r1,
        totalN: _selectedSetColumn?.length,
        labels: [_subsplitSource!.name, _subsplitTarget!.name],
        colors: const [
          Colors.blue,
          Colors.black,
        ],
        onChanged: (ratios) {
          setState(() {
            _splitRatio = SplitRatio.fromRecord(ratios);
            applyConfiguratorHierarchy();
            triggerAutoEvaluation();
          });
        },
      );
    } else {
      slider = BiocentralRatioSlider(
        ratio1: _splitRatio!.r1,
        ratio2: _splitRatio?.r2,
        totalN: _selectedDatabaseLength,
        labels: const ['Training', 'Validation', 'Test'],
        colors: const [Colors.blue, Colors.black, Colors.blueGrey],
        onChanged: (ratios) {
          setState(() {
            _splitRatio = SplitRatio.fromRecord(ratios);
            applyConfiguratorHierarchy();
          });
        },
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Select the size of the subsplit:'),
        slider,
      ],
    );
  }
}
