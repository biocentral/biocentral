// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biotrainer_prediction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiotrainerPrediction extends BiotrainerPrediction {
  @override
  final String seqId;
  @override
  final Prediction1 prediction;
  @override
  final bool? isAggregated;
  @override
  final int? residueIndex;
  @override
  final RawPrediction? rawPrediction;
  @override
  final BuiltList<JsonObject?>? mcdPredictions;
  @override
  final McdMean? mcdMean;
  @override
  final McdStd? mcdStd;
  @override
  final McdLowerBound? mcdLowerBound;
  @override
  final McdUpperBound? mcdUpperBound;
  @override
  final num? baldScore;

  factory _$BiotrainerPrediction(
          [void Function(BiotrainerPredictionBuilder)? updates]) =>
      (BiotrainerPredictionBuilder()..update(updates))._build();

  _$BiotrainerPrediction._(
      {required this.seqId,
      required this.prediction,
      this.isAggregated,
      this.residueIndex,
      this.rawPrediction,
      this.mcdPredictions,
      this.mcdMean,
      this.mcdStd,
      this.mcdLowerBound,
      this.mcdUpperBound,
      this.baldScore})
      : super._();
  @override
  BiotrainerPrediction rebuild(
          void Function(BiotrainerPredictionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiotrainerPredictionBuilder toBuilder() =>
      BiotrainerPredictionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiotrainerPrediction &&
        seqId == other.seqId &&
        prediction == other.prediction &&
        isAggregated == other.isAggregated &&
        residueIndex == other.residueIndex &&
        rawPrediction == other.rawPrediction &&
        mcdPredictions == other.mcdPredictions &&
        mcdMean == other.mcdMean &&
        mcdStd == other.mcdStd &&
        mcdLowerBound == other.mcdLowerBound &&
        mcdUpperBound == other.mcdUpperBound &&
        baldScore == other.baldScore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, seqId.hashCode);
    _$hash = $jc(_$hash, prediction.hashCode);
    _$hash = $jc(_$hash, isAggregated.hashCode);
    _$hash = $jc(_$hash, residueIndex.hashCode);
    _$hash = $jc(_$hash, rawPrediction.hashCode);
    _$hash = $jc(_$hash, mcdPredictions.hashCode);
    _$hash = $jc(_$hash, mcdMean.hashCode);
    _$hash = $jc(_$hash, mcdStd.hashCode);
    _$hash = $jc(_$hash, mcdLowerBound.hashCode);
    _$hash = $jc(_$hash, mcdUpperBound.hashCode);
    _$hash = $jc(_$hash, baldScore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiotrainerPrediction')
          ..add('seqId', seqId)
          ..add('prediction', prediction)
          ..add('isAggregated', isAggregated)
          ..add('residueIndex', residueIndex)
          ..add('rawPrediction', rawPrediction)
          ..add('mcdPredictions', mcdPredictions)
          ..add('mcdMean', mcdMean)
          ..add('mcdStd', mcdStd)
          ..add('mcdLowerBound', mcdLowerBound)
          ..add('mcdUpperBound', mcdUpperBound)
          ..add('baldScore', baldScore))
        .toString();
  }
}

class BiotrainerPredictionBuilder
    implements Builder<BiotrainerPrediction, BiotrainerPredictionBuilder> {
  _$BiotrainerPrediction? _$v;

  String? _seqId;
  String? get seqId => _$this._seqId;
  set seqId(String? seqId) => _$this._seqId = seqId;

  Prediction1Builder? _prediction;
  Prediction1Builder get prediction =>
      _$this._prediction ??= Prediction1Builder();
  set prediction(Prediction1Builder? prediction) =>
      _$this._prediction = prediction;

  bool? _isAggregated;
  bool? get isAggregated => _$this._isAggregated;
  set isAggregated(bool? isAggregated) => _$this._isAggregated = isAggregated;

  int? _residueIndex;
  int? get residueIndex => _$this._residueIndex;
  set residueIndex(int? residueIndex) => _$this._residueIndex = residueIndex;

  RawPredictionBuilder? _rawPrediction;
  RawPredictionBuilder get rawPrediction =>
      _$this._rawPrediction ??= RawPredictionBuilder();
  set rawPrediction(RawPredictionBuilder? rawPrediction) =>
      _$this._rawPrediction = rawPrediction;

  ListBuilder<JsonObject?>? _mcdPredictions;
  ListBuilder<JsonObject?> get mcdPredictions =>
      _$this._mcdPredictions ??= ListBuilder<JsonObject?>();
  set mcdPredictions(ListBuilder<JsonObject?>? mcdPredictions) =>
      _$this._mcdPredictions = mcdPredictions;

  McdMeanBuilder? _mcdMean;
  McdMeanBuilder get mcdMean => _$this._mcdMean ??= McdMeanBuilder();
  set mcdMean(McdMeanBuilder? mcdMean) => _$this._mcdMean = mcdMean;

  McdStdBuilder? _mcdStd;
  McdStdBuilder get mcdStd => _$this._mcdStd ??= McdStdBuilder();
  set mcdStd(McdStdBuilder? mcdStd) => _$this._mcdStd = mcdStd;

  McdLowerBoundBuilder? _mcdLowerBound;
  McdLowerBoundBuilder get mcdLowerBound =>
      _$this._mcdLowerBound ??= McdLowerBoundBuilder();
  set mcdLowerBound(McdLowerBoundBuilder? mcdLowerBound) =>
      _$this._mcdLowerBound = mcdLowerBound;

  McdUpperBoundBuilder? _mcdUpperBound;
  McdUpperBoundBuilder get mcdUpperBound =>
      _$this._mcdUpperBound ??= McdUpperBoundBuilder();
  set mcdUpperBound(McdUpperBoundBuilder? mcdUpperBound) =>
      _$this._mcdUpperBound = mcdUpperBound;

  num? _baldScore;
  num? get baldScore => _$this._baldScore;
  set baldScore(num? baldScore) => _$this._baldScore = baldScore;

  BiotrainerPredictionBuilder() {
    BiotrainerPrediction._defaults(this);
  }

  BiotrainerPredictionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _seqId = $v.seqId;
      _prediction = $v.prediction.toBuilder();
      _isAggregated = $v.isAggregated;
      _residueIndex = $v.residueIndex;
      _rawPrediction = $v.rawPrediction?.toBuilder();
      _mcdPredictions = $v.mcdPredictions?.toBuilder();
      _mcdMean = $v.mcdMean?.toBuilder();
      _mcdStd = $v.mcdStd?.toBuilder();
      _mcdLowerBound = $v.mcdLowerBound?.toBuilder();
      _mcdUpperBound = $v.mcdUpperBound?.toBuilder();
      _baldScore = $v.baldScore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiotrainerPrediction other) {
    _$v = other as _$BiotrainerPrediction;
  }

  @override
  void update(void Function(BiotrainerPredictionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiotrainerPrediction build() => _build();

  _$BiotrainerPrediction _build() {
    _$BiotrainerPrediction _$result;
    try {
      _$result = _$v ??
          _$BiotrainerPrediction._(
            seqId: BuiltValueNullFieldError.checkNotNull(
                seqId, r'BiotrainerPrediction', 'seqId'),
            prediction: prediction.build(),
            isAggregated: isAggregated,
            residueIndex: residueIndex,
            rawPrediction: _rawPrediction?.build(),
            mcdPredictions: _mcdPredictions?.build(),
            mcdMean: _mcdMean?.build(),
            mcdStd: _mcdStd?.build(),
            mcdLowerBound: _mcdLowerBound?.build(),
            mcdUpperBound: _mcdUpperBound?.build(),
            baldScore: baldScore,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'prediction';
        prediction.build();

        _$failedField = 'rawPrediction';
        _rawPrediction?.build();
        _$failedField = 'mcdPredictions';
        _mcdPredictions?.build();
        _$failedField = 'mcdMean';
        _mcdMean?.build();
        _$failedField = 'mcdStd';
        _mcdStd?.build();
        _$failedField = 'mcdLowerBound';
        _mcdLowerBound?.build();
        _$failedField = 'mcdUpperBound';
        _mcdUpperBound?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BiotrainerPrediction', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
