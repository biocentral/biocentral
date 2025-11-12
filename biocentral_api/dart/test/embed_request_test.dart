import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';

// tests for EmbedRequest
void main() {
  final instance = EmbedRequestBuilder();
  // TODO add properties to the builder and call build()

  group(EmbedRequest, () {
    // Name of the embedder model to use
    // String embedderName
    test('to test the property `embedderName`', () async {
      // TODO
    });

    // Whether to use dimensionality reduction
    // bool reduce (default value: false)
    test('to test the property `reduce`', () async {
      // TODO
    });

    // Sequence data to embed (seq_id -> sequence)
    // BuiltMap<String, String> sequenceData
    test('to test the property `sequenceData`', () async {
      // TODO
    });

    // Whether to use half precision
    // bool useHalfPrecision (default value: false)
    test('to test the property `useHalfPrecision`', () async {
      // TODO
    });

  });
}
