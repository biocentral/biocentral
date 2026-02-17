# biocentral_api - Dart Client

## Usage

This library is primarily designed to be used within 
the [biocentral frontend](https://github.com/biocentral/biocentral). You can find usage examples there.
The openapi specification can be found [here](https://biocentral.rostlab.org/docs).

## Post-generation setup
1. Fix `lib/src/model/biotrainer_sequence_record.dart` with BuiltMap
2. Fix `serializers.dart`:
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

## Citation

Please cite [our paper](https://doi.org/10.1016/j.jmb.2026.169673) if you are using the *biocentral API* in your work:

```text
@Article{Franz2026,
  author    = {Franz, Sebastian and Olenyi, Tobias and Schloetermann, Paula and Smaoui, Amine and Jimenez-Soto, Luisa F. and Rost, Burkhard},
  journal   = {Journal of Molecular Biology},
  title     = {biocentral: embedding-based protein predictions},
  year      = {2026},
  issn      = {0022-2836},
  month     = jan,
  pages     = {169673},
  doi       = {10.1016/j.jmb.2026.169673},
  groups    = {[JMB] biocentral: embedding-based protein predictions, swc_bo_engineering},
  publisher = {Elsevier BV},
}
```