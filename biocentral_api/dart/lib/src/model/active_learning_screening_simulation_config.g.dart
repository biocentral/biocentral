// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_screening_simulation_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningScreeningSimulationConfig
    extends ActiveLearningScreeningSimulationConfig {
  @override
  final BuiltList<SequenceData> simulationData;
  @override
  final int? nStart;
  @override
  final BuiltList<String>? startIds;
  @override
  final int nSuggestionsPerIteration;
  @override
  final num? coefficient;
  @override
  final ActiveLearningStoppingConfig stoppingConfig;
  @override
  final num? hitPercentile;
  @override
  final num? hitTargetDelta;

  factory _$ActiveLearningScreeningSimulationConfig(
          [void Function(ActiveLearningScreeningSimulationConfigBuilder)?
              updates]) =>
      (ActiveLearningScreeningSimulationConfigBuilder()..update(updates))
          ._build();

  _$ActiveLearningScreeningSimulationConfig._(
      {required this.simulationData,
      this.nStart,
      this.startIds,
      required this.nSuggestionsPerIteration,
      this.coefficient,
      required this.stoppingConfig,
      this.hitPercentile,
      this.hitTargetDelta})
      : super._();
  @override
  ActiveLearningScreeningSimulationConfig rebuild(
          void Function(ActiveLearningScreeningSimulationConfigBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningScreeningSimulationConfigBuilder toBuilder() =>
      ActiveLearningScreeningSimulationConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningScreeningSimulationConfig &&
        simulationData == other.simulationData &&
        nStart == other.nStart &&
        startIds == other.startIds &&
        nSuggestionsPerIteration == other.nSuggestionsPerIteration &&
        coefficient == other.coefficient &&
        stoppingConfig == other.stoppingConfig &&
        hitPercentile == other.hitPercentile &&
        hitTargetDelta == other.hitTargetDelta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, simulationData.hashCode);
    _$hash = $jc(_$hash, nStart.hashCode);
    _$hash = $jc(_$hash, startIds.hashCode);
    _$hash = $jc(_$hash, nSuggestionsPerIteration.hashCode);
    _$hash = $jc(_$hash, coefficient.hashCode);
    _$hash = $jc(_$hash, stoppingConfig.hashCode);
    _$hash = $jc(_$hash, hitPercentile.hashCode);
    _$hash = $jc(_$hash, hitTargetDelta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ActiveLearningScreeningSimulationConfig')
          ..add('simulationData', simulationData)
          ..add('nStart', nStart)
          ..add('startIds', startIds)
          ..add('nSuggestionsPerIteration', nSuggestionsPerIteration)
          ..add('coefficient', coefficient)
          ..add('stoppingConfig', stoppingConfig)
          ..add('hitPercentile', hitPercentile)
          ..add('hitTargetDelta', hitTargetDelta))
        .toString();
  }
}

class ActiveLearningScreeningSimulationConfigBuilder
    implements
        Builder<ActiveLearningScreeningSimulationConfig,
            ActiveLearningScreeningSimulationConfigBuilder> {
  _$ActiveLearningScreeningSimulationConfig? _$v;

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

  num? _coefficient;
  num? get coefficient => _$this._coefficient;
  set coefficient(num? coefficient) => _$this._coefficient = coefficient;

  ActiveLearningStoppingConfigBuilder? _stoppingConfig;
  ActiveLearningStoppingConfigBuilder get stoppingConfig =>
      _$this._stoppingConfig ??= ActiveLearningStoppingConfigBuilder();
  set stoppingConfig(ActiveLearningStoppingConfigBuilder? stoppingConfig) =>
      _$this._stoppingConfig = stoppingConfig;

  num? _hitPercentile;
  num? get hitPercentile => _$this._hitPercentile;
  set hitPercentile(num? hitPercentile) =>
      _$this._hitPercentile = hitPercentile;

  num? _hitTargetDelta;
  num? get hitTargetDelta => _$this._hitTargetDelta;
  set hitTargetDelta(num? hitTargetDelta) =>
      _$this._hitTargetDelta = hitTargetDelta;

  ActiveLearningScreeningSimulationConfigBuilder() {
    ActiveLearningScreeningSimulationConfig._defaults(this);
  }

  ActiveLearningScreeningSimulationConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _simulationData = $v.simulationData.toBuilder();
      _nStart = $v.nStart;
      _startIds = $v.startIds?.toBuilder();
      _nSuggestionsPerIteration = $v.nSuggestionsPerIteration;
      _coefficient = $v.coefficient;
      _stoppingConfig = $v.stoppingConfig.toBuilder();
      _hitPercentile = $v.hitPercentile;
      _hitTargetDelta = $v.hitTargetDelta;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningScreeningSimulationConfig other) {
    _$v = other as _$ActiveLearningScreeningSimulationConfig;
  }

  @override
  void update(
      void Function(ActiveLearningScreeningSimulationConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningScreeningSimulationConfig build() => _build();

  _$ActiveLearningScreeningSimulationConfig _build() {
    _$ActiveLearningScreeningSimulationConfig _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningScreeningSimulationConfig._(
            simulationData: simulationData.build(),
            nStart: nStart,
            startIds: _startIds?.build(),
            nSuggestionsPerIteration: BuiltValueNullFieldError.checkNotNull(
                nSuggestionsPerIteration,
                r'ActiveLearningScreeningSimulationConfig',
                'nSuggestionsPerIteration'),
            coefficient: coefficient,
            stoppingConfig: stoppingConfig.build(),
            hitPercentile: hitPercentile,
            hitTargetDelta: hitTargetDelta,
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
            r'ActiveLearningScreeningSimulationConfig',
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
