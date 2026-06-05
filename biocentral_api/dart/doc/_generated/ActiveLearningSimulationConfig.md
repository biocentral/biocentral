# biocentral_api.model.ActiveLearningSimulationConfig

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
**convergenceConfig** | [**ActiveLearningConvergenceConfig**](ActiveLearningConvergenceConfig.md) | Convergence criteria for the simulation | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


