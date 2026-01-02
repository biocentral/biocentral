# AutoEvalProgress


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**completed_tasks** | **int** | Number of completed autoeval tasks | 
**total_tasks** | **int** | Total number of autoeval tasks | 
**current_framework_name** | **str** | Name of the current framework that is being evaluated | 
**current_task_name** | **str** | Name of the current task that is being executed | 
**final_report** | [**AutoEvalReport**](AutoEvalReport.md) |  | [optional] 

## Example

```python
from biocentral_api._generated.models.auto_eval_progress import AutoEvalProgress

# TODO update the JSON string below
json = "{}"
# create an instance of AutoEvalProgress from a JSON string
auto_eval_progress_instance = AutoEvalProgress.from_json(json)
# print the JSON string representation of the object
print(AutoEvalProgress.to_json())

# convert the object into a dict
auto_eval_progress_dict = auto_eval_progress_instance.to_dict()
# create an instance of AutoEvalProgress from a dict
auto_eval_progress_from_dict = AutoEvalProgress.from_dict(auto_eval_progress_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


