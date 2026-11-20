// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_engineering_iteration_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningEngineeringIterationConfig
    extends ActiveLearningEngineeringIterationConfig {
  @override
  final int iteration;
  @override
  final BuiltList<String>? baseSequences;
  @override
  final BuiltList<SequenceData> trainingData;
  @override
  final num coefficient;
  @override
  final int nSuggestions;
  @override
  final int? nMutations;
  @override
  final int? nSubstitutions;
  @override
  final bool? generateCandidates;

  factory _$ActiveLearningEngineeringIterationConfig(
          [void Function(ActiveLearningEngineeringIterationConfigBuilder)?
              updates]) =>
      (ActiveLearningEngineeringIterationConfigBuilder()..update(updates))
          ._build();

  _$ActiveLearningEngineeringIterationConfig._(
      {required this.iteration,
      this.baseSequences,
      required this.trainingData,
      required this.coefficient,
      required this.nSuggestions,
      this.nMutations,
      this.nSubstitutions,
      this.generateCandidates})
      : super._();
  @override
  ActiveLearningEngineeringIterationConfig rebuild(
          void Function(ActiveLearningEngineeringIterationConfigBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningEngineeringIterationConfigBuilder toBuilder() =>
      ActiveLearningEngineeringIterationConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningEngineeringIterationConfig &&
        iteration == other.iteration &&
        baseSequences == other.baseSequences &&
        trainingData == other.trainingData &&
        coefficient == other.coefficient &&
        nSuggestions == other.nSuggestions &&
        nMutations == other.nMutations &&
        nSubstitutions == other.nSubstitutions &&
        generateCandidates == other.generateCandidates;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, iteration.hashCode);
    _$hash = $jc(_$hash, baseSequences.hashCode);
    _$hash = $jc(_$hash, trainingData.hashCode);
    _$hash = $jc(_$hash, coefficient.hashCode);
    _$hash = $jc(_$hash, nSuggestions.hashCode);
    _$hash = $jc(_$hash, nMutations.hashCode);
    _$hash = $jc(_$hash, nSubstitutions.hashCode);
    _$hash = $jc(_$hash, generateCandidates.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ActiveLearningEngineeringIterationConfig')
          ..add('iteration', iteration)
          ..add('baseSequences', baseSequences)
          ..add('trainingData', trainingData)
          ..add('coefficient', coefficient)
          ..add('nSuggestions', nSuggestions)
          ..add('nMutations', nMutations)
          ..add('nSubstitutions', nSubstitutions)
          ..add('generateCandidates', generateCandidates))
        .toString();
  }
}

class ActiveLearningEngineeringIterationConfigBuilder
    implements
        Builder<ActiveLearningEngineeringIterationConfig,
            ActiveLearningEngineeringIterationConfigBuilder> {
  _$ActiveLearningEngineeringIterationConfig? _$v;

  int? _iteration;
  int? get iteration => _$this._iteration;
  set iteration(int? iteration) => _$this._iteration = iteration;

  ListBuilder<String>? _baseSequences;
  ListBuilder<String> get baseSequences =>
      _$this._baseSequences ??= ListBuilder<String>();
  set baseSequences(ListBuilder<String>? baseSequences) =>
      _$this._baseSequences = baseSequences;

  ListBuilder<SequenceData>? _trainingData;
  ListBuilder<SequenceData> get trainingData =>
      _$this._trainingData ??= ListBuilder<SequenceData>();
  set trainingData(ListBuilder<SequenceData>? trainingData) =>
      _$this._trainingData = trainingData;

  num? _coefficient;
  num? get coefficient => _$this._coefficient;
  set coefficient(num? coefficient) => _$this._coefficient = coefficient;

  int? _nSuggestions;
  int? get nSuggestions => _$this._nSuggestions;
  set nSuggestions(int? nSuggestions) => _$this._nSuggestions = nSuggestions;

  int? _nMutations;
  int? get nMutations => _$this._nMutations;
  set nMutations(int? nMutations) => _$this._nMutations = nMutations;

  int? _nSubstitutions;
  int? get nSubstitutions => _$this._nSubstitutions;
  set nSubstitutions(int? nSubstitutions) =>
      _$this._nSubstitutions = nSubstitutions;

  bool? _generateCandidates;
  bool? get generateCandidates => _$this._generateCandidates;
  set generateCandidates(bool? generateCandidates) =>
      _$this._generateCandidates = generateCandidates;

  ActiveLearningEngineeringIterationConfigBuilder() {
    ActiveLearningEngineeringIterationConfig._defaults(this);
  }

  ActiveLearningEngineeringIterationConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _iteration = $v.iteration;
      _baseSequences = $v.baseSequences?.toBuilder();
      _trainingData = $v.trainingData.toBuilder();
      _coefficient = $v.coefficient;
      _nSuggestions = $v.nSuggestions;
      _nMutations = $v.nMutations;
      _nSubstitutions = $v.nSubstitutions;
      _generateCandidates = $v.generateCandidates;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningEngineeringIterationConfig other) {
    _$v = other as _$ActiveLearningEngineeringIterationConfig;
  }

  @override
  void update(
      void Function(ActiveLearningEngineeringIterationConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningEngineeringIterationConfig build() => _build();

  _$ActiveLearningEngineeringIterationConfig _build() {
    _$ActiveLearningEngineeringIterationConfig _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningEngineeringIterationConfig._(
            iteration: BuiltValueNullFieldError.checkNotNull(iteration,
                r'ActiveLearningEngineeringIterationConfig', 'iteration'),
            baseSequences: _baseSequences?.build(),
            trainingData: trainingData.build(),
            coefficient: BuiltValueNullFieldError.checkNotNull(coefficient,
                r'ActiveLearningEngineeringIterationConfig', 'coefficient'),
            nSuggestions: BuiltValueNullFieldError.checkNotNull(nSuggestions,
                r'ActiveLearningEngineeringIterationConfig', 'nSuggestions'),
            nMutations: nMutations,
            nSubstitutions: nSubstitutions,
            generateCandidates: generateCandidates,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'baseSequences';
        _baseSequences?.build();
        _$failedField = 'trainingData';
        trainingData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningEngineeringIterationConfig',
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
