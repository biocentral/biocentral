# StartTaskResponse

Response model for job submission

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**task_id** | **str** | Unique task identifier for tracking the computation job | 

## Example

```python
from biocentral_api._generated.models.start_task_response import StartTaskResponse

# TODO update the JSON string below
json = "{}"
# create an instance of StartTaskResponse from a JSON string
start_task_response_instance = StartTaskResponse.from_json(json)
# print the JSON string representation of the object
print(StartTaskResponse.to_json())

# convert the object into a dict
start_task_response_dict = start_task_response_instance.to_dict()
# create an instance of StartTaskResponse from a dict
start_task_response_from_dict = StartTaskResponse.from_dict(start_task_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


