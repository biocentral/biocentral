// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_screening_iteration_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningScreeningIterationConfig
    extends ActiveLearningScreeningIterationConfig {
  @override
  final int iteration;
  @override
  final BuiltList<SequenceData> iterationData;
  @override
  final num coefficient;
  @override
  final int nSuggestions;

  factory _$ActiveLearningScreeningIterationConfig(
          [void Function(ActiveLearningScreeningIterationConfigBuilder)?
              updates]) =>
      (ActiveLearningScreeningIterationConfigBuilder()..update(updates))
          ._build();

  _$ActiveLearningScreeningIterationConfig._(
      {required this.iteration,
      required this.iterationData,
      required this.coefficient,
      required this.nSuggestions})
      : super._();
  @override
  ActiveLearningScreeningIterationConfig rebuild(
          void Function(ActiveLearningScreeningIterationConfigBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningScreeningIterationConfigBuilder toBuilder() =>
      ActiveLearningScreeningIterationConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningScreeningIterationConfig &&
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
    return (newBuiltValueToStringHelper(
            r'ActiveLearningScreeningIterationConfig')
          ..add('iteration', iteration)
          ..add('iterationData', iterationData)
          ..add('coefficient', coefficient)
          ..add('nSuggestions', nSuggestions))
        .toString();
  }
}

class ActiveLearningScreeningIterationConfigBuilder
    implements
        Builder<ActiveLearningScreeningIterationConfig,
            ActiveLearningScreeningIterationConfigBuilder> {
  _$ActiveLearningScreeningIterationConfig? _$v;

  int? _iteration;
  int? get iteration => _$this._iteration;
  set iteration(int? iteration) => _$this._iteration = iteration;

  ListBuilder<SequenceData>? _iterationData;
  ListBuilder<SequenceData> get iterationData =>
      _$this._iterationData ??= ListBuilder<SequenceData>();
  set iterationData(ListBuilder<SequenceData>? iterationData) =>
      _$this._iterationData = iterationData;

  num? _coefficient;
  num? get coefficient => _$this._coefficient;
  set coefficient(num? coefficient) => _$this._coefficient = coefficient;

  int? _nSuggestions;
  int? get nSuggestions => _$this._nSuggestions;
  set nSuggestions(int? nSuggestions) => _$this._nSuggestions = nSuggestions;

  ActiveLearningScreeningIterationConfigBuilder() {
    ActiveLearningScreeningIterationConfig._defaults(this);
  }

  ActiveLearningScreeningIterationConfigBuilder get _$this {
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
  void replace(ActiveLearningScreeningIterationConfig other) {
    _$v = other as _$ActiveLearningScreeningIterationConfig;
  }

  @override
  void update(
      void Function(ActiveLearningScreeningIterationConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningScreeningIterationConfig build() => _build();

  _$ActiveLearningScreeningIterationConfig _build() {
    _$ActiveLearningScreeningIterationConfig _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningScreeningIterationConfig._(
            iteration: BuiltValueNullFieldError.checkNotNull(iteration,
                r'ActiveLearningScreeningIterationConfig', 'iteration'),
            iterationData: iterationData.build(),
            coefficient: BuiltValueNullFieldError.checkNotNull(coefficient,
                r'ActiveLearningScreeningIterationConfig', 'coefficient'),
            nSuggestions: BuiltValueNullFieldError.checkNotNull(nSuggestions,
                r'ActiveLearningScreeningIterationConfig', 'nSuggestions'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'iterationData';
        iterationData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningScreeningIterationConfig',
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
