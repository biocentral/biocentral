import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';

class EmbeddingsServiceEndpoints {
  static const String embedding = '/embeddings_service/embed';
  static const String getMissingEmbeddings = '/embeddings_service/get_missing_embeddings';
  static const String addEmbeddings = '/embeddings_service/add_embeddings';
  static const String projectionForSequences = '/embeddings_service/projection_for_sequences';
}

class ProtspaceFileHandler {
  static Map<ProjectionData, List<Map<String, dynamic>>> parse(String jsonFile) {
    final Map<ProjectionData, List<Map<String, dynamic>>> result = {};
    final Map<String, dynamic> protspaceMap = jsonDecode(jsonFile);

    // Parse Protein Features
    final Map<String, dynamic> proteinData = protspaceMap['protein_data'] ?? {};
    final Map<String, Map<String, String>> parsedProteinData = {};
    for (final entry in proteinData.entries) {
      final proteinID = entry.key;
      final Map<String, dynamic> featureMap = entry.value['features'] ?? {};
      if (featureMap.isEmpty) {
        parsedProteinData[proteinID] = {};
        continue;
      }

      final parsedFeatureMap = Map<String, dynamic>.fromIterable(
        featureMap.entries.map((feature) => MapEntry(feature.key.toString(), feature.value.toString())).toList(),
      );
      parsedFeatureMap['id'] = proteinID;
      parsedProteinData[proteinID] = parsedFeatureMap.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    // Parse Projections
    for (final projection in protspaceMap['projections'] ?? []) {
      final projectionID = projection?['name'] ?? 'UnknownProjectionID';

      final data = List<Map>.from(projection?['data'] ?? {});

      if (data.isEmpty) {
        break;
      }

      final List<String> ids = [];
      final List<List<double>> allCoordinates = [];
      for (final map in data) {
        final identifier = map['identifier'];
        if (identifier == null || identifier.toString().isEmpty) {
          break;
        }
        ids.add(identifier);

        final coordMap = map['coordinates'];
        final double? x = double.tryParse(coordMap['x'].toString());
        final double? y = double.tryParse(coordMap['y'].toString());
        final double? z = double.tryParse(coordMap['z'].toString());
        final List<double> coords = [];
        if (x != null && y != null) {
          coords.add(x);
          coords.add(y);
          if (z != null) {
            coords.add(z);
          }
        }
        allCoordinates.add(coords);
      }
      final projectionData = ProjectionData(projectionID, ids, allCoordinates);
      result[projectionData] = List.from(ids.map((id) => proteinData[id]));
    }
    return result;
  }

  static Map<String, dynamic> toProtSpaceMap(Map<ProjectionData, List<Map<String, dynamic>>> projectionData) {
    final Map<String, dynamic> protspaceMap = {};

    // Reconstruct protein_data
    final Map<String, dynamic> proteinData = {};
    for (final entry in projectionData.entries) {
      for (final protein in entry.value) {
        final String proteinID = protein['id'] ?? '';
        if (proteinID.isNotEmpty) {
          final Map<String, dynamic> features = Map.from(protein)..remove('id');
          proteinData[proteinID] = {
            'features': {
              'sequence': protein['sequence']
            }, // TODO Add actual features
          };
        }
      }
    }
    protspaceMap['protein_data'] = proteinData;

    // Reconstruct projections
    final List<Map<String, dynamic>> projections = [];
    for (final entry in projectionData.entries) {
      final ProjectionData projection = entry.key;
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
          'identifier': projection.pointIDs?[i],
          'coordinates': coordMap,
        });
      }

      projections.add({
        'name': projection.identifier,
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
