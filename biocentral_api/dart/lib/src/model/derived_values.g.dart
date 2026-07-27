// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'derived_values.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DerivedValues extends DerivedValues {
  @override
  final String? biotrainerVersion;
  @override
  final BuiltMap<String, String>? classInt2str;
  @override
  final BuiltMap<String, int>? classStr2int;
  @override
  final BuiltMap<String, num>? computedClassWeights;
  @override
  final EmbeddingStats? embeddingStats;
  @override
  final String? embeddingsFile;
  @override
  final String? modelHash;
  @override
  final int? nClasses;
  @override
  final int? nFeatures;
  @override
  final int? nTestingIds;
  @override
  final num? pipelineElapsedTime;
  @override
  final String? pipelineEndTime;
  @override
  final String? pipelineStartTime;
  @override
  final num? trainingElapsedTime;

  factory _$DerivedValues([void Function(DerivedValuesBuilder)? updates]) =>
      (DerivedValuesBuilder()..update(updates))._build();

  _$DerivedValues._(
      {this.biotrainerVersion,
      this.classInt2str,
      this.classStr2int,
      this.computedClassWeights,
      this.embeddingStats,
      this.embeddingsFile,
      this.modelHash,
      this.nClasses,
      this.nFeatures,
      this.nTestingIds,
      this.pipelineElapsedTime,
      this.pipelineEndTime,
      this.pipelineStartTime,
      this.trainingElapsedTime})
      : super._();
  @override
  DerivedValues rebuild(void Function(DerivedValuesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DerivedValuesBuilder toBuilder() => DerivedValuesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DerivedValues &&
        biotrainerVersion == other.biotrainerVersion &&
        classInt2str == other.classInt2str &&
        classStr2int == other.classStr2int &&
        computedClassWeights == other.computedClassWeights &&
        embeddingStats == other.embeddingStats &&
        embeddingsFile == other.embeddingsFile &&
        modelHash == other.modelHash &&
        nClasses == other.nClasses &&
        nFeatures == other.nFeatures &&
        nTestingIds == other.nTestingIds &&
        pipelineElapsedTime == other.pipelineElapsedTime &&
        pipelineEndTime == other.pipelineEndTime &&
        pipelineStartTime == other.pipelineStartTime &&
        trainingElapsedTime == other.trainingElapsedTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, biotrainerVersion.hashCode);
    _$hash = $jc(_$hash, classInt2str.hashCode);
    _$hash = $jc(_$hash, classStr2int.hashCode);
    _$hash = $jc(_$hash, computedClassWeights.hashCode);
    _$hash = $jc(_$hash, embeddingStats.hashCode);
    _$hash = $jc(_$hash, embeddingsFile.hashCode);
    _$hash = $jc(_$hash, modelHash.hashCode);
    _$hash = $jc(_$hash, nClasses.hashCode);
    _$hash = $jc(_$hash, nFeatures.hashCode);
    _$hash = $jc(_$hash, nTestingIds.hashCode);
    _$hash = $jc(_$hash, pipelineElapsedTime.hashCode);
    _$hash = $jc(_$hash, pipelineEndTime.hashCode);
    _$hash = $jc(_$hash, pipelineStartTime.hashCode);
    _$hash = $jc(_$hash, trainingElapsedTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DerivedValues')
          ..add('biotrainerVersion', biotrainerVersion)
          ..add('classInt2str', classInt2str)
          ..add('classStr2int', classStr2int)
          ..add('computedClassWeights', computedClassWeights)
          ..add('embeddingStats', embeddingStats)
          ..add('embeddingsFile', embeddingsFile)
          ..add('modelHash', modelHash)
          ..add('nClasses', nClasses)
          ..add('nFeatures', nFeatures)
          ..add('nTestingIds', nTestingIds)
          ..add('pipelineElapsedTime', pipelineElapsedTime)
          ..add('pipelineEndTime', pipelineEndTime)
          ..add('pipelineStartTime', pipelineStartTime)
          ..add('trainingElapsedTime', trainingElapsedTime))
        .toString();
  }
}

class DerivedValuesBuilder
    implements Builder<DerivedValues, DerivedValuesBuilder> {
  _$DerivedValues? _$v;

  String? _biotrainerVersion;
  String? get biotrainerVersion => _$this._biotrainerVersion;
  set biotrainerVersion(String? biotrainerVersion) =>
      _$this._biotrainerVersion = biotrainerVersion;

  MapBuilder<String, String>? _classInt2str;
  MapBuilder<String, String> get classInt2str =>
      _$this._classInt2str ??= MapBuilder<String, String>();
  set classInt2str(MapBuilder<String, String>? classInt2str) =>
      _$this._classInt2str = classInt2str;

  MapBuilder<String, int>? _classStr2int;
  MapBuilder<String, int> get classStr2int =>
      _$this._classStr2int ??= MapBuilder<String, int>();
  set classStr2int(MapBuilder<String, int>? classStr2int) =>
      _$this._classStr2int = classStr2int;

  MapBuilder<String, num>? _computedClassWeights;
  MapBuilder<String, num> get computedClassWeights =>
      _$this._computedClassWeights ??= MapBuilder<String, num>();
  set computedClassWeights(MapBuilder<String, num>? computedClassWeights) =>
      _$this._computedClassWeights = computedClassWeights;

  EmbeddingStatsBuilder? _embeddingStats;
  EmbeddingStatsBuilder get embeddingStats =>
      _$this._embeddingStats ??= EmbeddingStatsBuilder();
  set embeddingStats(EmbeddingStatsBuilder? embeddingStats) =>
      _$this._embeddingStats = embeddingStats;

  String? _embeddingsFile;
  String? get embeddingsFile => _$this._embeddingsFile;
  set embeddingsFile(String? embeddingsFile) =>
      _$this._embeddingsFile = embeddingsFile;

  String? _modelHash;
  String? get modelHash => _$this._modelHash;
  set modelHash(String? modelHash) => _$this._modelHash = modelHash;

  int? _nClasses;
  int? get nClasses => _$this._nClasses;
  set nClasses(int? nClasses) => _$this._nClasses = nClasses;

  int? _nFeatures;
  int? get nFeatures => _$this._nFeatures;
  set nFeatures(int? nFeatures) => _$this._nFeatures = nFeatures;

  int? _nTestingIds;
  int? get nTestingIds => _$this._nTestingIds;
  set nTestingIds(int? nTestingIds) => _$this._nTestingIds = nTestingIds;

  num? _pipelineElapsedTime;
  num? get pipelineElapsedTime => _$this._pipelineElapsedTime;
  set pipelineElapsedTime(num? pipelineElapsedTime) =>
      _$this._pipelineElapsedTime = pipelineElapsedTime;

  String? _pipelineEndTime;
  String? get pipelineEndTime => _$this._pipelineEndTime;
  set pipelineEndTime(String? pipelineEndTime) =>
      _$this._pipelineEndTime = pipelineEndTime;

  String? _pipelineStartTime;
  String? get pipelineStartTime => _$this._pipelineStartTime;
  set pipelineStartTime(String? pipelineStartTime) =>
      _$this._pipelineStartTime = pipelineStartTime;

  num? _trainingElapsedTime;
  num? get trainingElapsedTime => _$this._trainingElapsedTime;
  set trainingElapsedTime(num? trainingElapsedTime) =>
      _$this._trainingElapsedTime = trainingElapsedTime;

  DerivedValuesBuilder() {
    DerivedValues._defaults(this);
  }

  DerivedValuesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _biotrainerVersion = $v.biotrainerVersion;
      _classInt2str = $v.classInt2str?.toBuilder();
      _classStr2int = $v.classStr2int?.toBuilder();
      _computedClassWeights = $v.computedClassWeights?.toBuilder();
      _embeddingStats = $v.embeddingStats?.toBuilder();
      _embeddingsFile = $v.embeddingsFile;
      _modelHash = $v.modelHash;
      _nClasses = $v.nClasses;
      _nFeatures = $v.nFeatures;
      _nTestingIds = $v.nTestingIds;
      _pipelineElapsedTime = $v.pipelineElapsedTime;
      _pipelineEndTime = $v.pipelineEndTime;
      _pipelineStartTime = $v.pipelineStartTime;
      _trainingElapsedTime = $v.trainingElapsedTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DerivedValues other) {
    _$v = other as _$DerivedValues;
  }

  @override
  void update(void Function(DerivedValuesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DerivedValues build() => _build();

  _$DerivedValues _build() {
    _$DerivedValues _$result;
    try {
      _$result = _$v ??
          _$DerivedValues._(
            biotrainerVersion: biotrainerVersion,
            classInt2str: _classInt2str?.build(),
            classStr2int: _classStr2int?.build(),
            computedClassWeights: _computedClassWeights?.build(),
            embeddingStats: _embeddingStats?.build(),
            embeddingsFile: embeddingsFile,
            modelHash: modelHash,
            nClasses: nClasses,
            nFeatures: nFeatures,
            nTestingIds: nTestingIds,
            pipelineElapsedTime: pipelineElapsedTime,
            pipelineEndTime: pipelineEndTime,
            pipelineStartTime: pipelineStartTime,
            trainingElapsedTime: trainingElapsedTime,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'classInt2str';
        _classInt2str?.build();
        _$failedField = 'classStr2int';
        _classStr2int?.build();
        _$failedField = 'computedClassWeights';
        _computedClassWeights?.build();
        _$failedField = 'embeddingStats';
        _embeddingStats?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DerivedValues', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
