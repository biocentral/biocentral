# biocentral_api.model.ActiveLearningScreeningSimulationConfig

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**simulationData** | [**BuiltList&lt;SequenceData&gt;**](SequenceData.md) | List of all sequence data for the simulation | 
**nStart** | **int** | Number of initial sequences to use for training (chosen randomly, seed from campaign config used) | [optional] 
**startIds** | **BuiltList&lt;String&gt;** | List of sequence IDs to start the simulated campaign | [optional] 
**nSuggestionsPerIteration** | **int** | Number of suggestions to propose per iteration | 
**coefficient** | **num** | Exploitation-Exploration coefficient value, applied to every iteration (must be between 0 and 1, 1 is maximum exploration) | [optional] [default to 0.5]
**stoppingConfig** | [**ActiveLearningStoppingConfig**](ActiveLearningStoppingConfig.md) | Stopping criteria for the simulation | 
**hitPercentile** | **num** | Percentile of all labels that counts as a hit (modes: MAXIMIZE, MINIMIZE). 1.0 means the top/bottom 1% of the labels. | [optional] [default to 1.0]
**hitTargetDelta** | **num** | Absolute tolerance around the target value that counts as a hit (mode: VALUE) | [optional] [default to 0.5]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


