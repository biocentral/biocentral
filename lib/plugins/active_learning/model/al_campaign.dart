import 'package:biocentral/sdk/util/library_extensions_util.dart';
import 'package:biocentral_api/biocentral_api.dart';

class ALCampaign {
  final ActiveLearningCampaignConfig config;
  final String columnName; // Database Column used for the campaign
  final List<(ActiveLearningIterationConfig, ActiveLearningIterationResult)> iterationResults;

  ALCampaign({required this.config, required this.columnName, required this.iterationResults});

  ALCampaign.startNew({required this.config, required this.columnName}) : iterationResults = [];

  factory ALCampaign.deserialize(Map<String, dynamic> jsonMap) {
    return ALCampaign(
      config: ALCampaignConfigSerial.deserialize(jsonMap['config']),
      columnName: jsonMap['columnName'],
      iterationResults: (jsonMap['iterationResults'] as List<dynamic>)
          .map(
            (item) => (
              ALIterationConfigSerial.deserialize(item['config']),
              ALIterationResultSerial.deserialize(item['result']),
            ),
          )
          .toList(),
    );
  }

  String internalName() {
    return config.name + config.embedderName + columnName + config.hashCode.toString();
  }

  void addIterationResult(ActiveLearningIterationConfig config, ActiveLearningIterationResult result) {
    iterationResults.add((config, result));
  }

  Map<String, dynamic> serialize() {
    return {
      'config': config.serialize(),
      'columnName': columnName,
      'iterationResults': iterationResults
          .map(
            (tuple) => {
              'config': tuple.$1.serialize(),
              'result': tuple.$2.serialize(),
            },
          )
          .toList(),
    };
  }
}
