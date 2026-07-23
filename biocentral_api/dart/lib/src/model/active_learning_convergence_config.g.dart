// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_convergence_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningConvergenceConfig
    extends ActiveLearningConvergenceConfig {
  @override
  final int? maxLabelsBudget;
  @override
  final int? nHits;
  @override
  final int? maxConsecutiveFailures;

  factory _$ActiveLearningConvergenceConfig(
          [void Function(ActiveLearningConvergenceConfigBuilder)? updates]) =>
      (ActiveLearningConvergenceConfigBuilder()..update(updates))._build();

  _$ActiveLearningConvergenceConfig._(
      {this.maxLabelsBudget, this.nHits, this.maxConsecutiveFailures})
      : super._();
  @override
  ActiveLearningConvergenceConfig rebuild(
          void Function(ActiveLearningConvergenceConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningConvergenceConfigBuilder toBuilder() =>
      ActiveLearningConvergenceConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningConvergenceConfig &&
        maxLabelsBudget == other.maxLabelsBudget &&
        nHits == other.nHits &&
        maxConsecutiveFailures == other.maxConsecutiveFailures;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, maxLabelsBudget.hashCode);
    _$hash = $jc(_$hash, nHits.hashCode);
    _$hash = $jc(_$hash, maxConsecutiveFailures.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningConvergenceConfig')
          ..add('maxLabelsBudget', maxLabelsBudget)
          ..add('nHits', nHits)
          ..add('maxConsecutiveFailures', maxConsecutiveFailures))
        .toString();
  }
}

class ActiveLearningConvergenceConfigBuilder
    implements
        Builder<ActiveLearningConvergenceConfig,
            ActiveLearningConvergenceConfigBuilder> {
  _$ActiveLearningConvergenceConfig? _$v;

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

  ActiveLearningConvergenceConfigBuilder() {
    ActiveLearningConvergenceConfig._defaults(this);
  }

  ActiveLearningConvergenceConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _maxLabelsBudget = $v.maxLabelsBudget;
      _nHits = $v.nHits;
      _maxConsecutiveFailures = $v.maxConsecutiveFailures;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningConvergenceConfig other) {
    _$v = other as _$ActiveLearningConvergenceConfig;
  }

  @override
  void update(void Function(ActiveLearningConvergenceConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningConvergenceConfig build() => _build();

  _$ActiveLearningConvergenceConfig _build() {
    final _$result = _$v ??
        _$ActiveLearningConvergenceConfig._(
          maxLabelsBudget: maxLabelsBudget,
          nHits: nHits,
          maxConsecutiveFailures: maxConsecutiveFailures,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
