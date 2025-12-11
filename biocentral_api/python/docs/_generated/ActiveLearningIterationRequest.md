# ActiveLearningIterationRequest

Request model for an active learning iteration

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaign_config** | [**ActiveLearningCampaignConfig**](ActiveLearningCampaignConfig.md) | Campaign configuration | 
**iteration_config** | [**ActiveLearningIterationConfig**](ActiveLearningIterationConfig.md) | Iteration configuration | 

## Example

```python
from biocentral_api._generated.models.active_learning_iteration_request import ActiveLearningIterationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningIterationRequest from a JSON string
active_learning_iteration_request_instance = ActiveLearningIterationRequest.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningIterationRequest.to_json())

# convert the object into a dict
active_learning_iteration_request_dict = active_learning_iteration_request_instance.to_dict()
# create an instance of ActiveLearningIterationRequest from a dict
active_learning_iteration_request_from_dict = ActiveLearningIterationRequest.from_dict(active_learning_iteration_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


