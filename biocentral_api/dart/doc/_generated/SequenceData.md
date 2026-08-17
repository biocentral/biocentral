# biocentral_api.model.SequenceData

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**seqId** | **String** | Sequence id | 
**seq** | **String** | Sequence | 
**label** | **String** | Shortcut for TARGET attribute | [optional] 
**set_** | **String** | Shortcut for SET attribute | [optional] 
**mask** | **String** | Shortcut for MASK attribute | [optional] 
**attributes** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Attributes such as TARGET, SET or MASK | [optional] 
**embedding** | [**BuiltList&lt;JsonObject&gt;**](JsonObject.md) | Embedding (should be a list or torch.tensor or numpy array) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


