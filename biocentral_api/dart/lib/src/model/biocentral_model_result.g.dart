// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biocentral_model_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BiocentralModelResult extends BiocentralModelResult {
  @override
  final BiotrainerModelResult modelResult;
  @override
  final String loggingFile;
  @override
  final BuiltList<BiotrainerCheckpoint> checkpoints;
  @override
  final BuiltList<BiotrainerCheckpoint>? onnxCheckpoint;

  factory _$BiocentralModelResult(
          [void Function(BiocentralModelResultBuilder)? updates]) =>
      (BiocentralModelResultBuilder()..update(updates))._build();

  _$BiocentralModelResult._(
      {required this.modelResult,
      required this.loggingFile,
      required this.checkpoints,
      this.onnxCheckpoint})
      : super._();
  @override
  BiocentralModelResult rebuild(
          void Function(BiocentralModelResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BiocentralModelResultBuilder toBuilder() =>
      BiocentralModelResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BiocentralModelResult &&
        modelResult == other.modelResult &&
        loggingFile == other.loggingFile &&
        checkpoints == other.checkpoints &&
        onnxCheckpoint == other.onnxCheckpoint;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, modelResult.hashCode);
    _$hash = $jc(_$hash, loggingFile.hashCode);
    _$hash = $jc(_$hash, checkpoints.hashCode);
    _$hash = $jc(_$hash, onnxCheckpoint.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BiocentralModelResult')
          ..add('modelResult', modelResult)
          ..add('loggingFile', loggingFile)
          ..add('checkpoints', checkpoints)
          ..add('onnxCheckpoint', onnxCheckpoint))
        .toString();
  }
}

class BiocentralModelResultBuilder
    implements Builder<BiocentralModelResult, BiocentralModelResultBuilder> {
  _$BiocentralModelResult? _$v;

  BiotrainerModelResultBuilder? _modelResult;
  BiotrainerModelResultBuilder get modelResult =>
      _$this._modelResult ??= BiotrainerModelResultBuilder();
  set modelResult(BiotrainerModelResultBuilder? modelResult) =>
      _$this._modelResult = modelResult;

  String? _loggingFile;
  String? get loggingFile => _$this._loggingFile;
  set loggingFile(String? loggingFile) => _$this._loggingFile = loggingFile;

  ListBuilder<BiotrainerCheckpoint>? _checkpoints;
  ListBuilder<BiotrainerCheckpoint> get checkpoints =>
      _$this._checkpoints ??= ListBuilder<BiotrainerCheckpoint>();
  set checkpoints(ListBuilder<BiotrainerCheckpoint>? checkpoints) =>
      _$this._checkpoints = checkpoints;

  ListBuilder<BiotrainerCheckpoint>? _onnxCheckpoint;
  ListBuilder<BiotrainerCheckpoint> get onnxCheckpoint =>
      _$this._onnxCheckpoint ??= ListBuilder<BiotrainerCheckpoint>();
  set onnxCheckpoint(ListBuilder<BiotrainerCheckpoint>? onnxCheckpoint) =>
      _$this._onnxCheckpoint = onnxCheckpoint;

  BiocentralModelResultBuilder() {
    BiocentralModelResult._defaults(this);
  }

  BiocentralModelResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _modelResult = $v.modelResult.toBuilder();
      _loggingFile = $v.loggingFile;
      _checkpoints = $v.checkpoints.toBuilder();
      _onnxCheckpoint = $v.onnxCheckpoint?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BiocentralModelResult other) {
    _$v = other as _$BiocentralModelResult;
  }

  @override
  void update(void Function(BiocentralModelResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BiocentralModelResult build() => _build();

  _$BiocentralModelResult _build() {
    _$BiocentralModelResult _$result;
    try {
      _$result = _$v ??
          _$BiocentralModelResult._(
            modelResult: modelResult.build(),
            loggingFile: BuiltValueNullFieldError.checkNotNull(
                loggingFile, r'BiocentralModelResult', 'loggingFile'),
            checkpoints: checkpoints.build(),
            onnxCheckpoint: _onnxCheckpoint?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modelResult';
        modelResult.build();

        _$failedField = 'checkpoints';
        checkpoints.build();
        _$failedField = 'onnxCheckpoint';
        _onnxCheckpoint?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BiocentralModelResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
