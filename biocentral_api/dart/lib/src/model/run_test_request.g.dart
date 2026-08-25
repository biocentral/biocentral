// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_test_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunTestRequest extends RunTestRequest {
  @override
  final String hash;
  @override
  final String test;

  factory _$RunTestRequest([void Function(RunTestRequestBuilder)? updates]) =>
      (RunTestRequestBuilder()..update(updates))._build();

  _$RunTestRequest._({required this.hash, required this.test}) : super._();
  @override
  RunTestRequest rebuild(void Function(RunTestRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunTestRequestBuilder toBuilder() => RunTestRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunTestRequest && hash == other.hash && test == other.test;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, hash.hashCode);
    _$hash = $jc(_$hash, test.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunTestRequest')
          ..add('hash', hash)
          ..add('test', test))
        .toString();
  }
}

class RunTestRequestBuilder
    implements Builder<RunTestRequest, RunTestRequestBuilder> {
  _$RunTestRequest? _$v;

  String? _hash;
  String? get hash => _$this._hash;
  set hash(String? hash) => _$this._hash = hash;

  String? _test;
  String? get test => _$this._test;
  set test(String? test) => _$this._test = test;

  RunTestRequestBuilder() {
    RunTestRequest._defaults(this);
  }

  RunTestRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _hash = $v.hash;
      _test = $v.test;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunTestRequest other) {
    _$v = other as _$RunTestRequest;
  }

  @override
  void update(void Function(RunTestRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunTestRequest build() => _build();

  _$RunTestRequest _build() {
    final _$result = _$v ??
        _$RunTestRequest._(
          hash: BuiltValueNullFieldError.checkNotNull(
              hash, r'RunTestRequest', 'hash'),
          test: BuiltValueNullFieldError.checkNotNull(
              test, r'RunTestRequest', 'test'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
