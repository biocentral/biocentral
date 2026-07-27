//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'biocentral_service_stats.g.dart';

/// BiocentralServiceStats
///
/// Properties:
/// * [usableCpuCount] - Number of usable CPU cores available to the process
/// * [embeddingsDatabaseSize] - Current size of the embeddings database in bytes
/// * [totalTasks] - Total number of tasks submitted since server startup
/// * [queueLength] - Current number of tasks queued for execution
/// * [cudaAvailable] - Whether CUDA GPU acceleration is available
/// * [cudaDeviceNames] - List of names of available CUDA devices
/// * [cudaDeviceCount] - Number of available CUDA devices
@BuiltValue()
abstract class BiocentralServiceStats implements Built<BiocentralServiceStats, BiocentralServiceStatsBuilder> {
  /// Number of usable CPU cores available to the process
  @BuiltValueField(wireName: r'usable_cpu_count')
  int get usableCpuCount;

  /// Current size of the embeddings database in bytes
  @BuiltValueField(wireName: r'embeddings_database_size')
  int get embeddingsDatabaseSize;

  /// Total number of tasks submitted since server startup
  @BuiltValueField(wireName: r'total_tasks')
  int get totalTasks;

  /// Current number of tasks queued for execution
  @BuiltValueField(wireName: r'queue_length')
  int get queueLength;

  /// Whether CUDA GPU acceleration is available
  @BuiltValueField(wireName: r'cuda_available')
  bool get cudaAvailable;

  /// List of names of available CUDA devices
  @BuiltValueField(wireName: r'cuda_device_names')
  BuiltList<String> get cudaDeviceNames;

  /// Number of available CUDA devices
  @BuiltValueField(wireName: r'cuda_device_count')
  int get cudaDeviceCount;

  BiocentralServiceStats._();

  factory BiocentralServiceStats([void updates(BiocentralServiceStatsBuilder b)]) = _$BiocentralServiceStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BiocentralServiceStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BiocentralServiceStats> get serializer => _$BiocentralServiceStatsSerializer();
}

class _$BiocentralServiceStatsSerializer implements PrimitiveSerializer<BiocentralServiceStats> {
  @override
  final Iterable<Type> types = const [BiocentralServiceStats, _$BiocentralServiceStats];

  @override
  final String wireName = r'BiocentralServiceStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BiocentralServiceStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'usable_cpu_count';
    yield serializers.serialize(
      object.usableCpuCount,
      specifiedType: const FullType(int),
    );
    yield r'embeddings_database_size';
    yield serializers.serialize(
      object.embeddingsDatabaseSize,
      specifiedType: const FullType(int),
    );
    yield r'total_tasks';
    yield serializers.serialize(
      object.totalTasks,
      specifiedType: const FullType(int),
    );
    yield r'queue_length';
    yield serializers.serialize(
      object.queueLength,
      specifiedType: const FullType(int),
    );
    yield r'cuda_available';
    yield serializers.serialize(
      object.cudaAvailable,
      specifiedType: const FullType(bool),
    );
    yield r'cuda_device_names';
    yield serializers.serialize(
      object.cudaDeviceNames,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'cuda_device_count';
    yield serializers.serialize(
      object.cudaDeviceCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BiocentralServiceStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BiocentralServiceStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'usable_cpu_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.usableCpuCount = valueDes;
          break;
        case r'embeddings_database_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.embeddingsDatabaseSize = valueDes;
          break;
        case r'total_tasks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalTasks = valueDes;
          break;
        case r'queue_length':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.queueLength = valueDes;
          break;
        case r'cuda_available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.cudaAvailable = valueDes;
          break;
        case r'cuda_device_names':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.cudaDeviceNames.replace(valueDes);
          break;
        case r'cuda_device_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cudaDeviceCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BiocentralServiceStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BiocentralServiceStatsBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

