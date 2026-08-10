# biocentral_api.model.BiotrainerModelResult

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name                | Type                                                                 | Description                                      | Notes      |
| ------------------- | -------------------------------------------------------------------- | ------------------------------------------------ | ---------- |
| **config**          | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)              | Training configuration parameters                | [optional] |
| **derivedValues**   | [**DerivedValues**](DerivedValues.md)                                | Values derived during the training process       | [optional] |
| **trainingResults** | [**BuiltMap&lt;String, TrainingResult&gt;**](TrainingResult.md)      | Training results for each cross-validation split | [optional] |
| **testResults**     | [**BuiltMap&lt;String, TestResult&gt;**](TestResult.md)              | Test results after training for each test set    | [optional] |
| **predictions**     | [**BuiltList&lt;BiotrainerPrediction&gt;**](BiotrainerPrediction.md) | Predictions made by the model                    | [optional] |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
