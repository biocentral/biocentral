//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_model_type.g.dart';

class ActiveLearningModelType extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GAUSSIAN_PROCESS')
  static const ActiveLearningModelType GAUSSIAN_PROCESS = _$GAUSSIAN_PROCESS;
  @BuiltValueEnumConst(wireName: r'FNN_MCD')
  static const ActiveLearningModelType FNN_MCD = _$FNN_MCD;
  @BuiltValueEnumConst(wireName: r'RANDOM')
  static const ActiveLearningModelType RANDOM = _$RANDOM;

  static Serializer<ActiveLearningModelType> get serializer => _$activeLearningModelTypeSerializer;

  const ActiveLearningModelType._(String name): super(name);

  static BuiltSet<ActiveLearningModelType> get values => _$values;
  static ActiveLearningModelType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ActiveLearningModelTypeMixin = Object with _$ActiveLearningModelTypeMixin;

