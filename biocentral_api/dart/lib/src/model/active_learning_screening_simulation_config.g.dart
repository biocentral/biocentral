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
  final ActiveLearningConvergenceConfig convergenceConfig;

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
      required this.convergenceConfig})
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
    return (newBuiltValueToStringHelper(
            r'ActiveLearningScreeningSimulationConfig')
          ..add('simulationData', simulationData)
          ..add('nStart', nStart)
          ..add('startIds', startIds)
          ..add('nSuggestionsPerIteration', nSuggestionsPerIteration)
          ..add('convergenceConfig', convergenceConfig))
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

  ActiveLearningConvergenceConfigBuilder? _convergenceConfig;
  ActiveLearningConvergenceConfigBuilder get convergenceConfig =>
      _$this._convergenceConfig ??= ActiveLearningConvergenceConfigBuilder();
  set convergenceConfig(
          ActiveLearningConvergenceConfigBuilder? convergenceConfig) =>
      _$this._convergenceConfig = convergenceConfig;

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
      _convergenceConfig = $v.convergenceConfig.toBuilder();
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
