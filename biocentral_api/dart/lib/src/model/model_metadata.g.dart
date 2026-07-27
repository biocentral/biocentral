// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_metadata.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModelMetadata extends ModelMetadata {
  @override
  final BiocentralPredictionModel name;
  @override
  final Protocol protocol;
  @override
  final String description;
  @override
  final String authors;
  @override
  final String modelLink;
  @override
  final String citation;
  @override
  final String licence;
  @override
  final BuiltList<ModelOutput> outputs;
  @override
  final String modelSize;
  @override
  final String embedder;
  @override
  final String? trainingDataLink;

  factory _$ModelMetadata([void Function(ModelMetadataBuilder)? updates]) =>
      (ModelMetadataBuilder()..update(updates))._build();

  _$ModelMetadata._(
      {required this.name,
      required this.protocol,
      required this.description,
      required this.authors,
      required this.modelLink,
      required this.citation,
      required this.licence,
      required this.outputs,
      required this.modelSize,
      required this.embedder,
      this.trainingDataLink})
      : super._();
  @override
  ModelMetadata rebuild(void Function(ModelMetadataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModelMetadataBuilder toBuilder() => ModelMetadataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModelMetadata &&
        name == other.name &&
        protocol == other.protocol &&
        description == other.description &&
        authors == other.authors &&
        modelLink == other.modelLink &&
        citation == other.citation &&
        licence == other.licence &&
        outputs == other.outputs &&
        modelSize == other.modelSize &&
        embedder == other.embedder &&
        trainingDataLink == other.trainingDataLink;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, protocol.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, authors.hashCode);
    _$hash = $jc(_$hash, modelLink.hashCode);
    _$hash = $jc(_$hash, citation.hashCode);
    _$hash = $jc(_$hash, licence.hashCode);
    _$hash = $jc(_$hash, outputs.hashCode);
    _$hash = $jc(_$hash, modelSize.hashCode);
    _$hash = $jc(_$hash, embedder.hashCode);
    _$hash = $jc(_$hash, trainingDataLink.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModelMetadata')
          ..add('name', name)
          ..add('protocol', protocol)
          ..add('description', description)
          ..add('authors', authors)
          ..add('modelLink', modelLink)
          ..add('citation', citation)
          ..add('licence', licence)
          ..add('outputs', outputs)
          ..add('modelSize', modelSize)
          ..add('embedder', embedder)
          ..add('trainingDataLink', trainingDataLink))
        .toString();
  }
}

class ModelMetadataBuilder
    implements Builder<ModelMetadata, ModelMetadataBuilder> {
  _$ModelMetadata? _$v;

  BiocentralPredictionModel? _name;
  BiocentralPredictionModel? get name => _$this._name;
  set name(BiocentralPredictionModel? name) => _$this._name = name;

  Protocol? _protocol;
  Protocol? get protocol => _$this._protocol;
  set protocol(Protocol? protocol) => _$this._protocol = protocol;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _authors;
  String? get authors => _$this._authors;
  set authors(String? authors) => _$this._authors = authors;

  String? _modelLink;
  String? get modelLink => _$this._modelLink;
  set modelLink(String? modelLink) => _$this._modelLink = modelLink;

  String? _citation;
  String? get citation => _$this._citation;
  set citation(String? citation) => _$this._citation = citation;

  String? _licence;
  String? get licence => _$this._licence;
  set licence(String? licence) => _$this._licence = licence;

  ListBuilder<ModelOutput>? _outputs;
  ListBuilder<ModelOutput> get outputs =>
      _$this._outputs ??= ListBuilder<ModelOutput>();
  set outputs(ListBuilder<ModelOutput>? outputs) => _$this._outputs = outputs;

  String? _modelSize;
  String? get modelSize => _$this._modelSize;
  set modelSize(String? modelSize) => _$this._modelSize = modelSize;

  String? _embedder;
  String? get embedder => _$this._embedder;
  set embedder(String? embedder) => _$this._embedder = embedder;

  String? _trainingDataLink;
  String? get trainingDataLink => _$this._trainingDataLink;
  set trainingDataLink(String? trainingDataLink) =>
      _$this._trainingDataLink = trainingDataLink;

  ModelMetadataBuilder() {
    ModelMetadata._defaults(this);
  }

  ModelMetadataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _protocol = $v.protocol;
      _description = $v.description;
      _authors = $v.authors;
      _modelLink = $v.modelLink;
      _citation = $v.citation;
      _licence = $v.licence;
      _outputs = $v.outputs.toBuilder();
      _modelSize = $v.modelSize;
      _embedder = $v.embedder;
      _trainingDataLink = $v.trainingDataLink;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModelMetadata other) {
    _$v = other as _$ModelMetadata;
  }

  @override
  void update(void Function(ModelMetadataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModelMetadata build() => _build();

  _$ModelMetadata _build() {
    _$ModelMetadata _$result;
    try {
      _$result = _$v ??
          _$ModelMetadata._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ModelMetadata', 'name'),
            protocol: BuiltValueNullFieldError.checkNotNull(
                protocol, r'ModelMetadata', 'protocol'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'ModelMetadata', 'description'),
            authors: BuiltValueNullFieldError.checkNotNull(
                authors, r'ModelMetadata', 'authors'),
            modelLink: BuiltValueNullFieldError.checkNotNull(
                modelLink, r'ModelMetadata', 'modelLink'),
            citation: BuiltValueNullFieldError.checkNotNull(
                citation, r'ModelMetadata', 'citation'),
            licence: BuiltValueNullFieldError.checkNotNull(
                licence, r'ModelMetadata', 'licence'),
            outputs: outputs.build(),
            modelSize: BuiltValueNullFieldError.checkNotNull(
                modelSize, r'ModelMetadata', 'modelSize'),
            embedder: BuiltValueNullFieldError.checkNotNull(
                embedder, r'ModelMetadata', 'embedder'),
            trainingDataLink: trainingDataLink,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'outputs';
        outputs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ModelMetadata', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
