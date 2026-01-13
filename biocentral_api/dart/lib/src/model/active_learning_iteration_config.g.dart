// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_iteration_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningIterationConfig extends ActiveLearningIterationConfig {
  @override
  final int iteration;
  @override
  final BuiltList<SequenceTrainingData> iterationData;
  @override
  final num coefficient;
  @override
  final int nSuggestions;

  factory _$ActiveLearningIterationConfig(
          [void Function(ActiveLearningIterationConfigBuilder)? updates]) =>
      (ActiveLearningIterationConfigBuilder()..update(updates))._build();

  _$ActiveLearningIterationConfig._(
      {required this.iteration,
      required this.iterationData,
      required this.coefficient,
      required this.nSuggestions})
      : super._();
  @override
  ActiveLearningIterationConfig rebuild(
          void Function(ActiveLearningIterationConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningIterationConfigBuilder toBuilder() =>
      ActiveLearningIterationConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningIterationConfig &&
        iteration == other.iteration &&
        iterationData == other.iterationData &&
        coefficient == other.coefficient &&
        nSuggestions == other.nSuggestions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, iteration.hashCode);
    _$hash = $jc(_$hash, iterationData.hashCode);
    _$hash = $jc(_$hash, coefficient.hashCode);
    _$hash = $jc(_$hash, nSuggestions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningIterationConfig')
          ..add('iteration', iteration)
          ..add('iterationData', iterationData)
          ..add('coefficient', coefficient)
          ..add('nSuggestions', nSuggestions))
        .toString();
  }
}

class ActiveLearningIterationConfigBuilder
    implements
        Builder<ActiveLearningIterationConfig,
            ActiveLearningIterationConfigBuilder> {
  _$ActiveLearningIterationConfig? _$v;

  int? _iteration;
  int? get iteration => _$this._iteration;
  set iteration(int? iteration) => _$this._iteration = iteration;

  ListBuilder<SequenceTrainingData>? _iterationData;
  ListBuilder<SequenceTrainingData> get iterationData =>
      _$this._iterationData ??= ListBuilder<SequenceTrainingData>();
  set iterationData(ListBuilder<SequenceTrainingData>? iterationData) =>
      _$this._iterationData = iterationData;

  num? _coefficient;
  num? get coefficient => _$this._coefficient;
  set coefficient(num? coefficient) => _$this._coefficient = coefficient;

  int? _nSuggestions;
  int? get nSuggestions => _$this._nSuggestions;
  set nSuggestions(int? nSuggestions) => _$this._nSuggestions = nSuggestions;

  ActiveLearningIterationConfigBuilder() {
    ActiveLearningIterationConfig._defaults(this);
  }

  ActiveLearningIterationConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _iteration = $v.iteration;
      _iterationData = $v.iterationData.toBuilder();
      _coefficient = $v.coefficient;
      _nSuggestions = $v.nSuggestions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningIterationConfig other) {
    _$v = other as _$ActiveLearningIterationConfig;
  }

  @override
  void update(void Function(ActiveLearningIterationConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningIterationConfig build() => _build();

  _$ActiveLearningIterationConfig _build() {
    _$ActiveLearningIterationConfig _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningIterationConfig._(
            iteration: BuiltValueNullFieldError.checkNotNull(
                iteration, r'ActiveLearningIterationConfig', 'iteration'),
            iterationData: iterationData.build(),
            coefficient: BuiltValueNullFieldError.checkNotNull(
                coefficient, r'ActiveLearningIterationConfig', 'coefficient'),
            nSuggestions: BuiltValueNullFieldError.checkNotNull(
                nSuggestions, r'ActiveLearningIterationConfig', 'nSuggestions'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'iterationData';
        iterationData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningIterationConfig', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
