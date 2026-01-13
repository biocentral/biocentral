//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'common_embedder.g.dart';

class CommonEmbedder extends EnumClass {

  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'Rostlab/prot_t5_xl_uniref50')
  static const CommonEmbedder ProtT5 = _$ProtT5;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'Rostlab/ProstT5')
  static const CommonEmbedder ProstT5 = _$ProstT5;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'facebook/esm2_t36_3B_UR50D')
  static const CommonEmbedder ESM2_3B = _$ESM2_3B;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'facebook/esm2_t33_650M_UR50D')
  static const CommonEmbedder ESM2_650M = _$ESM2_650M;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'facebook/esm2_t6_8M_UR50D')
  static const CommonEmbedder ESM_8M = _$ESM_8M;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'one_hot_encoding')
  static const CommonEmbedder ONE_HOT_ENCODING = _$ONE_HOT_ENCODING;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'random_embedder')
  static const CommonEmbedder RANDOM_EMBEDDER = _$RANDOM_EMBEDDER;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'AAOntology')
  static const CommonEmbedder AAOntology = _$AAOntology;
  /// Common embedder model names
  @BuiltValueEnumConst(wireName: r'blosum62')
  static const CommonEmbedder BLOSUM62 = _$BLOSUM62;

  static Serializer<CommonEmbedder> get serializer => _$commonEmbedderSerializer;

  const CommonEmbedder._(String name): super(name);

  static BuiltSet<CommonEmbedder> get values => _$values;
  static CommonEmbedder valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CommonEmbedderMixin = Object with _$CommonEmbedderMixin;

