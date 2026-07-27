import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/biocentral_service_stats.dart';
import 'package:biocentral_api/src/model/research_stats.dart';
import 'package:built_collection/built_collection.dart';

class StatsClient {
  /// Retrieve service and research stats.
  Future<BiocentralServiceStats?> serviceStats({
    required gen.BiocentralApi api,
  }) async {
    final serviceApi = api.getBiocentralServiceApi();

    try {
      final resp = await serviceApi.statsApiV1BiocentralServiceStatsGet();
      return resp.data?.serviceStats;
    } catch (e) {
      print('Exception when calling StatsClient->serviceStats: $e');
      return null;
    }
  }

  Future<ResearchStats?> researchStats({
    required gen.BiocentralApi api,
  }) async {
    final serviceApi = api.getBiocentralServiceApi();

    try {
      final resp = await serviceApi.researchStatsApiV1BiocentralServiceResearchStatsGet();
      return resp.data?.researchStats;
    } catch (e) {
      print('Exception when calling StatsClient->researchStats: $e');
      return null;
    }
  }
}
