# biocentral_api.model.ActiveLearningSimulationResult

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaignName** | **String** | Name of the simulated active learning campaign | 
**iterationMetricsTotal** | **BuiltList&lt;num&gt;** | Total metrics (rmse/acc) for each iteration on all data | [optional] 
**iterationMetricsSuggestions** | **BuiltList&lt;num&gt;** | Metrics (rmse/acc) for each iteration on suggested data | [optional] 
**iterationTargetSuccesses** | **BuiltList&lt;int&gt;** | Number of successful targets found in each iteration | [optional] 
**iterationConsecutiveFailures** | **BuiltList&lt;int&gt;** | Number of consecutive failures since the last successful target was found | [optional] 
**stopReasons** | **BuiltList&lt;String&gt;** |  | [optional] 
**iterationResults** | [**BuiltList&lt;ActiveLearningIterationResult&gt;**](ActiveLearningIterationResult.md) | List of active learning iteration results | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


