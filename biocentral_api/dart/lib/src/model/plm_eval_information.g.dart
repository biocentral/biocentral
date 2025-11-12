// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plm_eval_information.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PLMEvalInformation extends PLMEvalInformation {
  @override
  final int nTasks;
  @override
  final BuiltList<PLMEvalTaskInformation> tasks;

  factory _$PLMEvalInformation(
          [void Function(PLMEvalInformationBuilder)? updates]) =>
      (PLMEvalInformationBuilder()..update(updates))._build();

  _$PLMEvalInformation._({required this.nTasks, required this.tasks})
      : super._();
  @override
  PLMEvalInformation rebuild(
          void Function(PLMEvalInformationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PLMEvalInformationBuilder toBuilder() =>
      PLMEvalInformationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PLMEvalInformation &&
        nTasks == other.nTasks &&
        tasks == other.tasks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nTasks.hashCode);
    _$hash = $jc(_$hash, tasks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PLMEvalInformation')
          ..add('nTasks', nTasks)
          ..add('tasks', tasks))
        .toString();
  }
}

class PLMEvalInformationBuilder
    implements Builder<PLMEvalInformation, PLMEvalInformationBuilder> {
  _$PLMEvalInformation? _$v;

  int? _nTasks;
  int? get nTasks => _$this._nTasks;
  set nTasks(int? nTasks) => _$this._nTasks = nTasks;

  ListBuilder<PLMEvalTaskInformation>? _tasks;
  ListBuilder<PLMEvalTaskInformation> get tasks =>
      _$this._tasks ??= ListBuilder<PLMEvalTaskInformation>();
  set tasks(ListBuilder<PLMEvalTaskInformation>? tasks) =>
      _$this._tasks = tasks;

  PLMEvalInformationBuilder() {
    PLMEvalInformation._defaults(this);
  }

  PLMEvalInformationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nTasks = $v.nTasks;
      _tasks = $v.tasks.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PLMEvalInformation other) {
    _$v = other as _$PLMEvalInformation;
  }

  @override
  void update(void Function(PLMEvalInformationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PLMEvalInformation build() => _build();

  _$PLMEvalInformation _build() {
    _$PLMEvalInformation _$result;
    try {
      _$result = _$v ??
          _$PLMEvalInformation._(
            nTasks: BuiltValueNullFieldError.checkNotNull(
                nTasks, r'PLMEvalInformation', 'nTasks'),
            tasks: tasks.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tasks';
        tasks.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PLMEvalInformation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
