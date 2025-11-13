// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TaskDTO extends TaskDTO {
  @override
  final TaskStatus status;
  @override
  final String? error;
  @override
  final BuiltMap<String, BuiltList<Prediction>>? predictions;
  @override
  final OutputData? biotrainerUpdate;
  @override
  final BuiltMap<String, JsonObject?>? biotrainerResult;
  @override
  final int? embeddingCurrent;
  @override
  final int? embeddingTotal;
  @override
  final BuiltMap<String, String>? embeddedSequences;
  @override
  final BuiltList<BiotrainerSequenceRecord>? embeddings;
  @override
  final String? embeddingsFile;
  @override
  final BuiltMap<String, JsonObject?>? projectionResult;
  @override
  final String? embedderName;
  @override
  final AutoEvalProgress? autoevalProgress;
  @override
  final BuiltList<JsonObject?>? bayOptResults;

  factory _$TaskDTO([void Function(TaskDTOBuilder)? updates]) =>
      (TaskDTOBuilder()..update(updates))._build();

  _$TaskDTO._(
      {required this.status,
      this.error,
      this.predictions,
      this.biotrainerUpdate,
      this.biotrainerResult,
      this.embeddingCurrent,
      this.embeddingTotal,
      this.embeddedSequences,
      this.embeddings,
      this.embeddingsFile,
      this.projectionResult,
      this.embedderName,
      this.autoevalProgress,
      this.bayOptResults})
      : super._();
  @override
  TaskDTO rebuild(void Function(TaskDTOBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskDTOBuilder toBuilder() => TaskDTOBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskDTO &&
        status == other.status &&
        error == other.error &&
        predictions == other.predictions &&
        biotrainerUpdate == other.biotrainerUpdate &&
        biotrainerResult == other.biotrainerResult &&
        embeddingCurrent == other.embeddingCurrent &&
        embeddingTotal == other.embeddingTotal &&
        embeddedSequences == other.embeddedSequences &&
        embeddings == other.embeddings &&
        embeddingsFile == other.embeddingsFile &&
        projectionResult == other.projectionResult &&
        embedderName == other.embedderName &&
        autoevalProgress == other.autoevalProgress &&
        bayOptResults == other.bayOptResults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, predictions.hashCode);
    _$hash = $jc(_$hash, biotrainerUpdate.hashCode);
    _$hash = $jc(_$hash, biotrainerResult.hashCode);
    _$hash = $jc(_$hash, embeddingCurrent.hashCode);
    _$hash = $jc(_$hash, embeddingTotal.hashCode);
    _$hash = $jc(_$hash, embeddedSequences.hashCode);
    _$hash = $jc(_$hash, embeddings.hashCode);
    _$hash = $jc(_$hash, embeddingsFile.hashCode);
    _$hash = $jc(_$hash, projectionResult.hashCode);
    _$hash = $jc(_$hash, embedderName.hashCode);
    _$hash = $jc(_$hash, autoevalProgress.hashCode);
    _$hash = $jc(_$hash, bayOptResults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskDTO')
          ..add('status', status)
          ..add('error', error)
          ..add('predictions', predictions)
          ..add('biotrainerUpdate', biotrainerUpdate)
          ..add('biotrainerResult', biotrainerResult)
          ..add('embeddingCurrent', embeddingCurrent)
          ..add('embeddingTotal', embeddingTotal)
          ..add('embeddedSequences', embeddedSequences)
          ..add('embeddings', embeddings)
          ..add('embeddingsFile', embeddingsFile)
          ..add('projectionResult', projectionResult)
          ..add('embedderName', embedderName)
          ..add('autoevalProgress', autoevalProgress)
          ..add('bayOptResults', bayOptResults))
        .toString();
  }
}

class TaskDTOBuilder implements Builder<TaskDTO, TaskDTOBuilder> {
  _$TaskDTO? _$v;

  TaskStatus? _status;
  TaskStatus? get status => _$this._status;
  set status(TaskStatus? status) => _$this._status = status;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  MapBuilder<String, BuiltList<Prediction>>? _predictions;
  MapBuilder<String, BuiltList<Prediction>> get predictions =>
      _$this._predictions ??= MapBuilder<String, BuiltList<Prediction>>();
  set predictions(MapBuilder<String, BuiltList<Prediction>>? predictions) =>
      _$this._predictions = predictions;

  OutputDataBuilder? _biotrainerUpdate;
  OutputDataBuilder get biotrainerUpdate =>
      _$this._biotrainerUpdate ??= OutputDataBuilder();
  set biotrainerUpdate(OutputDataBuilder? biotrainerUpdate) =>
      _$this._biotrainerUpdate = biotrainerUpdate;

  MapBuilder<String, JsonObject?>? _biotrainerResult;
  MapBuilder<String, JsonObject?> get biotrainerResult =>
      _$this._biotrainerResult ??= MapBuilder<String, JsonObject?>();
  set biotrainerResult(MapBuilder<String, JsonObject?>? biotrainerResult) =>
      _$this._biotrainerResult = biotrainerResult;

  int? _embeddingCurrent;
  int? get embeddingCurrent => _$this._embeddingCurrent;
  set embeddingCurrent(int? embeddingCurrent) =>
      _$this._embeddingCurrent = embeddingCurrent;

  int? _embeddingTotal;
  int? get embeddingTotal => _$this._embeddingTotal;
  set embeddingTotal(int? embeddingTotal) =>
      _$this._embeddingTotal = embeddingTotal;

  MapBuilder<String, String>? _embeddedSequences;
  MapBuilder<String, String> get embeddedSequences =>
      _$this._embeddedSequences ??= MapBuilder<String, String>();
  set embeddedSequences(MapBuilder<String, String>? embeddedSequences) =>
      _$this._embeddedSequences = embeddedSequences;

  ListBuilder<BiotrainerSequenceRecord>? _embeddings;
  ListBuilder<BiotrainerSequenceRecord> get embeddings =>
      _$this._embeddings ??= ListBuilder<BiotrainerSequenceRecord>();
  set embeddings(ListBuilder<BiotrainerSequenceRecord>? embeddings) =>
      _$this._embeddings = embeddings;

  String? _embeddingsFile;
  String? get embeddingsFile => _$this._embeddingsFile;
  set embeddingsFile(String? embeddingsFile) =>
      _$this._embeddingsFile = embeddingsFile;

  MapBuilder<String, JsonObject?>? _projectionResult;
  MapBuilder<String, JsonObject?> get projectionResult =>
      _$this._projectionResult ??= MapBuilder<String, JsonObject?>();
  set projectionResult(MapBuilder<String, JsonObject?>? projectionResult) =>
      _$this._projectionResult = projectionResult;

  String? _embedderName;
  String? get embedderName => _$this._embedderName;
  set embedderName(String? embedderName) => _$this._embedderName = embedderName;

  AutoEvalProgressBuilder? _autoevalProgress;
  AutoEvalProgressBuilder get autoevalProgress =>
      _$this._autoevalProgress ??= AutoEvalProgressBuilder();
  set autoevalProgress(AutoEvalProgressBuilder? autoevalProgress) =>
      _$this._autoevalProgress = autoevalProgress;

  ListBuilder<JsonObject?>? _bayOptResults;
  ListBuilder<JsonObject?> get bayOptResults =>
      _$this._bayOptResults ??= ListBuilder<JsonObject?>();
  set bayOptResults(ListBuilder<JsonObject?>? bayOptResults) =>
      _$this._bayOptResults = bayOptResults;

  TaskDTOBuilder() {
    TaskDTO._defaults(this);
  }

  TaskDTOBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _error = $v.error;
      _predictions = $v.predictions?.toBuilder();
      _biotrainerUpdate = $v.biotrainerUpdate?.toBuilder();
      _biotrainerResult = $v.biotrainerResult?.toBuilder();
      _embeddingCurrent = $v.embeddingCurrent;
      _embeddingTotal = $v.embeddingTotal;
      _embeddedSequences = $v.embeddedSequences?.toBuilder();
      _embeddings = $v.embeddings?.toBuilder();
      _embeddingsFile = $v.embeddingsFile;
      _projectionResult = $v.projectionResult?.toBuilder();
      _embedderName = $v.embedderName;
      _autoevalProgress = $v.autoevalProgress?.toBuilder();
      _bayOptResults = $v.bayOptResults?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskDTO other) {
    _$v = other as _$TaskDTO;
  }

  @override
  void update(void Function(TaskDTOBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskDTO build() => _build();

  _$TaskDTO _build() {
    _$TaskDTO _$result;
    try {
      _$result = _$v ??
          _$TaskDTO._(
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'TaskDTO', 'status'),
            error: error,
            predictions: _predictions?.build(),
            biotrainerUpdate: _biotrainerUpdate?.build(),
            biotrainerResult: _biotrainerResult?.build(),
            embeddingCurrent: embeddingCurrent,
            embeddingTotal: embeddingTotal,
            embeddedSequences: _embeddedSequences?.build(),
            embeddings: _embeddings?.build(),
            embeddingsFile: embeddingsFile,
            projectionResult: _projectionResult?.build(),
            embedderName: embedderName,
            autoevalProgress: _autoevalProgress?.build(),
            bayOptResults: _bayOptResults?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'predictions';
        _predictions?.build();
        _$failedField = 'biotrainerUpdate';
        _biotrainerUpdate?.build();
        _$failedField = 'biotrainerResult';
        _biotrainerResult?.build();

        _$failedField = 'embeddedSequences';
        _embeddedSequences?.build();
        _$failedField = 'embeddings';
        _embeddings?.build();

        _$failedField = 'projectionResult';
        _projectionResult?.build();

        _$failedField = 'autoevalProgress';
        _autoevalProgress?.build();
        _$failedField = 'bayOptResults';
        _bayOptResults?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TaskDTO', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
