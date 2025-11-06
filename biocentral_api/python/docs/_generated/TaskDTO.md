# TaskDTO


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**status** | [**TaskStatus**](TaskStatus.md) |  | 
**error** | **str** |  | [optional] 
**predictions** | **Dict[str, List[Prediction]]** |  | [optional] 
**biotrainer_update** | [**OutputData**](OutputData.md) |  | [optional] 
**biotrainer_result** | **Dict[str, object]** |  | [optional] 
**embedding_current** | **int** |  | [optional] 
**embedding_total** | **int** |  | [optional] 
**embedded_sequences** | **Dict[str, str]** |  | [optional] 
**embeddings** | [**List[BiotrainerSequenceRecord]**](BiotrainerSequenceRecord.md) |  | [optional] 
**embeddings_file** | **str** |  | [optional] 
**embedder_name** | **str** |  | [optional] 
**autoeval_progress** | [**AutoEvalProgress**](AutoEvalProgress.md) |  | [optional] 
**bay_opt_results** | **List[object]** |  | [optional] 

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


