# ActiveLearningResult


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**entity_id** | **str** | Entity identifier | 
**prediction** | **float** | Predicted value | 
**uncertainty** | **float** | Uncertainty of the prediction | 
**score** | **float** | Score of the entity for using it for the next iteration | 

## Example

```python
from biocentral_api._generated.models.active_learning_result import ActiveLearningResult

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningResult from a JSON string
active_learning_result_instance = ActiveLearningResult.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningResult.to_json())

# convert the object into a dict
active_learning_result_dict = active_learning_result_instance.to_dict()
# create an instance of ActiveLearningResult from a dict
active_learning_result_from_dict = ActiveLearningResult.from_dict(active_learning_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


