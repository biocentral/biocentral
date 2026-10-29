# biocentral_api.model.ActiveLearningEngineeringSimulationConfig

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
**stoppingConfig** | [**ActiveLearningStoppingConfig**](ActiveLearningStoppingConfig.md) | Stopping criteria for the simulation | 
**hitPercentile** | **num** | Percentile of all labels that counts as a hit (modes: MAXIMIZE, MINIMIZE). 1.0 means the top/bottom 1% of the labels. | [optional] [default to 1.0]
**nCandidatesPerIteration** | **int** | Number of unlabelled landscape variants to score per iteration | [optional] [default to 1000]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


