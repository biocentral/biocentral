# biocentral_api.model.ActiveLearningEngineeringIterationConfig

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**iteration** | **int** | Iteration number | 
**baseSequences** | **BuiltList&lt;String&gt;** | Sequences used to generate mutations (defaults to the wildtype sequence of the campaign) | [optional] 
**trainingData** | [**BuiltList&lt;SequenceData&gt;**](SequenceData.md) | List of training data for this iteration | 
**coefficient** | **num** | Exploitation-Exploration coefficient value (must be between 0 and 1, 1 is maximum exploration) | 
**nSuggestions** | **int** | Number of suggestions to propose from this iteration | 
**nMutations** | **int** | Number of mutations to generate and score in this iteration | [optional] [default to 1000]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


