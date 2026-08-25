//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'active_learning_optimization_mode.g.dart';

class ActiveLearningOptimizationMode extends EnumClass {

  @BuiltValueEnumConst(wireName: r'INTERVAL')
  static const ActiveLearningOptimizationMode INTERVAL = _$INTERVAL;
  @BuiltValueEnumConst(wireName: r'VALUE')
  static const ActiveLearningOptimizationMode VALUE = _$VALUE;
  @BuiltValueEnumConst(wireName: r'MAXIMIZE')
  static const ActiveLearningOptimizationMode MAXIMIZE = _$MAXIMIZE;
  @BuiltValueEnumConst(wireName: r'MINIMIZE')
  static const ActiveLearningOptimizationMode MINIMIZE = _$MINIMIZE;
  @BuiltValueEnumConst(wireName: r'DISCRETE')
  static const ActiveLearningOptimizationMode DISCRETE = _$DISCRETE;

  static Serializer<ActiveLearningOptimizationMode> get serializer => _$activeLearningOptimizationModeSerializer;

  const ActiveLearningOptimizationMode._(String name): super(name);

  static BuiltSet<ActiveLearningOptimizationMode> get values => _$values;
  static ActiveLearningOptimizationMode valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ActiveLearningOptimizationModeMixin = Object with _$ActiveLearningOptimizationModeMixin;

