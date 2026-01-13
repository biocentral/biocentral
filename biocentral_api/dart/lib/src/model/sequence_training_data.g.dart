// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sequence_training_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SequenceTrainingData extends SequenceTrainingData {
  @override
  final String seqId;
  @override
  final String sequence;
  @override
  final String set_;
  @override
  final String? label;
  @override
  final String? mask;

  factory _$SequenceTrainingData(
          [void Function(SequenceTrainingDataBuilder)? updates]) =>
      (SequenceTrainingDataBuilder()..update(updates))._build();

  _$SequenceTrainingData._(
      {required this.seqId,
      required this.sequence,
      required this.set_,
      this.label,
      this.mask})
      : super._();
  @override
  SequenceTrainingData rebuild(
          void Function(SequenceTrainingDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SequenceTrainingDataBuilder toBuilder() =>
      SequenceTrainingDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SequenceTrainingData &&
        seqId == other.seqId &&
        sequence == other.sequence &&
        set_ == other.set_ &&
        label == other.label &&
        mask == other.mask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, seqId.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, set_.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, mask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SequenceTrainingData')
          ..add('seqId', seqId)
          ..add('sequence', sequence)
          ..add('set_', set_)
          ..add('label', label)
          ..add('mask', mask))
        .toString();
  }
}

class SequenceTrainingDataBuilder
    implements Builder<SequenceTrainingData, SequenceTrainingDataBuilder> {
  _$SequenceTrainingData? _$v;

  String? _seqId;
  String? get seqId => _$this._seqId;
  set seqId(String? seqId) => _$this._seqId = seqId;

  String? _sequence;
  String? get sequence => _$this._sequence;
  set sequence(String? sequence) => _$this._sequence = sequence;

  String? _set_;
  String? get set_ => _$this._set_;
  set set_(String? set_) => _$this._set_ = set_;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _mask;
  String? get mask => _$this._mask;
  set mask(String? mask) => _$this._mask = mask;

  SequenceTrainingDataBuilder() {
    SequenceTrainingData._defaults(this);
  }

  SequenceTrainingDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _seqId = $v.seqId;
      _sequence = $v.sequence;
      _set_ = $v.set_;
      _label = $v.label;
      _mask = $v.mask;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SequenceTrainingData other) {
    _$v = other as _$SequenceTrainingData;
  }

  @override
  void update(void Function(SequenceTrainingDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SequenceTrainingData build() => _build();

  _$SequenceTrainingData _build() {
    final _$result = _$v ??
        _$SequenceTrainingData._(
          seqId: BuiltValueNullFieldError.checkNotNull(
              seqId, r'SequenceTrainingData', 'seqId'),
          sequence: BuiltValueNullFieldError.checkNotNull(
              sequence, r'SequenceTrainingData', 'sequence'),
          set_: BuiltValueNullFieldError.checkNotNull(
              set_, r'SequenceTrainingData', 'set_'),
          label: label,
          mask: mask,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
