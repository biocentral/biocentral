# ActiveLearningEngineeringSimulationRequest

Request model for an active learning engineering simulation

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaign_config** | [**ActiveLearningEngineeringCampaignConfig**](ActiveLearningEngineeringCampaignConfig.md) | Engineering campaign configuration | 
**simulation_config** | [**ActiveLearningEngineeringSimulationConfig**](ActiveLearningEngineeringSimulationConfig.md) | Simulation configuration | 

## Example

```python
from biocentral_api._generated.models.active_learning_engineering_simulation_request import ActiveLearningEngineeringSimulationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningEngineeringSimulationRequest from a JSON string
active_learning_engineering_simulation_request_instance = ActiveLearningEngineeringSimulationRequest.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningEngineeringSimulationRequest.to_json())

# convert the object into a dict
active_learning_engineering_simulation_request_dict = active_learning_engineering_simulation_request_instance.to_dict()
# create an instance of ActiveLearningEngineeringSimulationRequest from a dict
active_learning_engineering_simulation_request_from_dict = ActiveLearningEngineeringSimulationRequest.from_dict(active_learning_engineering_simulation_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


