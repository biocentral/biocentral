// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_dataset_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportDatasetResponse extends ImportDatasetResponse {
  @override
  final BuiltMap<String, JsonObject?> importedDataset;

  factory _$ImportDatasetResponse(
          [void Function(ImportDatasetResponseBuilder)? updates]) =>
      (ImportDatasetResponseBuilder()..update(updates))._build();

  _$ImportDatasetResponse._({required this.importedDataset}) : super._();
  @override
  ImportDatasetResponse rebuild(
          void Function(ImportDatasetResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImportDatasetResponseBuilder toBuilder() =>
      ImportDatasetResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportDatasetResponse &&
        importedDataset == other.importedDataset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, importedDataset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportDatasetResponse')
          ..add('importedDataset', importedDataset))
        .toString();
  }
}

class ImportDatasetResponseBuilder
    implements Builder<ImportDatasetResponse, ImportDatasetResponseBuilder> {
  _$ImportDatasetResponse? _$v;

  MapBuilder<String, JsonObject?>? _importedDataset;
  MapBuilder<String, JsonObject?> get importedDataset =>
      _$this._importedDataset ??= MapBuilder<String, JsonObject?>();
  set importedDataset(MapBuilder<String, JsonObject?>? importedDataset) =>
      _$this._importedDataset = importedDataset;

  ImportDatasetResponseBuilder() {
    ImportDatasetResponse._defaults(this);
  }

  ImportDatasetResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _importedDataset = $v.importedDataset.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportDatasetResponse other) {
    _$v = other as _$ImportDatasetResponse;
  }

  @override
  void update(void Function(ImportDatasetResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportDatasetResponse build() => _build();

  _$ImportDatasetResponse _build() {
    _$ImportDatasetResponse _$result;
    try {
      _$result = _$v ??
          _$ImportDatasetResponse._(
            importedDataset: importedDataset.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'importedDataset';
        importedDataset.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ImportDatasetResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
