// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_simulation_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningSimulationConfig extends ActiveLearningSimulationConfig {
  @override
  final BuiltList<SequenceTrainingData> simulationData;
  @override
  final int? nStart;
  @override
  final BuiltList<String>? startIds;
  @override
  final int nSuggestionsPerIteration;
  @override
  final ActiveLearningConvergenceConfig convergenceConfig;

  factory _$ActiveLearningSimulationConfig(
          [void Function(ActiveLearningSimulationConfigBuilder)? updates]) =>
      (ActiveLearningSimulationConfigBuilder()..update(updates))._build();

  _$ActiveLearningSimulationConfig._(
      {required this.simulationData,
      this.nStart,
      this.startIds,
      required this.nSuggestionsPerIteration,
      required this.convergenceConfig})
      : super._();
  @override
  ActiveLearningSimulationConfig rebuild(
          void Function(ActiveLearningSimulationConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningSimulationConfigBuilder toBuilder() =>
      ActiveLearningSimulationConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningSimulationConfig &&
        simulationData == other.simulationData &&
        nStart == other.nStart &&
        startIds == other.startIds &&
        nSuggestionsPerIteration == other.nSuggestionsPerIteration &&
        convergenceConfig == other.convergenceConfig;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, simulationData.hashCode);
    _$hash = $jc(_$hash, nStart.hashCode);
    _$hash = $jc(_$hash, startIds.hashCode);
    _$hash = $jc(_$hash, nSuggestionsPerIteration.hashCode);
    _$hash = $jc(_$hash, convergenceConfig.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningSimulationConfig')
          ..add('simulationData', simulationData)
          ..add('nStart', nStart)
          ..add('startIds', startIds)
          ..add('nSuggestionsPerIteration', nSuggestionsPerIteration)
          ..add('convergenceConfig', convergenceConfig))
        .toString();
  }
}

class ActiveLearningSimulationConfigBuilder
    implements
        Builder<ActiveLearningSimulationConfig,
            ActiveLearningSimulationConfigBuilder> {
  _$ActiveLearningSimulationConfig? _$v;

  ListBuilder<SequenceTrainingData>? _simulationData;
  ListBuilder<SequenceTrainingData> get simulationData =>
      _$this._simulationData ??= ListBuilder<SequenceTrainingData>();
  set simulationData(ListBuilder<SequenceTrainingData>? simulationData) =>
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

  ActiveLearningConvergenceConfigBuilder? _convergenceConfig;
  ActiveLearningConvergenceConfigBuilder get convergenceConfig =>
      _$this._convergenceConfig ??= ActiveLearningConvergenceConfigBuilder();
  set convergenceConfig(
          ActiveLearningConvergenceConfigBuilder? convergenceConfig) =>
      _$this._convergenceConfig = convergenceConfig;

  ActiveLearningSimulationConfigBuilder() {
    ActiveLearningSimulationConfig._defaults(this);
  }

  ActiveLearningSimulationConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _simulationData = $v.simulationData.toBuilder();
      _nStart = $v.nStart;
      _startIds = $v.startIds?.toBuilder();
      _nSuggestionsPerIteration = $v.nSuggestionsPerIteration;
      _convergenceConfig = $v.convergenceConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningSimulationConfig other) {
    _$v = other as _$ActiveLearningSimulationConfig;
  }

  @override
  void update(void Function(ActiveLearningSimulationConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningSimulationConfig build() => _build();

  _$ActiveLearningSimulationConfig _build() {
    _$ActiveLearningSimulationConfig _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningSimulationConfig._(
            simulationData: simulationData.build(),
            nStart: nStart,
            startIds: _startIds?.build(),
            nSuggestionsPerIteration: BuiltValueNullFieldError.checkNotNull(
                nSuggestionsPerIteration,
                r'ActiveLearningSimulationConfig',
                'nSuggestionsPerIteration'),
            convergenceConfig: convergenceConfig.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'simulationData';
        simulationData.build();

        _$failedField = 'startIds';
        _startIds?.build();

        _$failedField = 'convergenceConfig';
        convergenceConfig.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningSimulationConfig', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
