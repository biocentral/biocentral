# ActiveLearningScreeningSimulationConfig

Configuration for a simulation of active learning on a complete dataset

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**simulation_data** | [**List[biotrainer_core.data_classes.SequenceData]**](biotrainer_core.data_classes.SequenceData.md) | List of all sequence data for the simulation | 
**n_start** | **int** | Number of initial sequences to use for training (chosen randomly, seed from campaign config used) | [optional] 
**start_ids** | **List[str]** | List of sequence IDs to start the simulated campaign | [optional] 
**n_suggestions_per_iteration** | **int** | Number of suggestions to propose per iteration | 
**coefficient** | **float** | Exploitation-Exploration coefficient value, applied to every iteration (must be between 0 and 1, 1 is maximum exploration) | [optional] [default to 0.5]
**stopping_config** | [**ActiveLearningStoppingConfig**](ActiveLearningStoppingConfig.md) | Stopping criteria for the simulation | 
**hit_percentile** | **float** | Percentile of all labels that counts as a hit (modes: MAXIMIZE, MINIMIZE). 1.0 means the top/bottom 1% of the labels. | [optional] [default to 1.0]
**hit_target_delta** | **float** | Absolute tolerance around the target value that counts as a hit (mode: VALUE) | [optional] [default to 0.5]

## Example

```python
from biocentral_api._generated.models.active_learning_screening_simulation_config import ActiveLearningScreeningSimulationConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningScreeningSimulationConfig from a JSON string
active_learning_screening_simulation_config_instance = ActiveLearningScreeningSimulationConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningScreeningSimulationConfig.to_json())

# convert the object into a dict
active_learning_screening_simulation_config_dict = active_learning_screening_simulation_config_instance.to_dict()
# create an instance of ActiveLearningScreeningSimulationConfig from a dict
active_learning_screening_simulation_config_from_dict = ActiveLearningScreeningSimulationConfig.from_dict(active_learning_screening_simulation_config_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


