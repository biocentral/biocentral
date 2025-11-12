import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';

// tests for AddEmbeddingsRequest
void main() {
  final instance = AddEmbeddingsRequestBuilder();
  // TODO add properties to the builder and call build()

  group(AddEmbeddingsRequest, () {
    // Base64 encoded HDF5 file containing embeddings
    // String h5Bytes
    test('to test the property `h5Bytes`', () async {
      // TODO
    });

    // JSON string containing sequence data
    // String sequences
    test('to test the property `sequences`', () async {
      // TODO
    });

    // Name of the embedder model
    // String embedderName
    test('to test the property `embedderName`', () async {
      // TODO
    });

    // Whether these are reduced embeddings
    // bool reduced
    test('to test the property `reduced`', () async {
      // TODO
    });

  });
}
