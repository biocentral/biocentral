import 'package:bio_flutter/bio_flutter.dart';

class Projection {
  final String id;  // TODO Might not be necessary (ProjectionData also has ID)
  final Map<String, String> config;
  final ProjectionData data;

  Projection({required this.id, required this.config, required this.data});

  factory Projection.deserialize(Map<String, dynamic> jsonMap) {
    final id = jsonMap['id'];
    final config = Map<String, String>.from(jsonMap['config'] ?? {});
    final dataMap = jsonMap['data'] ?? {};
    final data = ProjectionDataSerialization.deserialize(dataMap);

    return Projection(id: id, config: config, data: data);
  }

  Map<String, dynamic> serialize() {
    return {
      'id': id,
      'config': config,
      'data': data.serialize(),
    };
  }
}

// TODO Move to bio_flutter
extension ProjectionDataSerialization on ProjectionData {
  Map<String, dynamic> serialize() {
    return {
      'identifier': identifier,
      'coordinates': coordinates,
      'pointIDs': pointIDs,
    };
  }

  static ProjectionData deserialize(Map<String, dynamic> jsonMap) {
    final identifier = jsonMap['identifier'] as String;
    final pointIDs = jsonMap['pointIDs'] != null ? List<String>.from(jsonMap['pointIDs'] as List) : null;
    final coordinates = (jsonMap['coordinates'] as List).map((coord) => List<double>.from(coord as List)).toList();

    return ProjectionData(identifier, pointIDs, coordinates);
  }
}
