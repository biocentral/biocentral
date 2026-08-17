# ActiveLearningConvergenceConfig

Configuration for convergence criteria for active learning campaigns

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**max_labels_budget** | **int** | Maximum number of labels that can be tested in the lab (&#39;We can afford to test 100 proteins total&#39;) | [optional] 
**n_hits** | **int** | Number of positive targets (hits) found before stopping (&#39;Stop when we find 10 good proteins&#39;) | [optional] 
**max_consecutive_failures** | **int** | Maximum number of iterations in a row that do not yield a new target (&#39;Stop if 3 rounds yield nothing&#39;) | [optional] 

## Example

```python
from biocentral_api._generated.models.active_learning_convergence_config import ActiveLearningConvergenceConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningConvergenceConfig from a JSON string
active_learning_convergence_config_instance = ActiveLearningConvergenceConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningConvergenceConfig.to_json())

# convert the object into a dict
active_learning_convergence_config_dict = active_learning_convergence_config_instance.to_dict()
# create an instance of ActiveLearningConvergenceConfig from a dict
active_learning_convergence_config_from_dict = ActiveLearningConvergenceConfig.from_dict(active_learning_convergence_config_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


