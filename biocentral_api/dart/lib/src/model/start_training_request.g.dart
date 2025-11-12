// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_training_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StartTrainingRequest extends StartTrainingRequest {
  @override
  final BuiltMap<String, JsonObject?> configDict;
  @override
  final BuiltList<SequenceTrainingData> trainingData;

  factory _$StartTrainingRequest(
          [void Function(StartTrainingRequestBuilder)? updates]) =>
      (StartTrainingRequestBuilder()..update(updates))._build();

  _$StartTrainingRequest._(
      {required this.configDict, required this.trainingData})
      : super._();
  @override
  StartTrainingRequest rebuild(
          void Function(StartTrainingRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StartTrainingRequestBuilder toBuilder() =>
      StartTrainingRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StartTrainingRequest &&
        configDict == other.configDict &&
        trainingData == other.trainingData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, configDict.hashCode);
    _$hash = $jc(_$hash, trainingData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StartTrainingRequest')
          ..add('configDict', configDict)
          ..add('trainingData', trainingData))
        .toString();
  }
}

class StartTrainingRequestBuilder
    implements Builder<StartTrainingRequest, StartTrainingRequestBuilder> {
  _$StartTrainingRequest? _$v;

  MapBuilder<String, JsonObject?>? _configDict;
  MapBuilder<String, JsonObject?> get configDict =>
      _$this._configDict ??= MapBuilder<String, JsonObject?>();
  set configDict(MapBuilder<String, JsonObject?>? configDict) =>
      _$this._configDict = configDict;

  ListBuilder<SequenceTrainingData>? _trainingData;
  ListBuilder<SequenceTrainingData> get trainingData =>
      _$this._trainingData ??= ListBuilder<SequenceTrainingData>();
  set trainingData(ListBuilder<SequenceTrainingData>? trainingData) =>
      _$this._trainingData = trainingData;

  StartTrainingRequestBuilder() {
    StartTrainingRequest._defaults(this);
  }

  StartTrainingRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configDict = $v.configDict.toBuilder();
      _trainingData = $v.trainingData.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StartTrainingRequest other) {
    _$v = other as _$StartTrainingRequest;
  }

  @override
  void update(void Function(StartTrainingRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StartTrainingRequest build() => _build();

  _$StartTrainingRequest _build() {
    _$StartTrainingRequest _$result;
    try {
      _$result = _$v ??
          _$StartTrainingRequest._(
            configDict: configDict.build(),
            trainingData: trainingData.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'configDict';
        configDict.build();
        _$failedField = 'trainingData';
        trainingData.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StartTrainingRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
