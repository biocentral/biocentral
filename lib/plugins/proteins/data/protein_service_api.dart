import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/util/biocentral_exception.dart';
import 'package:fpdart/fpdart.dart';

Either<BiocentralException, Map<int, Taxonomy>> parseTaxonomy(Map<String, dynamic> taxonomyData) {
  Map<int, Taxonomy> result = {};
  for (MapEntry<String, dynamic> taxonomyEntry in taxonomyData.entries) {
    int? taxonomyID = int.tryParse(taxonomyEntry.key);
    String? name = taxonomyEntry.value["name"];
    String? family = taxonomyEntry.value["family"];
    if (taxonomyID != null && name != null && family != null) {
      result[taxonomyID] = Taxonomy(id: taxonomyID, name: name, family: family);
    }
  }
  return right(result);
}

class ProteinServiceEndpoints {
  static const String retrieveTaxonomyEndpoint = "/protein_service/taxonomy";
}
