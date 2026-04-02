import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/embeddings/model/projection.dart';

class ProtspaceFileHandler {
  static List<Projection> parse(Map<String, dynamic> protspaceMap) {
    final List<Projection> result = [];

    // Parse Protein Features (if needed for validation)
    final proteinFeaturesRaw = protspaceMap['protein_features'];
    final Map<String, dynamic> proteinFeatures =
        proteinFeaturesRaw is Map<String, dynamic> ? proteinFeaturesRaw : (proteinFeaturesRaw?.asMap ?? {});
    final List<dynamic> proteinIds = proteinFeatures['protein_id'] ?? [];

    // Parse Projections Metadata
    final metadataRaw = protspaceMap['projections_metadata'];
    final Map<String, dynamic> metadata =
        metadataRaw is Map<String, dynamic> ? metadataRaw : (metadataRaw?.asMap ?? {});
    final List<dynamic> projNames = metadata['projection_name'] ?? [];
    final List<dynamic> dimensions = metadata['dimensions'] ?? [];
    final List<dynamic> infoJsons = metadata['info_json'] ?? [];

    // Parse Projections Data
    final projDataRaw = protspaceMap['projections_data'];
    final Map<String, dynamic> projData =
        projDataRaw is Map<String, dynamic> ? projDataRaw : (projDataRaw?.asMap ?? {});
    final List<dynamic> projectionNames = projData['projection_name'] ?? [];
    final List<dynamic> identifiers = projData['identifier'] ?? [];
    final List<dynamic> xCoords = projData['x'] ?? [];
    final List<dynamic> yCoords = projData['y'] ?? [];
    final List<dynamic> zCoords = projData['z'] ?? [];

    // Group data by unique projection names
    final Map<String, List<int>> projectionIndices = {};
    for (int i = 0; i < projectionNames.length; i++) {
      final projName = projectionNames[i].toString();
      projectionIndices.putIfAbsent(projName, () => []).add(i);
    }

    // Create Projection objects
    for (final projName in projectionIndices.keys) {
      final indices = projectionIndices[projName]!;
      final List<String> ids = [];
      final List<List<double>> coords = [];

      for (final idx in indices) {
        ids.add(identifiers[idx].toString());

        final List<double> coordinates = [];

        final x = xCoords[idx];
        final y = yCoords[idx];
        final z = zCoords[idx];

        if (x != null) coordinates.add((x is num) ? x.toDouble() : double.parse(x.toString()));
        if (y != null) coordinates.add((y is num) ? y.toDouble() : double.parse(y.toString()));
        if (z != null) coordinates.add((z is num) ? z.toDouble() : double.parse(z.toString()));

        coords.add(coordinates);
      }

      // Get metadata for this projection
      final metadataIdx = projNames.indexOf(projName);
      final Map<String, dynamic> config;
      if (metadataIdx >= 0 && metadataIdx < infoJsons.length) {
        final configRaw = infoJsons[metadataIdx];
        config = configRaw is Map<String, dynamic>
            ? configRaw
            : (jsonDecode(configRaw) as Map<String, dynamic>? ?? <String, String>{});
      } else {
        config = <String, String>{};
      }

      final projectionData = ProjectionData(projName, ids, coords);
      final projection = Projection(
          id: projName, config: config.map((k, v) => MapEntry(k.toString(), v.toString())), data: projectionData);
      result.add(projection);
    }

    return result;
  }

  static Map<String, dynamic> toProtSpaceMap({
    required List<Projection> projections,
    Map<String, Map<String, dynamic>> features = const {},
  }) {
    final Map<String, dynamic> protspaceMap = {};

    // Collect all unique protein IDs
    final Set<String> allProteinIds = {};
    for (final projection in projections) {
      allProteinIds.addAll(projection.data.pointIDs ?? []);
    }

    // Build protein_features
    protspaceMap['protein_features'] = {
      'protein_id': allProteinIds.toList(),
    };

    // Build projections_metadata
    final List<String> metadataNames = [];
    final List<int> metadataDimensions = [];
    final List<Map<String, dynamic>> metadataInfoJsons = [];

    for (final projection in projections) {
      metadataNames.add(projection.data.identifier);
      final dim = projection.data.coordinates.isNotEmpty ? projection.data.coordinates.first.length : 0;
      metadataDimensions.add(dim);
      metadataInfoJsons.add(projection.config);
    }

    protspaceMap['projections_metadata'] = {
      'projection_name': metadataNames,
      'dimensions': metadataDimensions,
      'info_json': metadataInfoJsons,
    };

    // Build projections_data (columnar format)
    final List<String> projectionNames = [];
    final List<String> identifiers = [];
    final List<double?> xCoords = [];
    final List<double?> yCoords = [];
    final List<double?> zCoords = [];

    for (final projection in projections) {
      final projName = projection.data.identifier;

      for (int i = 0; i < (projection.data.pointIDs?.length ?? 0); i++) {
        projectionNames.add(projName);
        identifiers.add(projection.data.pointIDs?[i] ?? i.toString());

        final coords = projection.data.coordinates[i];
        xCoords.add(coords.length > 0 ? coords[0] : null);
        yCoords.add(coords.length > 1 ? coords[1] : null);
        zCoords.add(coords.length > 2 ? coords[2] : null);
      }
    }

    protspaceMap['projections_data'] = {
      'projection_name': projectionNames,
      'identifier': identifiers,
      'x': xCoords,
      'y': yCoords,
      'z': zCoords,
    };

    return protspaceMap;
  }

  static String createProtspaceHTML({
    required List<Projection> projections,
    Map<String, Map<String, dynamic>> features = const {},
  }) {
    final protspaceURL = 'https://protspace.onrender.com/colab';
    final protspaceMap = ProtspaceFileHandler.toProtSpaceMap(projections: projections, features: features);
    final Map<String, dynamic> body = {
      'source': 'colab',
      'content': {
        'data': {
          'protein_data': protspaceMap['protein_features'],
          'projections': protspaceMap['projections_data'],
        },
      },
    };
    final jsonData = jsonEncode(body);

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <title>Protspace Visualization</title>
    <style>
        body, html { margin: 0; padding: 0; height: 100%; }
        iframe { border: none; width: 100%; height: 100%; }
    </style>
</head>
<body>
    <iframe id="protspaceFrame" src="$protspaceURL"></iframe>
    <script>
    (function() {
        var iframe = document.getElementById('protspaceFrame');
        var data = $jsonData;
        
        function sendData() {
            iframe.contentWindow.postMessage(data, "$protspaceURL");
        }

        // Wait for iframe to load before sending data
        iframe.onload = function() {
            // Send data immediately after load
            sendData();

            // Also set up an interval to keep trying for a short while
            var attempts = 0;
            var interval = setInterval(function() {
                attempts++;
                if (attempts >= 20) {  // Try for 10 seconds (20 * 500ms)
                    clearInterval(interval);
                }
                sendData();
            }, 500);
        };
    })();
    </script>
</body>
</html>
    ''';

    return htmlContent;
  }
}
