// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_dataset_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportDatasetRequest extends ImportDatasetRequest {
  @override
  final String format;
  @override
  final String dataset;

  factory _$ImportDatasetRequest(
          [void Function(ImportDatasetRequestBuilder)? updates]) =>
      (ImportDatasetRequestBuilder()..update(updates))._build();

  _$ImportDatasetRequest._({required this.format, required this.dataset})
      : super._();
  @override
  ImportDatasetRequest rebuild(
          void Function(ImportDatasetRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImportDatasetRequestBuilder toBuilder() =>
      ImportDatasetRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportDatasetRequest &&
        format == other.format &&
        dataset == other.dataset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, format.hashCode);
    _$hash = $jc(_$hash, dataset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportDatasetRequest')
          ..add('format', format)
          ..add('dataset', dataset))
        .toString();
  }
}

class ImportDatasetRequestBuilder
    implements Builder<ImportDatasetRequest, ImportDatasetRequestBuilder> {
  _$ImportDatasetRequest? _$v;

  String? _format;
  String? get format => _$this._format;
  set format(String? format) => _$this._format = format;

  String? _dataset;
  String? get dataset => _$this._dataset;
  set dataset(String? dataset) => _$this._dataset = dataset;

  ImportDatasetRequestBuilder() {
    ImportDatasetRequest._defaults(this);
  }

  ImportDatasetRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _format = $v.format;
      _dataset = $v.dataset;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportDatasetRequest other) {
    _$v = other as _$ImportDatasetRequest;
  }

  @override
  void update(void Function(ImportDatasetRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportDatasetRequest build() => _build();

  _$ImportDatasetRequest _build() {
    final _$result = _$v ??
        _$ImportDatasetRequest._(
          format: BuiltValueNullFieldError.checkNotNull(
              format, r'ImportDatasetRequest', 'format'),
          dataset: BuiltValueNullFieldError.checkNotNull(
              dataset, r'ImportDatasetRequest', 'dataset'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
