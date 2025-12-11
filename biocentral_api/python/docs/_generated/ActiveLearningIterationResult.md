# ActiveLearningIterationResult


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**results** | [**List[ActiveLearningResult]**](ActiveLearningResult.md) | List of active learning results | 
**suggestions** | **List[str]** | List of suggested entity IDs for next iteration | 

## Example

```python
from biocentral_api._generated.models.active_learning_iteration_result import ActiveLearningIterationResult

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningIterationResult from a JSON string
active_learning_iteration_result_instance = ActiveLearningIterationResult.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningIterationResult.to_json())

# convert the object into a dict
active_learning_iteration_result_dict = active_learning_iteration_result_instance.to_dict()
# create an instance of ActiveLearningIterationResult from a dict
active_learning_iteration_result_from_dict = ActiveLearningIterationResult.from_dict(active_learning_iteration_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


