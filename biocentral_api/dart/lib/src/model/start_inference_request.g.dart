// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_inference_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StartInferenceRequest extends StartInferenceRequest {
  @override
  final String modelHash;
  @override
  final BuiltMap<String, String> sequenceData;

  factory _$StartInferenceRequest(
          [void Function(StartInferenceRequestBuilder)? updates]) =>
      (StartInferenceRequestBuilder()..update(updates))._build();

  _$StartInferenceRequest._(
      {required this.modelHash, required this.sequenceData})
      : super._();
  @override
  StartInferenceRequest rebuild(
          void Function(StartInferenceRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StartInferenceRequestBuilder toBuilder() =>
      StartInferenceRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StartInferenceRequest &&
        modelHash == other.modelHash &&
        sequenceData == other.sequenceData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, modelHash.hashCode);
    _$hash = $jc(_$hash, sequenceData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StartInferenceRequest')
          ..add('modelHash', modelHash)
          ..add('sequenceData', sequenceData))
        .toString();
  }
}

class StartInferenceRequestBuilder
    implements Builder<StartInferenceRequest, StartInferenceRequestBuilder> {
  _$StartInferenceRequest? _$v;

  String? _modelHash;
  String? get modelHash => _$this._modelHash;
  set modelHash(String? modelHash) => _$this._modelHash = modelHash;

  MapBuilder<String, String>? _sequenceData;
  MapBuilder<String, String> get sequenceData =>
      _$this._sequenceData ??= MapBuilder<String, String>();
  set sequenceData(MapBuilder<String, String>? sequenceData) =>
      _$this._sequenceData = sequenceData;

  StartInferenceRequestBuilder() {
    StartInferenceRequest._defaults(this);
  }

  StartInferenceRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _modelHash = $v.modelHash;
      _sequenceData = $v.sequenceData.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StartInferenceRequest other) {
    _$v = other as _$StartInferenceRequest;
  }

  @override
  void update(void Function(StartInferenceRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StartInferenceRequest build() => _build();

  _$StartInferenceRequest _build() {
    _$StartInferenceRequest _$result;
    try {
      _$result = _$v ??
          _$StartInferenceRequest._(
            modelHash: BuiltValueNullFieldError.checkNotNull(
                modelHash, r'StartInferenceRequest', 'modelHash'),
            sequenceData: sequenceData.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sequenceData';
        sequenceData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StartInferenceRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
