// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perplexity_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PerplexityRequest extends PerplexityRequest {
  @override
  final BuiltMap<String, String> sequenceData;
  @override
  final String plmName;

  factory _$PerplexityRequest(
          [void Function(PerplexityRequestBuilder)? updates]) =>
      (PerplexityRequestBuilder()..update(updates))._build();

  _$PerplexityRequest._({required this.sequenceData, required this.plmName})
      : super._();
  @override
  PerplexityRequest rebuild(void Function(PerplexityRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PerplexityRequestBuilder toBuilder() =>
      PerplexityRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PerplexityRequest &&
        sequenceData == other.sequenceData &&
        plmName == other.plmName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sequenceData.hashCode);
    _$hash = $jc(_$hash, plmName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PerplexityRequest')
          ..add('sequenceData', sequenceData)
          ..add('plmName', plmName))
        .toString();
  }
}

class PerplexityRequestBuilder
    implements Builder<PerplexityRequest, PerplexityRequestBuilder> {
  _$PerplexityRequest? _$v;

  MapBuilder<String, String>? _sequenceData;
  MapBuilder<String, String> get sequenceData =>
      _$this._sequenceData ??= MapBuilder<String, String>();
  set sequenceData(MapBuilder<String, String>? sequenceData) =>
      _$this._sequenceData = sequenceData;

  String? _plmName;
  String? get plmName => _$this._plmName;
  set plmName(String? plmName) => _$this._plmName = plmName;

  PerplexityRequestBuilder() {
    PerplexityRequest._defaults(this);
  }

  PerplexityRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sequenceData = $v.sequenceData.toBuilder();
      _plmName = $v.plmName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PerplexityRequest other) {
    _$v = other as _$PerplexityRequest;
  }

  @override
  void update(void Function(PerplexityRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PerplexityRequest build() => _build();

  _$PerplexityRequest _build() {
    _$PerplexityRequest _$result;
    try {
      _$result = _$v ??
          _$PerplexityRequest._(
            sequenceData: sequenceData.build(),
            plmName: BuiltValueNullFieldError.checkNotNull(
                plmName, r'PerplexityRequest', 'plmName'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sequenceData';
        sequenceData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PerplexityRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
