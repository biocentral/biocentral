# biocentral_api.model.TaskDTO

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name                          | Type                                                                                      | Description | Notes      |
| ----------------------------- | ----------------------------------------------------------------------------------------- | ----------- | ---------- |
| **status**                    | [**TaskStatus**](TaskStatus.md)                                                           |             |
| **error**                     | **String**                                                                                |             | [optional] |
| **predictions**               | [**BuiltMap&lt;String, BuiltList&lt;Prediction&gt;&gt;**](BuiltList.md)                   |             | [optional] |
| **biotrainerUpdate**          | [**BiotrainerModelUpdate**](BiotrainerModelUpdate.md)                                     |             | [optional] |
| **biotrainerResult**          | [**BiotrainerModelResult**](BiotrainerModelResult.md)                                     |             | [optional] |
| **biotrainerInferenceResult** | [**BiotrainerInferenceResult**](BiotrainerInferenceResult.md)                             |             | [optional] |
| **embeddingProgress**         | [**EmbeddingProgress**](EmbeddingProgress.md)                                             |             | [optional] |
| **embeddedSequences**         | **BuiltMap&lt;String, String&gt;**                                                        |             | [optional] |
| **embeddings**                | [**BuiltList&lt;SequenceData&gt;**](SequenceData.md)                                      |             | [optional] |
| **embeddingsFile**            | **String**                                                                                |             | [optional] |
| **clusteredData**             | [**BuiltMap&lt;String, BuiltList&lt;String&gt;&gt;**](BuiltList.md)                       |             | [optional] |
| **projectionResult**          | [**ProjectionResult**](ProjectionResult.md)                                               |             | [optional] |
| **alIterationResult**         | [**ActiveLearningIterationResult**](ActiveLearningIterationResult.md)                     |             | [optional] |
| **alSimulationResult**        | [**ActiveLearningScreeningSimulationResult**](ActiveLearningScreeningSimulationResult.md) |             | [optional] |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
