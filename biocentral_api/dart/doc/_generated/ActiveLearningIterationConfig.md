# biocentral_api.model.ActiveLearningIterationConfig

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**iteration** | **int** | Iteration number | 
**iterationData** | [**BuiltList&lt;SequenceTrainingData&gt;**](SequenceTrainingData.md) | List of sequence training data for this iteration | 
**coefficient** | **num** | Exploitation-Exploration coefficient value (must be between 0 and 1, 1 is maximum exploration) | 
**nSuggestions** | **int** | Number of suggestions to propose from this iteration | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


