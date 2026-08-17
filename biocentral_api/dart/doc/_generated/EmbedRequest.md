# biocentral_api.model.EmbedRequest

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**embedderName** | **String** | Name of the embedder model to use | 
**reduce** | **bool** | Whether to use dimensionality reduction | [optional] [default to false]
**sequenceData** | **BuiltMap&lt;String, String&gt;** | Sequence data to embed (seq_id -> sequence) | 
**useHalfPrecision** | **bool** | Whether to use half precision | [optional] [default to false]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


