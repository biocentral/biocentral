// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_engineering_campaign_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningEngineeringCampaignConfig
    extends ActiveLearningEngineeringCampaignConfig {
  @override
  final String embedderName;
  @override
  final String name;
  @override
  final ActiveLearningModelType modelType;
  @override
  final ActiveLearningOptimizationMode optimizationMode;
  @override
  final int? seed;
  @override
  final String wildtypeSequence;

  factory _$ActiveLearningEngineeringCampaignConfig(
          [void Function(ActiveLearningEngineeringCampaignConfigBuilder)?
              updates]) =>
      (ActiveLearningEngineeringCampaignConfigBuilder()..update(updates))
          ._build();

  _$ActiveLearningEngineeringCampaignConfig._(
      {required this.embedderName,
      required this.name,
      required this.modelType,
      required this.optimizationMode,
      this.seed,
      required this.wildtypeSequence})
      : super._();
  @override
  ActiveLearningEngineeringCampaignConfig rebuild(
          void Function(ActiveLearningEngineeringCampaignConfigBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningEngineeringCampaignConfigBuilder toBuilder() =>
      ActiveLearningEngineeringCampaignConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningEngineeringCampaignConfig &&
        embedderName == other.embedderName &&
        name == other.name &&
        modelType == other.modelType &&
        optimizationMode == other.optimizationMode &&
        seed == other.seed &&
        wildtypeSequence == other.wildtypeSequence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, modelType.hashCode);
    _$hash = $jc(_$hash, optimizationMode.hashCode);
    _$hash = $jc(_$hash, seed.hashCode);
    _$hash = $jc(_$hash, wildtypeSequence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ActiveLearningEngineeringCampaignConfig')
          ..add('embedderName', embedderName)
          ..add('name', name)
          ..add('modelType', modelType)
          ..add('optimizationMode', optimizationMode)
          ..add('seed', seed)
          ..add('wildtypeSequence', wildtypeSequence))
        .toString();
  }
}

class ActiveLearningEngineeringCampaignConfigBuilder
    implements
        Builder<ActiveLearningEngineeringCampaignConfig,
            ActiveLearningEngineeringCampaignConfigBuilder> {
  _$ActiveLearningEngineeringCampaignConfig? _$v;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ActiveLearningModelType? _modelType;
  ActiveLearningModelType? get modelType => _$this._modelType;
  set modelType(ActiveLearningModelType? modelType) =>
      _$this._modelType = modelType;

  ActiveLearningOptimizationMode? _optimizationMode;
  ActiveLearningOptimizationMode? get optimizationMode =>
      _$this._optimizationMode;
  set optimizationMode(ActiveLearningOptimizationMode? optimizationMode) =>
      _$this._optimizationMode = optimizationMode;

  int? _seed;
  int? get seed => _$this._seed;
  set seed(int? seed) => _$this._seed = seed;

  String? _wildtypeSequence;
  String? get wildtypeSequence => _$this._wildtypeSequence;
  set wildtypeSequence(String? wildtypeSequence) =>
      _$this._wildtypeSequence = wildtypeSequence;

  ActiveLearningEngineeringCampaignConfigBuilder() {
    ActiveLearningEngineeringCampaignConfig._defaults(this);
  }

  ActiveLearningEngineeringCampaignConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _embedderName = $v.embedderName;
      _name = $v.name;
      _modelType = $v.modelType;
      _optimizationMode = $v.optimizationMode;
      _seed = $v.seed;
      _wildtypeSequence = $v.wildtypeSequence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningEngineeringCampaignConfig other) {
    _$v = other as _$ActiveLearningEngineeringCampaignConfig;
  }

  @override
  void update(
      void Function(ActiveLearningEngineeringCampaignConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningEngineeringCampaignConfig build() => _build();

  _$ActiveLearningEngineeringCampaignConfig _build() {
    final _$result = _$v ??
        _$ActiveLearningEngineeringCampaignConfig._(
          embedderName: BuiltValueNullFieldError.checkNotNull(embedderName,
              r'ActiveLearningEngineeringCampaignConfig', 'embedderName'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ActiveLearningEngineeringCampaignConfig', 'name'),
          modelType: BuiltValueNullFieldError.checkNotNull(modelType,
              r'ActiveLearningEngineeringCampaignConfig', 'modelType'),
          optimizationMode: BuiltValueNullFieldError.checkNotNull(
              optimizationMode,
              r'ActiveLearningEngineeringCampaignConfig',
              'optimizationMode'),
          seed: seed,
          wildtypeSequence: BuiltValueNullFieldError.checkNotNull(
              wildtypeSequence,
              r'ActiveLearningEngineeringCampaignConfig',
              'wildtypeSequence'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
