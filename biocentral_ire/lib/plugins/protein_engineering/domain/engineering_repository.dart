import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/domain/streamable_database.dart';

/// Owns applied campaign revisions and project autosave.
class EngineeringRepository with AutoSaving, StreamableDatabase<List<EngineeringCampaign>> {
  final Map<String, EngineeringCampaign> _campaigns = {};

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  EngineeringRepository(BiocentralProjectRepository projectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      projectRepository: projectRepository,
      fileName: 'engineering_results.json',
      fileType: EngineeringCampaign,
      saveFunctionString: () async => encodeEngineeringCampaigns(_campaigns.values),
    );
  }

  EngineeringCampaign? campaign(String id) => _campaigns[id];

  /// Commits only if the revision captured by the command is still current.
  void replace(EngineeringCampaign campaign, {required int? expectedRevision}) {
    if (_campaigns[campaign.id]?.revision != expectedRevision) {
      throw StateError('Campaign changed since this command was prepared. Please try again.');
    }
    _campaigns[campaign.id] = campaign;
    _publish();
  }

  void delete(String id, {required int expectedRevision}) {
    if (_campaigns[id]?.revision != expectedRevision) throw StateError('Campaign changed before deletion.');
    _campaigns.remove(id);
    _publish();
  }

  /// Applies a completely validated import in a single repository update.
  void importCampaigns(List<EngineeringCampaign> campaigns, {required DatabaseImportMode mode}) {
    for (final campaign in campaigns) {
      if (mode == DatabaseImportMode.overwrite || !_campaigns.containsKey(campaign.id)) {
        _campaigns[campaign.id] = campaign;
      }
    }
    _publish();
  }

  void _publish() {
    autosave();
    updateStream();
  }

  @override
  List<EngineeringCampaign> toStreamable() => List.unmodifiable(_campaigns.values);
}
