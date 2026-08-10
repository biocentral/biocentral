# biocentral_api.model.DerivedValues

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name                     | Type                                    | Description                                          | Notes      |
| ------------------------ | --------------------------------------- | ---------------------------------------------------- | ---------- |
| **biotrainerVersion**    | **String**                              | Version of BioTrainer used for training              | [optional] |
| **classInt2str**         | **BuiltMap&lt;String, String&gt;**      | Mapping of class integers to class names             | [optional] |
| **classStr2int**         | **BuiltMap&lt;String, int&gt;**         | Mapping of class names to class integers             | [optional] |
| **computedClassWeights** | **BuiltMap&lt;String, num&gt;**         | Class weights computed during training               | [optional] |
| **embeddingStats**       | [**EmbeddingStats**](EmbeddingStats.md) | Statistics of the embeddings                         | [optional] |
| **embeddingsFile**       | **String**                              | Path to the embeddings file                          | [optional] |
| **modelHash**            | **String**                              | Hash of the model                                    | [optional] |
| **nClasses**             | **int**                                 | Number of classes in the dataset                     | [optional] |
| **nFeatures**            | **int**                                 | Number of input features (e.g. embedding dimensions) | [optional] |
| **nTestingIds**          | **int**                                 | Number of sequences in the test set                  | [optional] |
| **pipelineElapsedTime**  | **num**                                 | Elapsed time in seconds for the pipeline             | [optional] |
| **pipelineEndTime**      | **String**                              | End time of the pipeline                             | [optional] |
| **pipelineStartTime**    | **String**                              | Start time of the pipeline                           | [optional] |
| **trainingElapsedTime**  | **num**                                 | Elapsed time in seconds for training                 | [optional] |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
