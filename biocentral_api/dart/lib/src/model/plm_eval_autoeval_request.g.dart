// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plm_eval_autoeval_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PLMEvalAutoevalRequest extends PLMEvalAutoevalRequest {
  @override
  final String modelId;
  @override
  final String? onnxFile;
  @override
  final String? tokenizerConfig;

  factory _$PLMEvalAutoevalRequest(
          [void Function(PLMEvalAutoevalRequestBuilder)? updates]) =>
      (PLMEvalAutoevalRequestBuilder()..update(updates))._build();

  _$PLMEvalAutoevalRequest._(
      {required this.modelId, this.onnxFile, this.tokenizerConfig})
      : super._();
  @override
  PLMEvalAutoevalRequest rebuild(
          void Function(PLMEvalAutoevalRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PLMEvalAutoevalRequestBuilder toBuilder() =>
      PLMEvalAutoevalRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PLMEvalAutoevalRequest &&
        modelId == other.modelId &&
        onnxFile == other.onnxFile &&
        tokenizerConfig == other.tokenizerConfig;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, modelId.hashCode);
    _$hash = $jc(_$hash, onnxFile.hashCode);
    _$hash = $jc(_$hash, tokenizerConfig.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PLMEvalAutoevalRequest')
          ..add('modelId', modelId)
          ..add('onnxFile', onnxFile)
          ..add('tokenizerConfig', tokenizerConfig))
        .toString();
  }
}

class PLMEvalAutoevalRequestBuilder
    implements Builder<PLMEvalAutoevalRequest, PLMEvalAutoevalRequestBuilder> {
  _$PLMEvalAutoevalRequest? _$v;

  String? _modelId;
  String? get modelId => _$this._modelId;
  set modelId(String? modelId) => _$this._modelId = modelId;

  String? _onnxFile;
  String? get onnxFile => _$this._onnxFile;
  set onnxFile(String? onnxFile) => _$this._onnxFile = onnxFile;

  String? _tokenizerConfig;
  String? get tokenizerConfig => _$this._tokenizerConfig;
  set tokenizerConfig(String? tokenizerConfig) =>
      _$this._tokenizerConfig = tokenizerConfig;

  PLMEvalAutoevalRequestBuilder() {
    PLMEvalAutoevalRequest._defaults(this);
  }

  PLMEvalAutoevalRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _modelId = $v.modelId;
      _onnxFile = $v.onnxFile;
      _tokenizerConfig = $v.tokenizerConfig;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PLMEvalAutoevalRequest other) {
    _$v = other as _$PLMEvalAutoevalRequest;
  }

  @override
  void update(void Function(PLMEvalAutoevalRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PLMEvalAutoevalRequest build() => _build();

  _$PLMEvalAutoevalRequest _build() {
    final _$result = _$v ??
        _$PLMEvalAutoevalRequest._(
          modelId: BuiltValueNullFieldError.checkNotNull(
              modelId, r'PLMEvalAutoevalRequest', 'modelId'),
          onnxFile: onnxFile,
          tokenizerConfig: tokenizerConfig,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
