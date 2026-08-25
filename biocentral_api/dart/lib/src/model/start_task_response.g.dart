// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_task_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StartTaskResponse extends StartTaskResponse {
  @override
  final String taskId;

  factory _$StartTaskResponse(
          [void Function(StartTaskResponseBuilder)? updates]) =>
      (StartTaskResponseBuilder()..update(updates))._build();

  _$StartTaskResponse._({required this.taskId}) : super._();
  @override
  StartTaskResponse rebuild(void Function(StartTaskResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StartTaskResponseBuilder toBuilder() =>
      StartTaskResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StartTaskResponse && taskId == other.taskId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StartTaskResponse')
          ..add('taskId', taskId))
        .toString();
  }
}

class StartTaskResponseBuilder
    implements Builder<StartTaskResponse, StartTaskResponseBuilder> {
  _$StartTaskResponse? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  StartTaskResponseBuilder() {
    StartTaskResponse._defaults(this);
  }

  StartTaskResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StartTaskResponse other) {
    _$v = other as _$StartTaskResponse;
  }

  @override
  void update(void Function(StartTaskResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StartTaskResponse build() => _build();

  _$StartTaskResponse _build() {
    final _$result = _$v ??
        _$StartTaskResponse._(
          taskId: BuiltValueNullFieldError.checkNotNull(
              taskId, r'StartTaskResponse', 'taskId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
