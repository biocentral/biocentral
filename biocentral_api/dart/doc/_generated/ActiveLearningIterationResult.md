# biocentral_api.model.ActiveLearningIterationResult

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**iteration** | **int** | Iteration number (zero indexed for simulations, otherwise matches the given number in the iteration config) | 
**results** | [**BuiltList&lt;ActiveLearningResult&gt;**](ActiveLearningResult.md) | List of active learning results | 
**suggestions** | **BuiltList&lt;String&gt;** | List of suggested entity IDs for next iteration | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


