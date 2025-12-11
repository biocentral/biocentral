# ActiveLearningSimulationResult

Result of a simulated active learning campaign - used as a mutable object to store intermediate results

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaign_name** | **str** | Name of the simulated active learning campaign | 
**iteration_metrics_total** | **List[float]** | Total metrics (rmse/acc) for each iteration on all data | [optional] 
**iteration_metrics_suggestions** | **List[float]** | Metrics (rmse/acc) for each iteration on suggested data | [optional] 
**iteration_convergence** | **List[float]** | Convergence percentage for each iteration | [optional] 
**iteration_results** | [**List[ActiveLearningIterationResult]**](ActiveLearningIterationResult.md) | List of active learning iteration results | [optional] 

## Example

```python
from biocentral_api._generated.models.active_learning_simulation_result import ActiveLearningSimulationResult

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningSimulationResult from a JSON string
active_learning_simulation_result_instance = ActiveLearningSimulationResult.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningSimulationResult.to_json())

# convert the object into a dict
active_learning_simulation_result_dict = active_learning_simulation_result_instance.to_dict()
# create an instance of ActiveLearningSimulationResult from a dict
active_learning_simulation_result_from_dict = ActiveLearningSimulationResult.from_dict(active_learning_simulation_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


