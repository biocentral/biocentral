# ActiveLearningSimulationRequest

Request model for an active learning simulation

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaign_config** | [**ActiveLearningCampaignConfig**](ActiveLearningCampaignConfig.md) | Campaign configuration | 
**simulation_config** | [**ActiveLearningSimulationConfig**](ActiveLearningSimulationConfig.md) | Simulation configuration | 

## Example

```python
from biocentral_api._generated.models.active_learning_simulation_request import ActiveLearningSimulationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningSimulationRequest from a JSON string
active_learning_simulation_request_instance = ActiveLearningSimulationRequest.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningSimulationRequest.to_json())

# convert the object into a dict
active_learning_simulation_request_dict = active_learning_simulation_request_instance.to_dict()
# create an instance of ActiveLearningSimulationRequest from a dict
active_learning_simulation_request_from_dict = ActiveLearningSimulationRequest.from_dict(active_learning_simulation_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


