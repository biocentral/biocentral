// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_iteration_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningIterationResult extends ActiveLearningIterationResult {
  @override
  final int iteration;
  @override
  final BuiltList<ActiveLearningResult> results;
  @override
  final BuiltList<String> suggestions;

  factory _$ActiveLearningIterationResult(
          [void Function(ActiveLearningIterationResultBuilder)? updates]) =>
      (ActiveLearningIterationResultBuilder()..update(updates))._build();

  _$ActiveLearningIterationResult._(
      {required this.iteration,
      required this.results,
      required this.suggestions})
      : super._();
  @override
  ActiveLearningIterationResult rebuild(
          void Function(ActiveLearningIterationResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningIterationResultBuilder toBuilder() =>
      ActiveLearningIterationResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningIterationResult &&
        iteration == other.iteration &&
        results == other.results &&
        suggestions == other.suggestions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, iteration.hashCode);
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jc(_$hash, suggestions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActiveLearningIterationResult')
          ..add('iteration', iteration)
          ..add('results', results)
          ..add('suggestions', suggestions))
        .toString();
  }
}

class ActiveLearningIterationResultBuilder
    implements
        Builder<ActiveLearningIterationResult,
            ActiveLearningIterationResultBuilder> {
  _$ActiveLearningIterationResult? _$v;

  int? _iteration;
  int? get iteration => _$this._iteration;
  set iteration(int? iteration) => _$this._iteration = iteration;

  ListBuilder<ActiveLearningResult>? _results;
  ListBuilder<ActiveLearningResult> get results =>
      _$this._results ??= ListBuilder<ActiveLearningResult>();
  set results(ListBuilder<ActiveLearningResult>? results) =>
      _$this._results = results;

  ListBuilder<String>? _suggestions;
  ListBuilder<String> get suggestions =>
      _$this._suggestions ??= ListBuilder<String>();
  set suggestions(ListBuilder<String>? suggestions) =>
      _$this._suggestions = suggestions;

  ActiveLearningIterationResultBuilder() {
    ActiveLearningIterationResult._defaults(this);
  }

  ActiveLearningIterationResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _iteration = $v.iteration;
      _results = $v.results.toBuilder();
      _suggestions = $v.suggestions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningIterationResult other) {
    _$v = other as _$ActiveLearningIterationResult;
  }

  @override
  void update(void Function(ActiveLearningIterationResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningIterationResult build() => _build();

  _$ActiveLearningIterationResult _build() {
    _$ActiveLearningIterationResult _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningIterationResult._(
            iteration: BuiltValueNullFieldError.checkNotNull(
                iteration, r'ActiveLearningIterationResult', 'iteration'),
            results: results.build(),
            suggestions: suggestions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
        _$failedField = 'suggestions';
        suggestions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningIterationResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
