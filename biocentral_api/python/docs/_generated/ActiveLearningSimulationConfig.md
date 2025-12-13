# ActiveLearningSimulationConfig

Configuration for a simulation of active learning on a complete dataset

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**simulation_data** | [**List[SequenceTrainingData]**](SequenceTrainingData.md) | List of all sequence data for the simulation | 
**n_start** | **int** |  | [optional] 
**start_ids** | **List[str]** |  | [optional] 
**n_suggestions_per_iteration** | **int** | Number of suggestions to propose per iteration | 
**convergence_config** | [**ActiveLearningConvergenceConfig**](ActiveLearningConvergenceConfig.md) | Convergence criteria for the simulation | 

## Example

```python
from biocentral_api._generated.models.active_learning_simulation_config import ActiveLearningSimulationConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningSimulationConfig from a JSON string
active_learning_simulation_config_instance = ActiveLearningSimulationConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningSimulationConfig.to_json())

# convert the object into a dict
active_learning_simulation_config_dict = active_learning_simulation_config_instance.to_dict()
# create an instance of ActiveLearningSimulationConfig from a dict
active_learning_simulation_config_from_dict = ActiveLearningSimulationConfig.from_dict(active_learning_simulation_config_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


