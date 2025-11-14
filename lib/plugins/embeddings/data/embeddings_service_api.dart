import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:fpdart/fpdart.dart';

class ProtspaceConfigHandler {
  static Either<BiocentralParsingException, Map<String, List<BiocentralConfigOption>>> fromMap(
      Map<dynamic, dynamic> map) {
    final Map<String, List<BiocentralConfigOption>> result = {};
    for (final entry in map.entries) {
      final method = entry.key.toString();
      final methodOptions = entry.value;
      if (methodOptions is! List) {
        return left(
          BiocentralParsingException(
              message: 'Could not parse projection config: Method options for $method are not valid!'),
        );
      }
      result[method] = methodOptions.map((methodOption) => BiocentralConfigOption.fromMap(methodOption)).toList();
    }
    return right(result);
  }
}

class ProtspaceFileHandler {
  static Map<ProjectionData, List<Map<String, dynamic>>> parse(Map<String, dynamic> protspaceMap) {
    final Map<ProjectionData, List<Map<String, dynamic>>> result = {};

    // Parse Protein Features
    final Map<String, dynamic> proteinFeatures = protspaceMap['protein_features']?.asMap ?? {};
    final identifiers = proteinFeatures['protein_id'] as List? ?? [];

    // Parse Projections Metadata
    final metadata = protspaceMap['projections_metadata']?.asMap ?? {};
    final projNames = metadata['projection_name'] as List? ?? [];
    final dimensions = metadata['dimensions'] as List? ?? [];

    // Parse Projections Data
    final projData = protspaceMap['projections_data']?.asMap ?? {};
    final projIdentifiers = projData['identifier'] as List? ?? [];
    final xCoords = projData['x'] as List? ?? [];
    final yCoords = projData['y'] as List? ?? [];
    final zCoords = projData['z'] as List? ?? [];

    for (int i = 0; i < projNames.length; i++) {
      final projName = projNames[i];
      final dim = dimensions[i];

      final List<String> ids = [];
      final List<List<double>> coords = [];

      for (int j = 0; j < projIdentifiers.length; j++) {
        ids.add(projIdentifiers[j].toString());

        final x = xCoords[j];
        final y = yCoords[j];
        final z = zCoords[j];

        final List<double> coordinates = [];
        if (x != null) coordinates.add(x);
        if (y != null) coordinates.add(y);
        if (z != null) coordinates.add(z);

        coords.add(coordinates);
      }

      final projectionData = ProjectionData(projName, ids, coords);
      result[projectionData] = List.generate(ids.length, (i) => {"id": ids[i]});
    }
    return result;
  }

  static Map<String, dynamic> toProtSpaceMap(Map<ProjectionData, List<Map<String, dynamic>>> projectionData) {
    final Map<String, dynamic> protspaceMap = {};

    // Reconstruct protein_data
    final Map<String, dynamic> proteinData = {};
    for (final pointValues in projectionData.values) {
      for (final proteinMap in pointValues) {
        final String proteinID = proteinMap['id'] ?? '';
        if (proteinID.isNotEmpty) {
          final Map<String, dynamic> features = Map.from(proteinMap)..remove('id');
          proteinData[proteinID] = {
            'features': features, // TODO [Feature] Add actual features from entity repository
          };
        }
      }
    }
    protspaceMap['protein_data'] = proteinData;

    // Reconstruct projections
    final List<Map<String, dynamic>> projections = [];
    for (final (projection, pointValues) in projectionData.entriesRecord) {
      final List<Map<String, dynamic>> data = [];

      for (int i = 0; i < (projection.pointIDs?.length ?? 0); i++) {
        final Map<String, dynamic> coordMap = {};
        final List<double> coords = projection.coordinates[i];

        if (coords.length >= 2) {
          coordMap['x'] = coords[0].toString();
          coordMap['y'] = coords[1].toString();
          if (coords.length >= 3) {
            coordMap['z'] = coords[2].toString();
          }
        }

        data.add({
          'identifier': pointValues[i]["id"] ?? projection.pointIDs?[i],
          'coordinates': coordMap,
        });
      }

      projections.add({
        'name': projection.identifier,
        'dimensions': projection.coordinates.first.length,
        'data': data,
      });
    }
    protspaceMap['projections'] = projections;

    return protspaceMap;
  }

  static String createProtspaceHTML(Map<ProjectionData, List<Map<String, dynamic>>> projectionData) {
    final protspaceURL = 'https://protspace.onrender.com/colab';
    final protspaceMap = ProtspaceFileHandler.toProtSpaceMap(projectionData);
    final Map<String, dynamic> body = {
      'source': 'colab',
      'content': {
        'data': {
          'protein_data': protspaceMap['protein_data'],
          'projections': protspaceMap['projections'],
        }
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
