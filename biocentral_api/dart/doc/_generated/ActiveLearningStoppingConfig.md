# biocentral_api.model.ActiveLearningStoppingConfig

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**maxLabelsBudget** | **int** | Maximum number of labels that can be tested in the lab ('We can afford to test 100 proteins total') | [optional] 
**nHits** | **int** | Number of positive targets (hits) found before stopping ('Stop when we find 10 good proteins') | [optional] 
**maxConsecutiveFailures** | **int** | Maximum number of iterations in a row that do not yield a new target ('Stop if 3 rounds yield nothing') | [optional] 
**nMaxIterations** | **int** | Hard upper limit on the number of iterations, applied even if no other criterion is reached | [optional] [default to 100]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


