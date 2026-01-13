// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_embedder.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommonEmbedder _$ProtT5 = const CommonEmbedder._('ProtT5');
const CommonEmbedder _$ProstT5 = const CommonEmbedder._('ProstT5');
const CommonEmbedder _$ESM2_3B = const CommonEmbedder._('ESM2_3B');
const CommonEmbedder _$ESM2_650M = const CommonEmbedder._('ESM2_650M');
const CommonEmbedder _$ESM_8M = const CommonEmbedder._('ESM_8M');
const CommonEmbedder _$ONE_HOT_ENCODING =
    const CommonEmbedder._('ONE_HOT_ENCODING');
const CommonEmbedder _$RANDOM_EMBEDDER =
    const CommonEmbedder._('RANDOM_EMBEDDER');
const CommonEmbedder _$AAOntology = const CommonEmbedder._('AAOntology');
const CommonEmbedder _$BLOSUM62 = const CommonEmbedder._('BLOSUM62');

CommonEmbedder _$valueOf(String name) {
  switch (name) {
    case 'ProtT5':
      return _$ProtT5;
    case 'ProstT5':
      return _$ProstT5;
    case 'ESM2_3B':
      return _$ESM2_3B;
    case 'ESM2_650M':
      return _$ESM2_650M;
    case 'ESM_8M':
      return _$ESM_8M;
    case 'ONE_HOT_ENCODING':
      return _$ONE_HOT_ENCODING;
    case 'RANDOM_EMBEDDER':
      return _$RANDOM_EMBEDDER;
    case 'AAOntology':
      return _$AAOntology;
    case 'BLOSUM62':
      return _$BLOSUM62;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommonEmbedder> _$values =
    BuiltSet<CommonEmbedder>(const <CommonEmbedder>[
  _$ProtT5,
  _$ProstT5,
  _$ESM2_3B,
  _$ESM2_650M,
  _$ESM_8M,
  _$ONE_HOT_ENCODING,
  _$RANDOM_EMBEDDER,
  _$AAOntology,
  _$BLOSUM62,
]);

class _$CommonEmbedderMeta {
  const _$CommonEmbedderMeta();
  CommonEmbedder get ProtT5 => _$ProtT5;
  CommonEmbedder get ProstT5 => _$ProstT5;
  CommonEmbedder get ESM2_3B => _$ESM2_3B;
  CommonEmbedder get ESM2_650M => _$ESM2_650M;
  CommonEmbedder get ESM_8M => _$ESM_8M;
  CommonEmbedder get ONE_HOT_ENCODING => _$ONE_HOT_ENCODING;
  CommonEmbedder get RANDOM_EMBEDDER => _$RANDOM_EMBEDDER;
  CommonEmbedder get AAOntology => _$AAOntology;
  CommonEmbedder get BLOSUM62 => _$BLOSUM62;
  CommonEmbedder valueOf(String name) => _$valueOf(name);
  BuiltSet<CommonEmbedder> get values => _$values;
}

mixin _$CommonEmbedderMixin {
  // ignore: non_constant_identifier_names
  _$CommonEmbedderMeta get CommonEmbedder => const _$CommonEmbedderMeta();
}

Serializer<CommonEmbedder> _$commonEmbedderSerializer =
    _$CommonEmbedderSerializer();

class _$CommonEmbedderSerializer
    implements PrimitiveSerializer<CommonEmbedder> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ProtT5': 'Rostlab/prot_t5_xl_uniref50',
    'ProstT5': 'Rostlab/ProstT5',
    'ESM2_3B': 'facebook/esm2_t36_3B_UR50D',
    'ESM2_650M': 'facebook/esm2_t33_650M_UR50D',
    'ESM_8M': 'facebook/esm2_t6_8M_UR50D',
    'ONE_HOT_ENCODING': 'one_hot_encoding',
    'RANDOM_EMBEDDER': 'random_embedder',
    'AAOntology': 'AAOntology',
    'BLOSUM62': 'blosum62',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Rostlab/prot_t5_xl_uniref50': 'ProtT5',
    'Rostlab/ProstT5': 'ProstT5',
    'facebook/esm2_t36_3B_UR50D': 'ESM2_3B',
    'facebook/esm2_t33_650M_UR50D': 'ESM2_650M',
    'facebook/esm2_t6_8M_UR50D': 'ESM_8M',
    'one_hot_encoding': 'ONE_HOT_ENCODING',
    'random_embedder': 'RANDOM_EMBEDDER',
    'AAOntology': 'AAOntology',
    'blosum62': 'BLOSUM62',
  };

  @override
  final Iterable<Type> types = const <Type>[CommonEmbedder];
  @override
  final String wireName = 'CommonEmbedder';

  @override
  Object serialize(Serializers serializers, CommonEmbedder object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommonEmbedder deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommonEmbedder.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
