# ActiveLearningEngineeringSimulationConfig

Configuration for a simulated engineering campaign over a labelled landscape.  Each round scores candidates drawn from simulation_data, so every suggestion has a label to reveal. Engineering campaigns only maximize or minimize, so there is no hit_target_delta.

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**simulation_data** | [**List[biotrainer_core.data_classes.SequenceData]**](biotrainer_core.data_classes.SequenceData.md) | List of all sequence data for the simulation | 
**n_start** | **int** | Number of initial sequences to use for training (chosen randomly, seed from campaign config used) | [optional] 
**start_ids** | **List[str]** | List of sequence IDs to start the simulated campaign | [optional] 
**n_suggestions_per_iteration** | **int** | Number of suggestions to propose per iteration | 
**stopping_config** | [**ActiveLearningStoppingConfig**](ActiveLearningStoppingConfig.md) | Stopping criteria for the simulation | 
**hit_percentile** | **float** | Percentile of all labels that counts as a hit (modes: MAXIMIZE, MINIMIZE). 1.0 means the top/bottom 1% of the labels. | [optional] [default to 1.0]
**n_candidates_per_iteration** | **int** | Number of unlabelled landscape variants to score per iteration | [optional] [default to 1000]

## Example

```python
from biocentral_api._generated.models.active_learning_engineering_simulation_config import ActiveLearningEngineeringSimulationConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningEngineeringSimulationConfig from a JSON string
active_learning_engineering_simulation_config_instance = ActiveLearningEngineeringSimulationConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningEngineeringSimulationConfig.to_json())

# convert the object into a dict
active_learning_engineering_simulation_config_dict = active_learning_engineering_simulation_config_instance.to_dict()
# create an instance of ActiveLearningEngineeringSimulationConfig from a dict
active_learning_engineering_simulation_config_from_dict = ActiveLearningEngineeringSimulationConfig.from_dict(active_learning_engineering_simulation_config_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


