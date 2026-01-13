# biocentral_api.model.ActiveLearningSimulationConfig

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**simulationData** | [**BuiltList&lt;SequenceTrainingData&gt;**](SequenceTrainingData.md) | List of all sequence data for the simulation | 
**nStart** | **int** |  | [optional] 
**startIds** | **BuiltList&lt;String&gt;** |  | [optional] 
**nSuggestionsPerIteration** | **int** | Number of suggestions to propose per iteration | 
**convergenceConfig** | [**ActiveLearningConvergenceConfig**](ActiveLearningConvergenceConfig.md) | Convergence criteria for the simulation | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


