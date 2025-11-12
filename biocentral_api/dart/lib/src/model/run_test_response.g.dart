// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_test_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunTestResponse extends RunTestResponse {
  @override
  final TestResult testResult;

  factory _$RunTestResponse([void Function(RunTestResponseBuilder)? updates]) =>
      (RunTestResponseBuilder()..update(updates))._build();

  _$RunTestResponse._({required this.testResult}) : super._();
  @override
  RunTestResponse rebuild(void Function(RunTestResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunTestResponseBuilder toBuilder() => RunTestResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunTestResponse && testResult == other.testResult;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, testResult.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunTestResponse')
          ..add('testResult', testResult))
        .toString();
  }
}

class RunTestResponseBuilder
    implements Builder<RunTestResponse, RunTestResponseBuilder> {
  _$RunTestResponse? _$v;

  TestResultBuilder? _testResult;
  TestResultBuilder get testResult =>
      _$this._testResult ??= TestResultBuilder();
  set testResult(TestResultBuilder? testResult) =>
      _$this._testResult = testResult;

  RunTestResponseBuilder() {
    RunTestResponse._defaults(this);
  }

  RunTestResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _testResult = $v.testResult.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunTestResponse other) {
    _$v = other as _$RunTestResponse;
  }

  @override
  void update(void Function(RunTestResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunTestResponse build() => _build();

  _$RunTestResponse _build() {
    _$RunTestResponse _$result;
    try {
      _$result = _$v ??
          _$RunTestResponse._(
            testResult: testResult.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'testResult';
        testResult.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RunTestResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
