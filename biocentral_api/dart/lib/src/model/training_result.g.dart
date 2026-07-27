// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrainingResult extends TrainingResult {
  @override
  final int? nTrainingIds;
  @override
  final int? nValidationIds;
  @override
  final BuiltList<String>? trainingIds;
  @override
  final BuiltList<String>? validationIds;
  @override
  final BuiltMap<String, JsonObject?>? splitHyperParams;
  @override
  final int? nFreeParameters;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  final num? elapsedTime;
  @override
  final BuiltList<num>? trainingLosses;
  @override
  final BuiltList<num>? validationLosses;
  @override
  final EpochMetrics? bestEpochMetrics;
  @override
  final BuiltList<String>? sanityCheckWarnings;

  factory _$TrainingResult([void Function(TrainingResultBuilder)? updates]) =>
      (TrainingResultBuilder()..update(updates))._build();

  _$TrainingResult._(
      {this.nTrainingIds,
      this.nValidationIds,
      this.trainingIds,
      this.validationIds,
      this.splitHyperParams,
      this.nFreeParameters,
      this.startTime,
      this.endTime,
      this.elapsedTime,
      this.trainingLosses,
      this.validationLosses,
      this.bestEpochMetrics,
      this.sanityCheckWarnings})
      : super._();
  @override
  TrainingResult rebuild(void Function(TrainingResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrainingResultBuilder toBuilder() => TrainingResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrainingResult &&
        nTrainingIds == other.nTrainingIds &&
        nValidationIds == other.nValidationIds &&
        trainingIds == other.trainingIds &&
        validationIds == other.validationIds &&
        splitHyperParams == other.splitHyperParams &&
        nFreeParameters == other.nFreeParameters &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        elapsedTime == other.elapsedTime &&
        trainingLosses == other.trainingLosses &&
        validationLosses == other.validationLosses &&
        bestEpochMetrics == other.bestEpochMetrics &&
        sanityCheckWarnings == other.sanityCheckWarnings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nTrainingIds.hashCode);
    _$hash = $jc(_$hash, nValidationIds.hashCode);
    _$hash = $jc(_$hash, trainingIds.hashCode);
    _$hash = $jc(_$hash, validationIds.hashCode);
    _$hash = $jc(_$hash, splitHyperParams.hashCode);
    _$hash = $jc(_$hash, nFreeParameters.hashCode);
    _$hash = $jc(_$hash, startTime.hashCode);
    _$hash = $jc(_$hash, endTime.hashCode);
    _$hash = $jc(_$hash, elapsedTime.hashCode);
    _$hash = $jc(_$hash, trainingLosses.hashCode);
    _$hash = $jc(_$hash, validationLosses.hashCode);
    _$hash = $jc(_$hash, bestEpochMetrics.hashCode);
    _$hash = $jc(_$hash, sanityCheckWarnings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrainingResult')
          ..add('nTrainingIds', nTrainingIds)
          ..add('nValidationIds', nValidationIds)
          ..add('trainingIds', trainingIds)
          ..add('validationIds', validationIds)
          ..add('splitHyperParams', splitHyperParams)
          ..add('nFreeParameters', nFreeParameters)
          ..add('startTime', startTime)
          ..add('endTime', endTime)
          ..add('elapsedTime', elapsedTime)
          ..add('trainingLosses', trainingLosses)
          ..add('validationLosses', validationLosses)
          ..add('bestEpochMetrics', bestEpochMetrics)
          ..add('sanityCheckWarnings', sanityCheckWarnings))
        .toString();
  }
}

class TrainingResultBuilder
    implements Builder<TrainingResult, TrainingResultBuilder> {
  _$TrainingResult? _$v;

  int? _nTrainingIds;
  int? get nTrainingIds => _$this._nTrainingIds;
  set nTrainingIds(int? nTrainingIds) => _$this._nTrainingIds = nTrainingIds;

  int? _nValidationIds;
  int? get nValidationIds => _$this._nValidationIds;
  set nValidationIds(int? nValidationIds) =>
      _$this._nValidationIds = nValidationIds;

  ListBuilder<String>? _trainingIds;
  ListBuilder<String> get trainingIds =>
      _$this._trainingIds ??= ListBuilder<String>();
  set trainingIds(ListBuilder<String>? trainingIds) =>
      _$this._trainingIds = trainingIds;

  ListBuilder<String>? _validationIds;
  ListBuilder<String> get validationIds =>
      _$this._validationIds ??= ListBuilder<String>();
  set validationIds(ListBuilder<String>? validationIds) =>
      _$this._validationIds = validationIds;

  MapBuilder<String, JsonObject?>? _splitHyperParams;
  MapBuilder<String, JsonObject?> get splitHyperParams =>
      _$this._splitHyperParams ??= MapBuilder<String, JsonObject?>();
  set splitHyperParams(MapBuilder<String, JsonObject?>? splitHyperParams) =>
      _$this._splitHyperParams = splitHyperParams;

  int? _nFreeParameters;
  int? get nFreeParameters => _$this._nFreeParameters;
  set nFreeParameters(int? nFreeParameters) =>
      _$this._nFreeParameters = nFreeParameters;

  String? _startTime;
  String? get startTime => _$this._startTime;
  set startTime(String? startTime) => _$this._startTime = startTime;

  String? _endTime;
  String? get endTime => _$this._endTime;
  set endTime(String? endTime) => _$this._endTime = endTime;

  num? _elapsedTime;
  num? get elapsedTime => _$this._elapsedTime;
  set elapsedTime(num? elapsedTime) => _$this._elapsedTime = elapsedTime;

  ListBuilder<num>? _trainingLosses;
  ListBuilder<num> get trainingLosses =>
      _$this._trainingLosses ??= ListBuilder<num>();
  set trainingLosses(ListBuilder<num>? trainingLosses) =>
      _$this._trainingLosses = trainingLosses;

  ListBuilder<num>? _validationLosses;
  ListBuilder<num> get validationLosses =>
      _$this._validationLosses ??= ListBuilder<num>();
  set validationLosses(ListBuilder<num>? validationLosses) =>
      _$this._validationLosses = validationLosses;

  EpochMetricsBuilder? _bestEpochMetrics;
  EpochMetricsBuilder get bestEpochMetrics =>
      _$this._bestEpochMetrics ??= EpochMetricsBuilder();
  set bestEpochMetrics(EpochMetricsBuilder? bestEpochMetrics) =>
      _$this._bestEpochMetrics = bestEpochMetrics;

  ListBuilder<String>? _sanityCheckWarnings;
  ListBuilder<String> get sanityCheckWarnings =>
      _$this._sanityCheckWarnings ??= ListBuilder<String>();
  set sanityCheckWarnings(ListBuilder<String>? sanityCheckWarnings) =>
      _$this._sanityCheckWarnings = sanityCheckWarnings;

  TrainingResultBuilder() {
    TrainingResult._defaults(this);
  }

  TrainingResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nTrainingIds = $v.nTrainingIds;
      _nValidationIds = $v.nValidationIds;
      _trainingIds = $v.trainingIds?.toBuilder();
      _validationIds = $v.validationIds?.toBuilder();
      _splitHyperParams = $v.splitHyperParams?.toBuilder();
      _nFreeParameters = $v.nFreeParameters;
      _startTime = $v.startTime;
      _endTime = $v.endTime;
      _elapsedTime = $v.elapsedTime;
      _trainingLosses = $v.trainingLosses?.toBuilder();
      _validationLosses = $v.validationLosses?.toBuilder();
      _bestEpochMetrics = $v.bestEpochMetrics?.toBuilder();
      _sanityCheckWarnings = $v.sanityCheckWarnings?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrainingResult other) {
    _$v = other as _$TrainingResult;
  }

  @override
  void update(void Function(TrainingResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrainingResult build() => _build();

  _$TrainingResult _build() {
    _$TrainingResult _$result;
    try {
      _$result = _$v ??
          _$TrainingResult._(
            nTrainingIds: nTrainingIds,
            nValidationIds: nValidationIds,
            trainingIds: _trainingIds?.build(),
            validationIds: _validationIds?.build(),
            splitHyperParams: _splitHyperParams?.build(),
            nFreeParameters: nFreeParameters,
            startTime: startTime,
            endTime: endTime,
            elapsedTime: elapsedTime,
            trainingLosses: _trainingLosses?.build(),
            validationLosses: _validationLosses?.build(),
            bestEpochMetrics: _bestEpochMetrics?.build(),
            sanityCheckWarnings: _sanityCheckWarnings?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'trainingIds';
        _trainingIds?.build();
        _$failedField = 'validationIds';
        _validationIds?.build();
        _$failedField = 'splitHyperParams';
        _splitHyperParams?.build();

        _$failedField = 'trainingLosses';
        _trainingLosses?.build();
        _$failedField = 'validationLosses';
        _validationLosses?.build();
        _$failedField = 'bestEpochMetrics';
        _bestEpochMetrics?.build();
        _$failedField = 'sanityCheckWarnings';
        _sanityCheckWarnings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrainingResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
