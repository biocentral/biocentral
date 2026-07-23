# biocentral_api.model.ActiveLearningScreeningSimulationResult

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaignName** | **String** | Name of the simulated active learning campaign | 
**potentialHits** | **BuiltList&lt;String&gt;** | Potential targets (hits) to find in the dataset given the campaign config | 
**iterationMetricsTotal** | [**BuiltList&lt;BootstrappedMetric&gt;**](BootstrappedMetric.md) | Total metrics (mae/acc) for each iteration on all data | [optional] 
**iterationMetricsSuggestions** | [**BuiltList&lt;BootstrappedMetric&gt;**](BootstrappedMetric.md) | Metrics (mae/acc) for each iteration on suggested data | [optional] 
**iterationHits** | [**BuiltList&lt;BuiltList&lt;String&gt;&gt;**](BuiltList.md) | Successful targets (hits) found in each iteration | [optional] 
**iterationConsecutiveFailures** | **BuiltList&lt;int&gt;** | Number of consecutive failures since the last successful target was found | [optional] 
**stopReasons** | **BuiltList&lt;String&gt;** | Reason(s) for stopping the simulation (convergence criteria reached) | [optional] 
**iterationResults** | [**BuiltList&lt;ActiveLearningIterationResult&gt;**](ActiveLearningIterationResult.md) | List of active learning iteration results | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


