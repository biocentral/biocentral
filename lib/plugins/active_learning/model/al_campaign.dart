import 'package:biocentral_api/biocentral_api.dart';

class ALCampaign {
  final ActiveLearningScreeningCampaignConfig config;
  final String columnName; // Database Column used for the campaign
  final List<(ActiveLearningScreeningIterationConfig, ActiveLearningIterationResult)> iterationResults;

  ALCampaign({required this.config, required this.columnName, required this.iterationResults});

  ALCampaign.startNew({required this.config, required this.columnName}) : iterationResults = [];

  factory ALCampaign.deserialize(Map<String, dynamic> jsonMap) {
    return ALCampaign(
      config: ALScreeningCampaignConfigSerial.deserialize(jsonMap['config']),
      columnName: jsonMap['columnName'],
      iterationResults: (jsonMap['iterationResults'] as List<dynamic>)
          .map(
            (item) => (
              ALScreeningIterationConfigSerial.deserialize(item['config']),
              ALIterationResultSerial.deserialize(item['result']),
            ),
          )
          .toList(),
    );
  }

  String internalName() {
    return config.name + config.embedderName + columnName + config.hashCode.toString();
  }

  void addIterationResult(ActiveLearningScreeningIterationConfig config, ActiveLearningIterationResult result) {
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
