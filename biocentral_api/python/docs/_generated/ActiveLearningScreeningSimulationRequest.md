# ActiveLearningScreeningSimulationRequest

Request model for an active learning screening simulation

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaign_config** | [**ActiveLearningScreeningCampaignConfig**](ActiveLearningScreeningCampaignConfig.md) | Campaign configuration | 
**simulation_config** | [**ActiveLearningScreeningSimulationConfig**](ActiveLearningScreeningSimulationConfig.md) | Simulation configuration | 

## Example

```python
from biocentral_api._generated.models.active_learning_screening_simulation_request import ActiveLearningScreeningSimulationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningScreeningSimulationRequest from a JSON string
active_learning_screening_simulation_request_instance = ActiveLearningScreeningSimulationRequest.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningScreeningSimulationRequest.to_json())

# convert the object into a dict
active_learning_screening_simulation_request_dict = active_learning_screening_simulation_request_instance.to_dict()
# create an instance of ActiveLearningScreeningSimulationRequest from a dict
active_learning_screening_simulation_request_from_dict = ActiveLearningScreeningSimulationRequest.from_dict(active_learning_screening_simulation_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


