import 'package:biocentral_api/biocentral_api.dart';

class BiocentralStatusInfo {
  final BiocentralAPIHealth health;
  final BiocentralServiceStats? serviceStats;
  final ResearchStats? researchStats;

  BiocentralStatusInfo({required this.health, required this.serviceStats, required this.researchStats});

  static Future<BiocentralStatusInfo> fromURL(String url) async {
    final BiocentralAPIHealth health = await BiocentralAPI.healthCheck(url);
    final (BiocentralServiceStats?, ResearchStats?)? stats = await BiocentralAPI.getStats(url);
    return BiocentralStatusInfo(health: health, serviceStats: stats?.$1, researchStats: stats?.$2);
  }
}
