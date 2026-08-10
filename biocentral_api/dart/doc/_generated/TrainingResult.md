# biocentral_api.model.TrainingResult

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name                    | Type                                                    | Description                               | Notes      |
| ----------------------- | ------------------------------------------------------- | ----------------------------------------- | ---------- |
| **nTrainingIds**        | **int**                                                 | Number of sequences in the training set   | [optional] |
| **nValidationIds**      | **int**                                                 | Number of sequences in the validation set | [optional] |
| **trainingIds**         | **BuiltList&lt;String&gt;**                             | List of IDs in the training set           | [optional] |
| **validationIds**       | **BuiltList&lt;String&gt;**                             | List of IDs in the validation set         | [optional] |
| **splitHyperParams**    | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Hyperparameters used for this split       | [optional] |
| **nFreeParameters**     | **int**                                                 | Number of free parameters in the model    | [optional] |
| **startTime**           | **String**                                              | Start time of the training process        | [optional] |
| **endTime**             | **String**                                              | End time of the training process          | [optional] |
| **elapsedTime**         | **num**                                                 | Elapsed time in seconds for training      | [optional] |
| **trainingLosses**      | **BuiltList&lt;num&gt;**                                | Training losses for each epoch            | [optional] |
| **validationLosses**    | **BuiltList&lt;num&gt;**                                | Validation losses for each epoch          | [optional] |
| **bestEpochMetrics**    | [**EpochMetrics**](EpochMetrics.md)                     | Best training epoch metrics               | [optional] |
| **sanityCheckWarnings** | **BuiltList&lt;String&gt;**                             | Warnings from sanity checks               | [optional] |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
