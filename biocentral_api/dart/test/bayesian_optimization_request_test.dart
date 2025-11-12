import 'package:test/test.dart';
import 'package:biocentral_api/biocentral_api.dart';

// tests for BayesianOptimizationRequest
void main() {
  final instance = BayesianOptimizationRequestBuilder();
  // TODO add properties to the builder and call build()

  group(BayesianOptimizationRequest, () {
    // Hash identifier for the training database
    // String databaseHash
    test('to test the property `databaseHash`', () async {
      // TODO
    });

    // Type of model to use
    // String modelType
    test('to test the property `modelType`', () async {
      // TODO
    });

    // Coefficient value (must be non-negative)
    // num coefficient
    test('to test the property `coefficient`', () async {
      // TODO
    });

    // Name of embedder to use
    // String embedderName
    test('to test the property `embedderName`', () async {
      // TODO
    });

    // Whether to perform discrete optimization or continuous optimization
    // bool discrete
    test('to test the property `discrete`', () async {
      // TODO
    });

    // Optimization mode selection
    // String optimizationMode
    test('to test the property `optimizationMode`', () async {
      // TODO
    });

    // num targetLb
    test('to test the property `targetLb`', () async {
      // TODO
    });

    // num targetUb
    test('to test the property `targetUb`', () async {
      // TODO
    });

    // num targetValue
    test('to test the property `targetValue`', () async {
      // TODO
    });

    // BuiltList<String> discreteLabels
    test('to test the property `discreteLabels`', () async {
      // TODO
    });

    // BuiltList<String> discreteTargets
    test('to test the property `discreteTargets`', () async {
      // TODO
    });

  });
}
