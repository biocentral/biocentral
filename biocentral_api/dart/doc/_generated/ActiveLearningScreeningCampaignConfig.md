# biocentral_api.model.ActiveLearningScreeningCampaignConfig

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name                 | Type                                                                    | Description                                                  | Notes      |
| -------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------ | ---------- |
| **embedderName**     | **String**                                                              | Name of the embedder model to use                            |
| **name**             | **String**                                                              | Name of the active learning campaign                         |
| **modelType**        | [**ActiveLearningModelType**](ActiveLearningModelType.md)               | Type of model to use                                         |
| **optimizationMode** | [**ActiveLearningOptimizationMode**](ActiveLearningOptimizationMode.md) | Optimization mode selection                                  |
| **seed**             | **int**                                                                 | Random seed for reproducibility.                             | [optional] |
| **targetLb**         | **num**                                                                 | Lower bound of the target value to optimize (mode: INTERVAL) | [optional] |
| **targetUb**         | **num**                                                                 | Upper bound of the target value to optimize (mode: INTERVAL) | [optional] |
| **targetValue**      | **num**                                                                 | Target value to optimize (mode: VALUE)                       | [optional] |
| **discreteTargets**  | **BuiltList&lt;String&gt;**                                             | List of target labels (must be subset of all labels)         | [optional] |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
