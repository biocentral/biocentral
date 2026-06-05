# biocentral_api.model.ActiveLearningConvergenceConfig

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**maxLabelsBudget** | **int** | Maximum number of labels that can be tested in the lab ('We can afford to test 100 proteins total') | [optional] 
**targetSuccesses** | **int** | Number of positive targets found before stopping ('Stop when we find 10 good proteins') | [optional] 
**maxConsecutiveFailures** | **int** | Maximum number of iterations in a row that do not yield a new target ('Stop if 3 rounds yield nothing') | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


