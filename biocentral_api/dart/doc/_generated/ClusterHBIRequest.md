# biocentral_api.model.ClusterHBIRequest

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**datasetHash** | **String** | Unique hash of the dataset for caching | 
**sequenceIdentityThreshold** | **num** | Sequence identity threshold for clustering | [optional] [default to 0.3]
**sequenceData** | **BuiltMap&lt;String, String&gt;** | Map of sequence_id -> sequence. Required on first call | [optional] 
**targetData** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Map of sequence_id -> target label/value for evaluation | 
**isNumeric** | **bool** | True for continuous regression targets, False for classification | [optional] [default to false]
**iterations** | **int** | Bootstrap iterations performed | [optional] [default to 30]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


