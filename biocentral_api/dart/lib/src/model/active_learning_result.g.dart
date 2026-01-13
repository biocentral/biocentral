// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningResult extends ActiveLearningResult {
  @override
  final String entityId;
  @override
  final num prediction;
  @override
  final num uncertainty;
  @override
  final num score;

  factory _$ActiveLearningResult(
          [void Function(ActiveLearningResultBuilder)? updates]) =>
      (ActiveLearningResultBuilder()..update(updates))._build();

  _$ActiveLearningResult._(
      {required this.entityId,
      required this.prediction,
      required this.uncertainty,
      required this.score})
      : super._();
  @override
  ActiveLearningResult rebuild(
          void Function(ActiveLearningResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningResultBuilder toBuilder() =>
      ActiveLearningResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningResult &&
        entityId == other.entityId &&
        prediction == other.prediction &&
        uncertainty == other.uncertainty &&
        score == other.score;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, prediction.hashCode);
    _$hash = $jc(_$hash, uncertainty.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningResult')
          ..add('entityId', entityId)
          ..add('prediction', prediction)
          ..add('uncertainty', uncertainty)
          ..add('score', score))
        .toString();
  }
}

class ActiveLearningResultBuilder
    implements Builder<ActiveLearningResult, ActiveLearningResultBuilder> {
  _$ActiveLearningResult? _$v;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  num? _prediction;
  num? get prediction => _$this._prediction;
  set prediction(num? prediction) => _$this._prediction = prediction;

  num? _uncertainty;
  num? get uncertainty => _$this._uncertainty;
  set uncertainty(num? uncertainty) => _$this._uncertainty = uncertainty;

  num? _score;
  num? get score => _$this._score;
  set score(num? score) => _$this._score = score;

  ActiveLearningResultBuilder() {
    ActiveLearningResult._defaults(this);
  }

  ActiveLearningResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entityId = $v.entityId;
      _prediction = $v.prediction;
      _uncertainty = $v.uncertainty;
      _score = $v.score;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningResult other) {
    _$v = other as _$ActiveLearningResult;
  }

  @override
  void update(void Function(ActiveLearningResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningResult build() => _build();

  _$ActiveLearningResult _build() {
    final _$result = _$v ??
        _$ActiveLearningResult._(
          entityId: BuiltValueNullFieldError.checkNotNull(
              entityId, r'ActiveLearningResult', 'entityId'),
          prediction: BuiltValueNullFieldError.checkNotNull(
              prediction, r'ActiveLearningResult', 'prediction'),
          uncertainty: BuiltValueNullFieldError.checkNotNull(
              uncertainty, r'ActiveLearningResult', 'uncertainty'),
          score: BuiltValueNullFieldError.checkNotNull(
              score, r'ActiveLearningResult', 'score'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
