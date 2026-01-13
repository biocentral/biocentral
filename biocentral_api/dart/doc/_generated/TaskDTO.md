# biocentral_api.model.TaskDTO

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**status** | [**TaskStatus**](TaskStatus.md) |  | 
**error** | **String** |  | [optional] 
**predictions** | [**BuiltMap&lt;String, BuiltList&lt;Prediction&gt;&gt;**](BuiltList.md) |  | [optional] 
**biotrainerUpdate** | [**OutputData**](OutputData.md) |  | [optional] 
**biotrainerResult** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**embeddingProgress** | [**EmbeddingProgress**](EmbeddingProgress.md) |  | [optional] 
**embeddedSequences** | **BuiltMap&lt;String, String&gt;** |  | [optional] 
**embeddings** | [**BuiltList&lt;BiotrainerSequenceRecord&gt;**](BiotrainerSequenceRecord.md) |  | [optional] 
**embeddingsFile** | **String** |  | [optional] 
**projectionResult** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**embedderName** | **String** |  | [optional] 
**autoevalProgress** | [**AutoEvalProgress**](AutoEvalProgress.md) |  | [optional] 
**alIterationResult** | [**ActiveLearningIterationResult**](ActiveLearningIterationResult.md) |  | [optional] 
**alSimulationResult** | [**ActiveLearningSimulationResult**](ActiveLearningSimulationResult.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


