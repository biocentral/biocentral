// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biotrainer_sequence_record.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiotrainerSequenceRecord extends BiotrainerSequenceRecord {
  @override
  final String seqId;
  @override
  final String seq;
  @override
  final BuiltMap<String, JsonObject?>? attributes;
  @override
  final BuiltMap<dynamic, dynamic>? embedding;

  factory _$BiotrainerSequenceRecord(
          [void Function(BiotrainerSequenceRecordBuilder)? updates]) =>
      (BiotrainerSequenceRecordBuilder()..update(updates))._build();

  _$BiotrainerSequenceRecord._(
      {required this.seqId, required this.seq, this.attributes, this.embedding})
      : super._();
  @override
  BiotrainerSequenceRecord rebuild(
          void Function(BiotrainerSequenceRecordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiotrainerSequenceRecordBuilder toBuilder() =>
      BiotrainerSequenceRecordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiotrainerSequenceRecord &&
        seqId == other.seqId &&
        seq == other.seq &&
        attributes == other.attributes &&
        embedding == other.embedding;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, seqId.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, attributes.hashCode);
    _$hash = $jc(_$hash, embedding.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiotrainerSequenceRecord')
          ..add('seqId', seqId)
          ..add('seq', seq)
          ..add('attributes', attributes)
          ..add('embedding', embedding))
        .toString();
  }
}

class BiotrainerSequenceRecordBuilder
    implements
        Builder<BiotrainerSequenceRecord, BiotrainerSequenceRecordBuilder> {
  _$BiotrainerSequenceRecord? _$v;

  String? _seqId;
  String? get seqId => _$this._seqId;
  set seqId(String? seqId) => _$this._seqId = seqId;

  String? _seq;
  String? get seq => _$this._seq;
  set seq(String? seq) => _$this._seq = seq;

  MapBuilder<String, JsonObject?>? _attributes;
  MapBuilder<String, JsonObject?> get attributes =>
      _$this._attributes ??= MapBuilder<String, JsonObject?>();
  set attributes(MapBuilder<String, JsonObject?>? attributes) =>
      _$this._attributes = attributes;

  MapBuilder<dynamic, dynamic>? _embedding;
  MapBuilder<dynamic, dynamic> get embedding =>
      _$this._embedding ??= MapBuilder<dynamic, dynamic>();
  set embedding(MapBuilder<dynamic, dynamic>? embedding) =>
      _$this._embedding = embedding;

  BiotrainerSequenceRecordBuilder() {
    BiotrainerSequenceRecord._defaults(this);
  }

  BiotrainerSequenceRecordBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _seqId = $v.seqId;
      _seq = $v.seq;
      _attributes = $v.attributes?.toBuilder();
      _embedding = $v.embedding?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiotrainerSequenceRecord other) {
    _$v = other as _$BiotrainerSequenceRecord;
  }

  @override
  void update(void Function(BiotrainerSequenceRecordBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiotrainerSequenceRecord build() => _build();

  _$BiotrainerSequenceRecord _build() {
    _$BiotrainerSequenceRecord _$result;
    try {
      _$result = _$v ??
          _$BiotrainerSequenceRecord._(
            seqId: BuiltValueNullFieldError.checkNotNull(
                seqId, r'BiotrainerSequenceRecord', 'seqId'),
            seq: BuiltValueNullFieldError.checkNotNull(
                seq, r'BiotrainerSequenceRecord', 'seq'),
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
            r'BiotrainerSequenceRecord', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
