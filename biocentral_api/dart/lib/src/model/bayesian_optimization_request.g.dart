// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bayesian_optimization_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BayesianOptimizationRequest extends BayesianOptimizationRequest {
  @override
  final String databaseHash;
  @override
  final String modelType;
  @override
  final num coefficient;
  @override
  final String embedderName;
  @override
  final bool discrete;
  @override
  final String optimizationMode;
  @override
  final num? targetLb;
  @override
  final num? targetUb;
  @override
  final num? targetValue;
  @override
  final BuiltList<String>? discreteLabels;
  @override
  final BuiltList<String>? discreteTargets;

  factory _$BayesianOptimizationRequest(
          [void Function(BayesianOptimizationRequestBuilder)? updates]) =>
      (BayesianOptimizationRequestBuilder()..update(updates))._build();

  _$BayesianOptimizationRequest._(
      {required this.databaseHash,
      required this.modelType,
      required this.coefficient,
      required this.embedderName,
      required this.discrete,
      required this.optimizationMode,
      this.targetLb,
      this.targetUb,
      this.targetValue,
      this.discreteLabels,
      this.discreteTargets})
      : super._();
  @override
  BayesianOptimizationRequest rebuild(
          void Function(BayesianOptimizationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BayesianOptimizationRequestBuilder toBuilder() =>
      BayesianOptimizationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BayesianOptimizationRequest &&
        databaseHash == other.databaseHash &&
        modelType == other.modelType &&
        coefficient == other.coefficient &&
        embedderName == other.embedderName &&
        discrete == other.discrete &&
        optimizationMode == other.optimizationMode &&
        targetLb == other.targetLb &&
        targetUb == other.targetUb &&
        targetValue == other.targetValue &&
        discreteLabels == other.discreteLabels &&
        discreteTargets == other.discreteTargets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, databaseHash.hashCode);
    _$hash = $jc(_$hash, modelType.hashCode);
    _$hash = $jc(_$hash, coefficient.hashCode);
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, discrete.hashCode);
    _$hash = $jc(_$hash, optimizationMode.hashCode);
    _$hash = $jc(_$hash, targetLb.hashCode);
    _$hash = $jc(_$hash, targetUb.hashCode);
    _$hash = $jc(_$hash, targetValue.hashCode);
    _$hash = $jc(_$hash, discreteLabels.hashCode);
    _$hash = $jc(_$hash, discreteTargets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BayesianOptimizationRequest')
          ..add('databaseHash', databaseHash)
          ..add('modelType', modelType)
          ..add('coefficient', coefficient)
          ..add('embedderName', embedderName)
          ..add('discrete', discrete)
          ..add('optimizationMode', optimizationMode)
          ..add('targetLb', targetLb)
          ..add('targetUb', targetUb)
          ..add('targetValue', targetValue)
          ..add('discreteLabels', discreteLabels)
          ..add('discreteTargets', discreteTargets))
        .toString();
  }
}

class BayesianOptimizationRequestBuilder
    implements
        Builder<BayesianOptimizationRequest,
            BayesianOptimizationRequestBuilder> {
  _$BayesianOptimizationRequest? _$v;

  String? _databaseHash;
  String? get databaseHash => _$this._databaseHash;
  set databaseHash(String? databaseHash) => _$this._databaseHash = databaseHash;

  String? _modelType;
  String? get modelType => _$this._modelType;
  set modelType(String? modelType) => _$this._modelType = modelType;

  num? _coefficient;
  num? get coefficient => _$this._coefficient;
  set coefficient(num? coefficient) => _$this._coefficient = coefficient;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  bool? _discrete;
  bool? get discrete => _$this._discrete;
  set discrete(bool? discrete) => _$this._discrete = discrete;

  String? _optimizationMode;
  String? get optimizationMode => _$this._optimizationMode;
  set optimizationMode(String? optimizationMode) =>
      _$this._optimizationMode = optimizationMode;

  num? _targetLb;
  num? get targetLb => _$this._targetLb;
  set targetLb(num? targetLb) => _$this._targetLb = targetLb;

  num? _targetUb;
  num? get targetUb => _$this._targetUb;
  set targetUb(num? targetUb) => _$this._targetUb = targetUb;

  num? _targetValue;
  num? get targetValue => _$this._targetValue;
  set targetValue(num? targetValue) => _$this._targetValue = targetValue;

  ListBuilder<String>? _discreteLabels;
  ListBuilder<String> get discreteLabels =>
      _$this._discreteLabels ??= ListBuilder<String>();
  set discreteLabels(ListBuilder<String>? discreteLabels) =>
      _$this._discreteLabels = discreteLabels;

  ListBuilder<String>? _discreteTargets;
  ListBuilder<String> get discreteTargets =>
      _$this._discreteTargets ??= ListBuilder<String>();
  set discreteTargets(ListBuilder<String>? discreteTargets) =>
      _$this._discreteTargets = discreteTargets;

  BayesianOptimizationRequestBuilder() {
    BayesianOptimizationRequest._defaults(this);
  }

  BayesianOptimizationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _databaseHash = $v.databaseHash;
      _modelType = $v.modelType;
      _coefficient = $v.coefficient;
      _embedderName = $v.embedderName;
      _discrete = $v.discrete;
      _optimizationMode = $v.optimizationMode;
      _targetLb = $v.targetLb;
      _targetUb = $v.targetUb;
      _targetValue = $v.targetValue;
      _discreteLabels = $v.discreteLabels?.toBuilder();
      _discreteTargets = $v.discreteTargets?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BayesianOptimizationRequest other) {
    _$v = other as _$BayesianOptimizationRequest;
  }

  @override
  void update(void Function(BayesianOptimizationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BayesianOptimizationRequest build() => _build();

  _$BayesianOptimizationRequest _build() {
    _$BayesianOptimizationRequest _$result;
    try {
      _$result = _$v ??
          _$BayesianOptimizationRequest._(
            databaseHash: BuiltValueNullFieldError.checkNotNull(
                databaseHash, r'BayesianOptimizationRequest', 'databaseHash'),
            modelType: BuiltValueNullFieldError.checkNotNull(
                modelType, r'BayesianOptimizationRequest', 'modelType'),
            coefficient: BuiltValueNullFieldError.checkNotNull(
                coefficient, r'BayesianOptimizationRequest', 'coefficient'),
            embedderName: BuiltValueNullFieldError.checkNotNull(
                embedderName, r'BayesianOptimizationRequest', 'embedderName'),
            discrete: BuiltValueNullFieldError.checkNotNull(
                discrete, r'BayesianOptimizationRequest', 'discrete'),
            optimizationMode: BuiltValueNullFieldError.checkNotNull(
                optimizationMode,
                r'BayesianOptimizationRequest',
                'optimizationMode'),
            targetLb: targetLb,
            targetUb: targetUb,
            targetValue: targetValue,
            discreteLabels: _discreteLabels?.build(),
            discreteTargets: _discreteTargets?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'discreteLabels';
        _discreteLabels?.build();
        _$failedField = 'discreteTargets';
        _discreteTargets?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BayesianOptimizationRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
