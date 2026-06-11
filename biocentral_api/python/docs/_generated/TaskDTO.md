# TaskDTO


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**status** | [**TaskStatus**](TaskStatus.md) |  | 
**error** | **str** |  | [optional] 
**predictions** | **Dict[str, List[Prediction]]** |  | [optional] 
**biotrainer_update** | [**BiotrainerModelUpdate**](BiotrainerModelUpdate.md) |  | [optional] 
**biotrainer_result** | [**BiotrainerModelResult**](BiotrainerModelResult.md) |  | [optional] 
**biotrainer_inference_result** | [**BiotrainerInferenceResult**](BiotrainerInferenceResult.md) |  | [optional] 
**embedding_progress** | [**EmbeddingProgress**](EmbeddingProgress.md) |  | [optional] 
**embedded_sequences** | **Dict[str, str]** |  | [optional] 
**embeddings** | [**List[biotrainer_core.data_classes.SequenceData]**](biotrainer_core.data_classes.SequenceData.md) |  | [optional] 
**embeddings_file** | **str** |  | [optional] 
**projection_result** | **Dict[str, object]** | Hyperparameters used for this split | [optional] 
**al_iteration_result** | [**ActiveLearningIterationResult**](ActiveLearningIterationResult.md) |  | [optional] 
**al_simulation_result** | [**ActiveLearningSimulationResult**](ActiveLearningSimulationResult.md) |  | [optional] 

## Example

```python
from biocentral_api._generated.models.task_dto import TaskDTO

# TODO update the JSON string below
json = "{}"
# create an instance of TaskDTO from a JSON string
task_dto_instance = TaskDTO.from_json(json)
# print the JSON string representation of the object
print(TaskDTO.to_json())

# convert the object into a dict
task_dto_dict = task_dto_instance.to_dict()
# create an instance of TaskDTO from a dict
task_dto_from_dict = TaskDTO.from_dict(task_dto_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


