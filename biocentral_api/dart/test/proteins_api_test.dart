import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';


/// tests for ProteinsApi
void main() {
  final instance = BiocentralApi().getProteinsApi();

  group(ProteinsApi, () {
    // Retrieve taxonomy data
    //
    // Retrieve taxonomy data for a list of taxonomy ids
    //
    //Future<TaxonomyResponse> taxonomyApiV1ProteinServiceTaxonomyPost(TaxonomyRequest taxonomyRequest) async
    test('test taxonomyApiV1ProteinServiceTaxonomyPost', () async {
      // TODO
    });

  });
}
