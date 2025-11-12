# biocentral_api - Dart Client

## Usage

This library is primarily designed to be used within 
the [biocentral frontend](https://github.com/biocentral/biocentral). You can find usage examples there.
The openapi specification can be found [here](https://biocentral.rostlab.org/docs).

## Post-generation setup
1. Fix `lib/src/model/biotrainer_sequence_record.dart` with BuiltMap
2. Fix `lib/src/api.dart` `getBiocentralApi()` method
3. Fix `serializers.dart`:
```dart
      // Builder factories for nested collection types used in models
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Prediction)]),
        () => ListBuilder<Prediction>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(Prediction)])]),
        () => MapBuilder<String, BuiltList<Prediction>>(),
      )
```
4. Run `dart run build_runner build --delete-conflicting-outputs`
