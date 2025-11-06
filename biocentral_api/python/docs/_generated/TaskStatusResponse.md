# TaskStatusResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**dtos** | [**List[TaskDTO]**](TaskDTO.md) | List of task DTOs generated during task execution | 

## Example

```python
from biocentral_api._generated.models.task_status_response import TaskStatusResponse

# TODO update the JSON string below
json = "{}"
# create an instance of TaskStatusResponse from a JSON string
task_status_response_instance = TaskStatusResponse.from_json(json)
# print the JSON string representation of the object
print(TaskStatusResponse.to_json())

# convert the object into a dict
task_status_response_dict = task_status_response_instance.to_dict()
# create an instance of TaskStatusResponse from a dict
task_status_response_from_dict = TaskStatusResponse.from_dict(task_status_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


