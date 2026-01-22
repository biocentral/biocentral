import 'package:biocentral_api/src/api.dart' as gen;
import 'package:biocentral_api/src/model/taxonomy_item.dart';
import 'package:biocentral_api/src/model/taxonomy_request.dart';
import 'package:built_collection/built_collection.dart';

class ProteinsClient {
  /// Retrieve taxonomy data for the provided taxonomy IDs.
  Future<BuiltList<TaxonomyItem>?> taxonomy({
    required gen.BiocentralApi api,
    required List<int> taxonomyIds,
  }) async {
    final proteinsApi = api.getProteinsApi();
    final req = TaxonomyRequest((b) => b..taxonomyIds.replace(BuiltList<int>(taxonomyIds)));

    try {
      final resp = await proteinsApi.taxonomyApiV1ProteinServiceTaxonomyPost(taxonomyRequest: req);
      return resp.data?.taxonomy;
    } catch (e) {
      print('Exception when calling ProteinsApi->taxonomy: $e');
      return null;
    }
  }
}
