# biocentral_api - Dart Client

## Usage

This library is primarily designed to be used within
the [biocentral frontend](https://github.com/biocentral/biocentral). You can find usage examples there.
The openapi specification can be found [here](https://biocentral.rostlab.org/docs).

## Post-generation setup

1. Fix `lib/src/model/biotrainer_sequence_record.dart` with BuiltMap
2. Add the following to `common_embedder.dart`:

```dart
  String get wireName =>
      (_$commonEmbedderSerializer as _$CommonEmbedderSerializer).serialize(Serializers(), this) as String;
```

3. Add the following to `protocol.dart`:

```dart
  String get wireName =>
      (_$protocolSerializer as _$ProtocolSerializer).serialize(Serializers(), this) as String;
```

4. Run `dart run build_runner build --delete-conflicting-outputs`
5. Rollback `extensions` directory if it was deleted

## Citation

Please cite [our paper](https://doi.org/10.1016/j.jmb.2026.169673) if you are using the _biocentral API_ in your work:

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
