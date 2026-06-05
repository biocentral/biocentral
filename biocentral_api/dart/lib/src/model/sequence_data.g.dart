// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sequence_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SequenceData extends SequenceData {
  @override
  final String seqId;
  @override
  final String seq;
  @override
  final String? label;
  @override
  final String? set_;
  @override
  final String? mask;
  @override
  final BuiltMap<String, JsonObject?>? attributes;
  @override
  final BuiltList<JsonObject?>? embedding;

  factory _$SequenceData([void Function(SequenceDataBuilder)? updates]) =>
      (SequenceDataBuilder()..update(updates))._build();

  _$SequenceData._(
      {required this.seqId,
      required this.seq,
      this.label,
      this.set_,
      this.mask,
      this.attributes,
      this.embedding})
      : super._();
  @override
  SequenceData rebuild(void Function(SequenceDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SequenceDataBuilder toBuilder() => SequenceDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SequenceData &&
        seqId == other.seqId &&
        seq == other.seq &&
        label == other.label &&
        set_ == other.set_ &&
        mask == other.mask &&
        attributes == other.attributes &&
        embedding == other.embedding;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, seqId.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, set_.hashCode);
    _$hash = $jc(_$hash, mask.hashCode);
    _$hash = $jc(_$hash, attributes.hashCode);
    _$hash = $jc(_$hash, embedding.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SequenceData')
          ..add('seqId', seqId)
          ..add('seq', seq)
          ..add('label', label)
          ..add('set_', set_)
          ..add('mask', mask)
          ..add('attributes', attributes)
          ..add('embedding', embedding))
        .toString();
  }
}

class SequenceDataBuilder
    implements Builder<SequenceData, SequenceDataBuilder> {
  _$SequenceData? _$v;

  String? _seqId;
  String? get seqId => _$this._seqId;
  set seqId(String? seqId) => _$this._seqId = seqId;

  String? _seq;
  String? get seq => _$this._seq;
  set seq(String? seq) => _$this._seq = seq;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _set_;
  String? get set_ => _$this._set_;
  set set_(String? set_) => _$this._set_ = set_;

  String? _mask;
  String? get mask => _$this._mask;
  set mask(String? mask) => _$this._mask = mask;

  MapBuilder<String, JsonObject?>? _attributes;
  MapBuilder<String, JsonObject?> get attributes =>
      _$this._attributes ??= MapBuilder<String, JsonObject?>();
  set attributes(MapBuilder<String, JsonObject?>? attributes) =>
      _$this._attributes = attributes;

  ListBuilder<JsonObject?>? _embedding;
  ListBuilder<JsonObject?> get embedding =>
      _$this._embedding ??= ListBuilder<JsonObject?>();
  set embedding(ListBuilder<JsonObject?>? embedding) =>
      _$this._embedding = embedding;

  SequenceDataBuilder() {
    SequenceData._defaults(this);
  }

  SequenceDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _seqId = $v.seqId;
      _seq = $v.seq;
      _label = $v.label;
      _set_ = $v.set_;
      _mask = $v.mask;
      _attributes = $v.attributes?.toBuilder();
      _embedding = $v.embedding?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SequenceData other) {
    _$v = other as _$SequenceData;
  }

  @override
  void update(void Function(SequenceDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SequenceData build() => _build();

  _$SequenceData _build() {
    _$SequenceData _$result;
    try {
      _$result = _$v ??
          _$SequenceData._(
            seqId: BuiltValueNullFieldError.checkNotNull(
                seqId, r'SequenceData', 'seqId'),
            seq: BuiltValueNullFieldError.checkNotNull(
                seq, r'SequenceData', 'seq'),
            label: label,
            set_: set_,
            mask: mask,
            attributes: _attributes?.build(),
            embedding: _embedding?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attributes';
        _attributes?.build();
        _$failedField = 'embedding';
        _embedding?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SequenceData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
