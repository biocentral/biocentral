import 'dart:convert';

import 'package:biocentral/plugins/active_learning/model/al_campaign.dart';
import 'package:biocentral/sdk/domain/biocentral_project_repository.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/domain/streamable_database.dart';
import 'package:biocentral_api/biocentral_api.dart';

/// Repository for managing Active Learning campaigns.
class ALRepository with AutoSaving, StreamableDatabase<List<ALCampaign>> {

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  final Map<String, ALCampaign> _campaigns = {};

  /// Constructor for [ALRepository].
  ///
  /// - [_projectRepository]: The project repository for handling external file operations.
  ALRepository(BiocentralProjectRepository projectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      projectRepository: projectRepository,
      fileName: 'al_results.json',
      fileType: ALCampaign,
      saveFunctionString: saveDBInfo,
    );
  }

  void addNewCampaign(ALCampaign campaign) {
    final internalName = campaign.internalName();
    _campaigns[internalName] = campaign;
    autosave();
    updateStream();
  }

  void addNewCampaigns(List<ALCampaign> campaigns) {
    for(final campaign in campaigns) {
      final internalName = campaign.internalName();
      _campaigns[internalName] = campaign;
    }
    autosave();
    updateStream();
  }

  void addNewResult(ALCampaign campaign, ActiveLearningIterationConfig config, ActiveLearningIterationResult result) {
    campaign.addIterationResult(config, result);
    addNewCampaign(campaign); // Simply overwrite existing campaign
  }

  Map<String, dynamic> serialize() => {'campaigns': _campaigns.values.map((campaign) => campaign.serialize()).toList()};

  Future<String> saveDBInfo() async {
    final jsonMap = serialize();
    return jsonEncode(jsonMap);
  }

  List<ALCampaign> campaignsToList() => List.from(_campaigns.values);

  @override
  List<ALCampaign> toStreamable() => campaignsToList();
}
