// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_screening_simulation_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningScreeningSimulationResult
    extends ActiveLearningScreeningSimulationResult {
  @override
  final String campaignName;
  @override
  final BuiltList<String> potentialHits;
  @override
  final BuiltList<BootstrappedMetric>? iterationMetricsTotal;
  @override
  final BuiltList<BootstrappedMetric>? iterationMetricsSuggestions;
  @override
  final BuiltList<BuiltList<String>>? iterationHits;
  @override
  final BuiltList<int>? iterationConsecutiveFailures;
  @override
  final BuiltList<String>? stopReasons;
  @override
  final BuiltList<ActiveLearningIterationResult>? iterationResults;

  factory _$ActiveLearningScreeningSimulationResult(
          [void Function(ActiveLearningScreeningSimulationResultBuilder)?
              updates]) =>
      (ActiveLearningScreeningSimulationResultBuilder()..update(updates))
          ._build();

  _$ActiveLearningScreeningSimulationResult._(
      {required this.campaignName,
      required this.potentialHits,
      this.iterationMetricsTotal,
      this.iterationMetricsSuggestions,
      this.iterationHits,
      this.iterationConsecutiveFailures,
      this.stopReasons,
      this.iterationResults})
      : super._();
  @override
  ActiveLearningScreeningSimulationResult rebuild(
          void Function(ActiveLearningScreeningSimulationResultBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningScreeningSimulationResultBuilder toBuilder() =>
      ActiveLearningScreeningSimulationResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningScreeningSimulationResult &&
        campaignName == other.campaignName &&
        potentialHits == other.potentialHits &&
        iterationMetricsTotal == other.iterationMetricsTotal &&
        iterationMetricsSuggestions == other.iterationMetricsSuggestions &&
        iterationHits == other.iterationHits &&
        iterationConsecutiveFailures == other.iterationConsecutiveFailures &&
        stopReasons == other.stopReasons &&
        iterationResults == other.iterationResults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campaignName.hashCode);
    _$hash = $jc(_$hash, potentialHits.hashCode);
    _$hash = $jc(_$hash, iterationMetricsTotal.hashCode);
    _$hash = $jc(_$hash, iterationMetricsSuggestions.hashCode);
    _$hash = $jc(_$hash, iterationHits.hashCode);
    _$hash = $jc(_$hash, iterationConsecutiveFailures.hashCode);
    _$hash = $jc(_$hash, stopReasons.hashCode);
    _$hash = $jc(_$hash, iterationResults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ActiveLearningScreeningSimulationResult')
          ..add('campaignName', campaignName)
          ..add('potentialHits', potentialHits)
          ..add('iterationMetricsTotal', iterationMetricsTotal)
          ..add('iterationMetricsSuggestions', iterationMetricsSuggestions)
          ..add('iterationHits', iterationHits)
          ..add('iterationConsecutiveFailures', iterationConsecutiveFailures)
          ..add('stopReasons', stopReasons)
          ..add('iterationResults', iterationResults))
        .toString();
  }
}

class ActiveLearningScreeningSimulationResultBuilder
    implements
        Builder<ActiveLearningScreeningSimulationResult,
            ActiveLearningScreeningSimulationResultBuilder> {
  _$ActiveLearningScreeningSimulationResult? _$v;

  String? _campaignName;
  String? get campaignName => _$this._campaignName;
  set campaignName(String? campaignName) => _$this._campaignName = campaignName;

  ListBuilder<String>? _potentialHits;
  ListBuilder<String> get potentialHits =>
      _$this._potentialHits ??= ListBuilder<String>();
  set potentialHits(ListBuilder<String>? potentialHits) =>
      _$this._potentialHits = potentialHits;

  ListBuilder<BootstrappedMetric>? _iterationMetricsTotal;
  ListBuilder<BootstrappedMetric> get iterationMetricsTotal =>
      _$this._iterationMetricsTotal ??= ListBuilder<BootstrappedMetric>();
  set iterationMetricsTotal(
          ListBuilder<BootstrappedMetric>? iterationMetricsTotal) =>
      _$this._iterationMetricsTotal = iterationMetricsTotal;

  ListBuilder<BootstrappedMetric>? _iterationMetricsSuggestions;
  ListBuilder<BootstrappedMetric> get iterationMetricsSuggestions =>
      _$this._iterationMetricsSuggestions ??= ListBuilder<BootstrappedMetric>();
  set iterationMetricsSuggestions(
          ListBuilder<BootstrappedMetric>? iterationMetricsSuggestions) =>
      _$this._iterationMetricsSuggestions = iterationMetricsSuggestions;

  ListBuilder<BuiltList<String>>? _iterationHits;
  ListBuilder<BuiltList<String>> get iterationHits =>
      _$this._iterationHits ??= ListBuilder<BuiltList<String>>();
  set iterationHits(ListBuilder<BuiltList<String>>? iterationHits) =>
      _$this._iterationHits = iterationHits;

  ListBuilder<int>? _iterationConsecutiveFailures;
  ListBuilder<int> get iterationConsecutiveFailures =>
      _$this._iterationConsecutiveFailures ??= ListBuilder<int>();
  set iterationConsecutiveFailures(
          ListBuilder<int>? iterationConsecutiveFailures) =>
      _$this._iterationConsecutiveFailures = iterationConsecutiveFailures;

  ListBuilder<String>? _stopReasons;
  ListBuilder<String> get stopReasons =>
      _$this._stopReasons ??= ListBuilder<String>();
  set stopReasons(ListBuilder<String>? stopReasons) =>
      _$this._stopReasons = stopReasons;

  ListBuilder<ActiveLearningIterationResult>? _iterationResults;
  ListBuilder<ActiveLearningIterationResult> get iterationResults =>
      _$this._iterationResults ??= ListBuilder<ActiveLearningIterationResult>();
  set iterationResults(
          ListBuilder<ActiveLearningIterationResult>? iterationResults) =>
      _$this._iterationResults = iterationResults;

  ActiveLearningScreeningSimulationResultBuilder() {
    ActiveLearningScreeningSimulationResult._defaults(this);
  }

  ActiveLearningScreeningSimulationResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignName = $v.campaignName;
      _potentialHits = $v.potentialHits.toBuilder();
      _iterationMetricsTotal = $v.iterationMetricsTotal?.toBuilder();
      _iterationMetricsSuggestions =
          $v.iterationMetricsSuggestions?.toBuilder();
      _iterationHits = $v.iterationHits?.toBuilder();
      _iterationConsecutiveFailures =
          $v.iterationConsecutiveFailures?.toBuilder();
      _stopReasons = $v.stopReasons?.toBuilder();
      _iterationResults = $v.iterationResults?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningScreeningSimulationResult other) {
    _$v = other as _$ActiveLearningScreeningSimulationResult;
  }

  @override
  void update(
      void Function(ActiveLearningScreeningSimulationResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningScreeningSimulationResult build() => _build();

  _$ActiveLearningScreeningSimulationResult _build() {
    _$ActiveLearningScreeningSimulationResult _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningScreeningSimulationResult._(
            campaignName: BuiltValueNullFieldError.checkNotNull(campaignName,
                r'ActiveLearningScreeningSimulationResult', 'campaignName'),
            potentialHits: potentialHits.build(),
            iterationMetricsTotal: _iterationMetricsTotal?.build(),
            iterationMetricsSuggestions: _iterationMetricsSuggestions?.build(),
            iterationHits: _iterationHits?.build(),
            iterationConsecutiveFailures:
                _iterationConsecutiveFailures?.build(),
            stopReasons: _stopReasons?.build(),
            iterationResults: _iterationResults?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'potentialHits';
        potentialHits.build();
        _$failedField = 'iterationMetricsTotal';
        _iterationMetricsTotal?.build();
        _$failedField = 'iterationMetricsSuggestions';
        _iterationMetricsSuggestions?.build();
        _$failedField = 'iterationHits';
        _iterationHits?.build();
        _$failedField = 'iterationConsecutiveFailures';
        _iterationConsecutiveFailures?.build();
        _$failedField = 'stopReasons';
        _stopReasons?.build();
        _$failedField = 'iterationResults';
        _iterationResults?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningScreeningSimulationResult',
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
