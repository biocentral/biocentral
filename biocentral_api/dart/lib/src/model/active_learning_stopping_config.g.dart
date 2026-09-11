// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_stopping_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningStoppingConfig extends ActiveLearningStoppingConfig {
  @override
  final int? maxLabelsBudget;
  @override
  final int? nHits;
  @override
  final int? maxConsecutiveFailures;
  @override
  final int? nMaxIterations;

  factory _$ActiveLearningStoppingConfig(
          [void Function(ActiveLearningStoppingConfigBuilder)? updates]) =>
      (ActiveLearningStoppingConfigBuilder()..update(updates))._build();

  _$ActiveLearningStoppingConfig._(
      {this.maxLabelsBudget,
      this.nHits,
      this.maxConsecutiveFailures,
      this.nMaxIterations})
      : super._();
  @override
  ActiveLearningStoppingConfig rebuild(
          void Function(ActiveLearningStoppingConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningStoppingConfigBuilder toBuilder() =>
      ActiveLearningStoppingConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningStoppingConfig &&
        maxLabelsBudget == other.maxLabelsBudget &&
        nHits == other.nHits &&
        maxConsecutiveFailures == other.maxConsecutiveFailures &&
        nMaxIterations == other.nMaxIterations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, maxLabelsBudget.hashCode);
    _$hash = $jc(_$hash, nHits.hashCode);
    _$hash = $jc(_$hash, maxConsecutiveFailures.hashCode);
    _$hash = $jc(_$hash, nMaxIterations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningStoppingConfig')
          ..add('maxLabelsBudget', maxLabelsBudget)
          ..add('nHits', nHits)
          ..add('maxConsecutiveFailures', maxConsecutiveFailures)
          ..add('nMaxIterations', nMaxIterations))
        .toString();
  }
}

class ActiveLearningStoppingConfigBuilder
    implements
        Builder<ActiveLearningStoppingConfig,
            ActiveLearningStoppingConfigBuilder> {
  _$ActiveLearningStoppingConfig? _$v;

  int? _maxLabelsBudget;
  int? get maxLabelsBudget => _$this._maxLabelsBudget;
  set maxLabelsBudget(int? maxLabelsBudget) =>
      _$this._maxLabelsBudget = maxLabelsBudget;

  int? _nHits;
  int? get nHits => _$this._nHits;
  set nHits(int? nHits) => _$this._nHits = nHits;

  int? _maxConsecutiveFailures;
  int? get maxConsecutiveFailures => _$this._maxConsecutiveFailures;
  set maxConsecutiveFailures(int? maxConsecutiveFailures) =>
      _$this._maxConsecutiveFailures = maxConsecutiveFailures;

  int? _nMaxIterations;
  int? get nMaxIterations => _$this._nMaxIterations;
  set nMaxIterations(int? nMaxIterations) =>
      _$this._nMaxIterations = nMaxIterations;

  ActiveLearningStoppingConfigBuilder() {
    ActiveLearningStoppingConfig._defaults(this);
  }

  ActiveLearningStoppingConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _maxLabelsBudget = $v.maxLabelsBudget;
      _nHits = $v.nHits;
      _maxConsecutiveFailures = $v.maxConsecutiveFailures;
      _nMaxIterations = $v.nMaxIterations;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningStoppingConfig other) {
    _$v = other as _$ActiveLearningStoppingConfig;
  }

  @override
  void update(void Function(ActiveLearningStoppingConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningStoppingConfig build() => _build();

  _$ActiveLearningStoppingConfig _build() {
    final _$result = _$v ??
        _$ActiveLearningStoppingConfig._(
          maxLabelsBudget: maxLabelsBudget,
          nHits: nHits,
          maxConsecutiveFailures: maxConsecutiveFailures,
          nMaxIterations: nMaxIterations,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
