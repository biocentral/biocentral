# ActiveLearningScreeningIterationRequest

Request model for an active learning screening iteration

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**campaign_config** | [**ActiveLearningScreeningCampaignConfig**](ActiveLearningScreeningCampaignConfig.md) | Campaign configuration | 
**iteration_config** | [**ActiveLearningScreeningIterationConfig**](ActiveLearningScreeningIterationConfig.md) | Iteration configuration | 

## Example

```python
from biocentral_api._generated.models.active_learning_screening_iteration_request import ActiveLearningScreeningIterationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningScreeningIterationRequest from a JSON string
active_learning_screening_iteration_request_instance = ActiveLearningScreeningIterationRequest.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningScreeningIterationRequest.to_json())

# convert the object into a dict
active_learning_screening_iteration_request_dict = active_learning_screening_iteration_request_instance.to_dict()
# create an instance of ActiveLearningScreeningIterationRequest from a dict
active_learning_screening_iteration_request_from_dict = ActiveLearningScreeningIterationRequest.from_dict(active_learning_screening_iteration_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


