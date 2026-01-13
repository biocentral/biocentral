// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PredictionRequest extends PredictionRequest {
  @override
  final BuiltList<BiocentralPredictionModel> modelNames;
  @override
  final BuiltMap<String, String> sequenceInput;

  factory _$PredictionRequest(
          [void Function(PredictionRequestBuilder)? updates]) =>
      (PredictionRequestBuilder()..update(updates))._build();

  _$PredictionRequest._({required this.modelNames, required this.sequenceInput})
      : super._();
  @override
  PredictionRequest rebuild(void Function(PredictionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PredictionRequestBuilder toBuilder() =>
      PredictionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PredictionRequest &&
        modelNames == other.modelNames &&
        sequenceInput == other.sequenceInput;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, modelNames.hashCode);
    _$hash = $jc(_$hash, sequenceInput.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PredictionRequest')
          ..add('modelNames', modelNames)
          ..add('sequenceInput', sequenceInput))
        .toString();
  }
}

class PredictionRequestBuilder
    implements Builder<PredictionRequest, PredictionRequestBuilder> {
  _$PredictionRequest? _$v;

  ListBuilder<BiocentralPredictionModel>? _modelNames;
  ListBuilder<BiocentralPredictionModel> get modelNames =>
      _$this._modelNames ??= ListBuilder<BiocentralPredictionModel>();
  set modelNames(ListBuilder<BiocentralPredictionModel>? modelNames) =>
      _$this._modelNames = modelNames;

  MapBuilder<String, String>? _sequenceInput;
  MapBuilder<String, String> get sequenceInput =>
      _$this._sequenceInput ??= MapBuilder<String, String>();
  set sequenceInput(MapBuilder<String, String>? sequenceInput) =>
      _$this._sequenceInput = sequenceInput;

  PredictionRequestBuilder() {
    PredictionRequest._defaults(this);
  }

  PredictionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _modelNames = $v.modelNames.toBuilder();
      _sequenceInput = $v.sequenceInput.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PredictionRequest other) {
    _$v = other as _$PredictionRequest;
  }

  @override
  void update(void Function(PredictionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PredictionRequest build() => _build();

  _$PredictionRequest _build() {
    _$PredictionRequest _$result;
    try {
      _$result = _$v ??
          _$PredictionRequest._(
            modelNames: modelNames.build(),
            sequenceInput: sequenceInput.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modelNames';
        modelNames.build();
        _$failedField = 'sequenceInput';
        sequenceInput.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PredictionRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
