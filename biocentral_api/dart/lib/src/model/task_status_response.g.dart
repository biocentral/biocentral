// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaskStatusResponse extends TaskStatusResponse {
  @override
  final BuiltList<TaskDTO> dtos;

  factory _$TaskStatusResponse(
          [void Function(TaskStatusResponseBuilder)? updates]) =>
      (TaskStatusResponseBuilder()..update(updates))._build();

  _$TaskStatusResponse._({required this.dtos}) : super._();
  @override
  TaskStatusResponse rebuild(
          void Function(TaskStatusResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskStatusResponseBuilder toBuilder() =>
      TaskStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskStatusResponse && dtos == other.dtos;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dtos.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskStatusResponse')
          ..add('dtos', dtos))
        .toString();
  }
}

class TaskStatusResponseBuilder
    implements Builder<TaskStatusResponse, TaskStatusResponseBuilder> {
  _$TaskStatusResponse? _$v;

  ListBuilder<TaskDTO>? _dtos;
  ListBuilder<TaskDTO> get dtos => _$this._dtos ??= ListBuilder<TaskDTO>();
  set dtos(ListBuilder<TaskDTO>? dtos) => _$this._dtos = dtos;

  TaskStatusResponseBuilder() {
    TaskStatusResponse._defaults(this);
  }

  TaskStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dtos = $v.dtos.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskStatusResponse other) {
    _$v = other as _$TaskStatusResponse;
  }

  @override
  void update(void Function(TaskStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskStatusResponse build() => _build();

  _$TaskStatusResponse _build() {
    _$TaskStatusResponse _$result;
    try {
      _$result = _$v ??
          _$TaskStatusResponse._(
            dtos: dtos.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dtos';
        dtos.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TaskStatusResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
