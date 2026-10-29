# biocentral_api.model.SplitHBIRequest

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**trainSeqs** | **BuiltMap&lt;String, String&gt;** | Target database sequences (train split) | 
**querySeqs** | **BuiltMap&lt;String, String&gt;** | Query database sequences to evaluate (test/val split) | 
**trainLabels** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Ground truth annotations for train sequences | 
**queryLabels** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Ground truth annotations for query sequences | 
**evalueCutoff** | **num** | Maximum MMSeqs2 E-value threshold | [optional] [default to 10.0]
**minSeqId** | **num** | Minimum sequence identity threshold | [optional] [default to 0.0]
**isNumeric** | **bool** | True for continuous regression targets, False for classification | [optional] [default to false]
**iterations** | **int** | Bootstrap iterations performed | [optional] [default to 30]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


