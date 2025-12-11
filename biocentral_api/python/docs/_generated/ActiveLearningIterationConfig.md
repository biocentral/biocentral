# ActiveLearningIterationConfig

Configuration for a single iteration of active learning

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**iteration_data** | [**List[SequenceTrainingData]**](SequenceTrainingData.md) | List of sequence training data for this iteration | 
**coefficient** | **float** | Exploitation-Exploration Coefficient value (must be between 0 and 1, 1 is maximum exploration) | 
**n_suggestions** | **int** | Number of suggestions to propose from this iteration | 

## Example

```python
from biocentral_api._generated.models.active_learning_iteration_config import ActiveLearningIterationConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningIterationConfig from a JSON string
active_learning_iteration_config_instance = ActiveLearningIterationConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningIterationConfig.to_json())

# convert the object into a dict
active_learning_iteration_config_dict = active_learning_iteration_config_instance.to_dict()
# create an instance of ActiveLearningIterationConfig from a dict
active_learning_iteration_config_from_dict = ActiveLearningIterationConfig.from_dict(active_learning_iteration_config_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


