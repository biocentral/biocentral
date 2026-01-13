// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_campaign_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningCampaignConfig extends ActiveLearningCampaignConfig {
  @override
  final String name;
  @override
  final ActiveLearningModelType modelType;
  @override
  final String embedderName;
  @override
  final ActiveLearningOptimizationMode optimizationMode;
  @override
  final int? seed;
  @override
  final num? targetLb;
  @override
  final num? targetUb;
  @override
  final num? targetValue;
  @override
  final BuiltList<String>? discreteTargets;

  factory _$ActiveLearningCampaignConfig(
          [void Function(ActiveLearningCampaignConfigBuilder)? updates]) =>
      (ActiveLearningCampaignConfigBuilder()..update(updates))._build();

  _$ActiveLearningCampaignConfig._(
      {required this.name,
      required this.modelType,
      required this.embedderName,
      required this.optimizationMode,
      this.seed,
      this.targetLb,
      this.targetUb,
      this.targetValue,
      this.discreteTargets})
      : super._();
  @override
  ActiveLearningCampaignConfig rebuild(
          void Function(ActiveLearningCampaignConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningCampaignConfigBuilder toBuilder() =>
      ActiveLearningCampaignConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningCampaignConfig &&
        name == other.name &&
        modelType == other.modelType &&
        embedderName == other.embedderName &&
        optimizationMode == other.optimizationMode &&
        seed == other.seed &&
        targetLb == other.targetLb &&
        targetUb == other.targetUb &&
        targetValue == other.targetValue &&
        discreteTargets == other.discreteTargets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, modelType.hashCode);
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, optimizationMode.hashCode);
    _$hash = $jc(_$hash, seed.hashCode);
    _$hash = $jc(_$hash, targetLb.hashCode);
    _$hash = $jc(_$hash, targetUb.hashCode);
    _$hash = $jc(_$hash, targetValue.hashCode);
    _$hash = $jc(_$hash, discreteTargets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningCampaignConfig')
          ..add('name', name)
          ..add('modelType', modelType)
          ..add('embedderName', embedderName)
          ..add('optimizationMode', optimizationMode)
          ..add('seed', seed)
          ..add('targetLb', targetLb)
          ..add('targetUb', targetUb)
          ..add('targetValue', targetValue)
          ..add('discreteTargets', discreteTargets))
        .toString();
  }
}

class ActiveLearningCampaignConfigBuilder
    implements
        Builder<ActiveLearningCampaignConfig,
            ActiveLearningCampaignConfigBuilder> {
  _$ActiveLearningCampaignConfig? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ActiveLearningModelType? _modelType;
  ActiveLearningModelType? get modelType => _$this._modelType;
  set modelType(ActiveLearningModelType? modelType) =>
      _$this._modelType = modelType;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  ActiveLearningOptimizationMode? _optimizationMode;
  ActiveLearningOptimizationMode? get optimizationMode =>
      _$this._optimizationMode;
  set optimizationMode(ActiveLearningOptimizationMode? optimizationMode) =>
      _$this._optimizationMode = optimizationMode;

  int? _seed;
  int? get seed => _$this._seed;
  set seed(int? seed) => _$this._seed = seed;

  num? _targetLb;
  num? get targetLb => _$this._targetLb;
  set targetLb(num? targetLb) => _$this._targetLb = targetLb;

  num? _targetUb;
  num? get targetUb => _$this._targetUb;
  set targetUb(num? targetUb) => _$this._targetUb = targetUb;

  num? _targetValue;
  num? get targetValue => _$this._targetValue;
  set targetValue(num? targetValue) => _$this._targetValue = targetValue;

  ListBuilder<String>? _discreteTargets;
  ListBuilder<String> get discreteTargets =>
      _$this._discreteTargets ??= ListBuilder<String>();
  set discreteTargets(ListBuilder<String>? discreteTargets) =>
      _$this._discreteTargets = discreteTargets;

  ActiveLearningCampaignConfigBuilder() {
    ActiveLearningCampaignConfig._defaults(this);
  }

  ActiveLearningCampaignConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _modelType = $v.modelType;
      _embedderName = $v.embedderName;
      _optimizationMode = $v.optimizationMode;
      _seed = $v.seed;
      _targetLb = $v.targetLb;
      _targetUb = $v.targetUb;
      _targetValue = $v.targetValue;
      _discreteTargets = $v.discreteTargets?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningCampaignConfig other) {
    _$v = other as _$ActiveLearningCampaignConfig;
  }

  @override
  void update(void Function(ActiveLearningCampaignConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningCampaignConfig build() => _build();

  _$ActiveLearningCampaignConfig _build() {
    _$ActiveLearningCampaignConfig _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningCampaignConfig._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ActiveLearningCampaignConfig', 'name'),
            modelType: BuiltValueNullFieldError.checkNotNull(
                modelType, r'ActiveLearningCampaignConfig', 'modelType'),
            embedderName: BuiltValueNullFieldError.checkNotNull(
                embedderName, r'ActiveLearningCampaignConfig', 'embedderName'),
            optimizationMode: BuiltValueNullFieldError.checkNotNull(
                optimizationMode,
                r'ActiveLearningCampaignConfig',
                'optimizationMode'),
            seed: seed,
            targetLb: targetLb,
            targetUb: targetUb,
            targetValue: targetValue,
            discreteTargets: _discreteTargets?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'discreteTargets';
        _discreteTargets?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningCampaignConfig', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
