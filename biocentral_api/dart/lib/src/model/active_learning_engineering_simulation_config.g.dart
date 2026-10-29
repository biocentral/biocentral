// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_engineering_simulation_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningEngineeringSimulationConfig
    extends ActiveLearningEngineeringSimulationConfig {
  @override
  final BuiltList<SequenceData> simulationData;
  @override
  final int? nStart;
  @override
  final BuiltList<String>? startIds;
  @override
  final int nSuggestionsPerIteration;
  @override
  final ActiveLearningStoppingConfig stoppingConfig;
  @override
  final num? hitPercentile;
  @override
  final int? nCandidatesPerIteration;

  factory _$ActiveLearningEngineeringSimulationConfig(
          [void Function(ActiveLearningEngineeringSimulationConfigBuilder)?
              updates]) =>
      (ActiveLearningEngineeringSimulationConfigBuilder()..update(updates))
          ._build();

  _$ActiveLearningEngineeringSimulationConfig._(
      {required this.simulationData,
      this.nStart,
      this.startIds,
      required this.nSuggestionsPerIteration,
      required this.stoppingConfig,
      this.hitPercentile,
      this.nCandidatesPerIteration})
      : super._();
  @override
  ActiveLearningEngineeringSimulationConfig rebuild(
          void Function(ActiveLearningEngineeringSimulationConfigBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningEngineeringSimulationConfigBuilder toBuilder() =>
      ActiveLearningEngineeringSimulationConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningEngineeringSimulationConfig &&
        simulationData == other.simulationData &&
        nStart == other.nStart &&
        startIds == other.startIds &&
        nSuggestionsPerIteration == other.nSuggestionsPerIteration &&
        stoppingConfig == other.stoppingConfig &&
        hitPercentile == other.hitPercentile &&
        nCandidatesPerIteration == other.nCandidatesPerIteration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, simulationData.hashCode);
    _$hash = $jc(_$hash, nStart.hashCode);
    _$hash = $jc(_$hash, startIds.hashCode);
    _$hash = $jc(_$hash, nSuggestionsPerIteration.hashCode);
    _$hash = $jc(_$hash, stoppingConfig.hashCode);
    _$hash = $jc(_$hash, hitPercentile.hashCode);
    _$hash = $jc(_$hash, nCandidatesPerIteration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ActiveLearningEngineeringSimulationConfig')
          ..add('simulationData', simulationData)
          ..add('nStart', nStart)
          ..add('startIds', startIds)
          ..add('nSuggestionsPerIteration', nSuggestionsPerIteration)
          ..add('stoppingConfig', stoppingConfig)
          ..add('hitPercentile', hitPercentile)
          ..add('nCandidatesPerIteration', nCandidatesPerIteration))
        .toString();
  }
}

class ActiveLearningEngineeringSimulationConfigBuilder
    implements
        Builder<ActiveLearningEngineeringSimulationConfig,
            ActiveLearningEngineeringSimulationConfigBuilder> {
  _$ActiveLearningEngineeringSimulationConfig? _$v;

  ListBuilder<SequenceData>? _simulationData;
  ListBuilder<SequenceData> get simulationData =>
      _$this._simulationData ??= ListBuilder<SequenceData>();
  set simulationData(ListBuilder<SequenceData>? simulationData) =>
      _$this._simulationData = simulationData;

  int? _nStart;
  int? get nStart => _$this._nStart;
  set nStart(int? nStart) => _$this._nStart = nStart;

  ListBuilder<String>? _startIds;
  ListBuilder<String> get startIds =>
      _$this._startIds ??= ListBuilder<String>();
  set startIds(ListBuilder<String>? startIds) => _$this._startIds = startIds;

  int? _nSuggestionsPerIteration;
  int? get nSuggestionsPerIteration => _$this._nSuggestionsPerIteration;
  set nSuggestionsPerIteration(int? nSuggestionsPerIteration) =>
      _$this._nSuggestionsPerIteration = nSuggestionsPerIteration;

  ActiveLearningStoppingConfigBuilder? _stoppingConfig;
  ActiveLearningStoppingConfigBuilder get stoppingConfig =>
      _$this._stoppingConfig ??= ActiveLearningStoppingConfigBuilder();
  set stoppingConfig(ActiveLearningStoppingConfigBuilder? stoppingConfig) =>
      _$this._stoppingConfig = stoppingConfig;

  num? _hitPercentile;
  num? get hitPercentile => _$this._hitPercentile;
  set hitPercentile(num? hitPercentile) =>
      _$this._hitPercentile = hitPercentile;

  int? _nCandidatesPerIteration;
  int? get nCandidatesPerIteration => _$this._nCandidatesPerIteration;
  set nCandidatesPerIteration(int? nCandidatesPerIteration) =>
      _$this._nCandidatesPerIteration = nCandidatesPerIteration;

  ActiveLearningEngineeringSimulationConfigBuilder() {
    ActiveLearningEngineeringSimulationConfig._defaults(this);
  }

  ActiveLearningEngineeringSimulationConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _simulationData = $v.simulationData.toBuilder();
      _nStart = $v.nStart;
      _startIds = $v.startIds?.toBuilder();
      _nSuggestionsPerIteration = $v.nSuggestionsPerIteration;
      _stoppingConfig = $v.stoppingConfig.toBuilder();
      _hitPercentile = $v.hitPercentile;
      _nCandidatesPerIteration = $v.nCandidatesPerIteration;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningEngineeringSimulationConfig other) {
    _$v = other as _$ActiveLearningEngineeringSimulationConfig;
  }

  @override
  void update(
      void Function(ActiveLearningEngineeringSimulationConfigBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningEngineeringSimulationConfig build() => _build();

  _$ActiveLearningEngineeringSimulationConfig _build() {
    _$ActiveLearningEngineeringSimulationConfig _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningEngineeringSimulationConfig._(
            simulationData: simulationData.build(),
            nStart: nStart,
            startIds: _startIds?.build(),
            nSuggestionsPerIteration: BuiltValueNullFieldError.checkNotNull(
                nSuggestionsPerIteration,
                r'ActiveLearningEngineeringSimulationConfig',
                'nSuggestionsPerIteration'),
            stoppingConfig: stoppingConfig.build(),
            hitPercentile: hitPercentile,
            nCandidatesPerIteration: nCandidatesPerIteration,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'simulationData';
        simulationData.build();

        _$failedField = 'startIds';
        _startIds?.build();

        _$failedField = 'stoppingConfig';
        stoppingConfig.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningEngineeringSimulationConfig',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
