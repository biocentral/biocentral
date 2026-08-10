# ActiveLearningEngineeringIterationRequest

Request model for an active learning engineering iteration

## Properties

| Name                 | Type                                                                                        | Description                         | Notes |
| -------------------- | ------------------------------------------------------------------------------------------- | ----------------------------------- | ----- |
| **campaign_config**  | [**ActiveLearningEngineeringCampaignConfig**](ActiveLearningEngineeringCampaignConfig.md)   | Engineering campaign configuration  |
| **iteration_config** | [**ActiveLearningEngineeringIterationConfig**](ActiveLearningEngineeringIterationConfig.md) | Engineering iteration configuration |

## Example

```python
from biocentral_api._generated.models.active_learning_engineering_iteration_request import ActiveLearningEngineeringIterationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningEngineeringIterationRequest from a JSON string
active_learning_engineering_iteration_request_instance = ActiveLearningEngineeringIterationRequest.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningEngineeringIterationRequest.to_json())

# convert the object into a dict
active_learning_engineering_iteration_request_dict = active_learning_engineering_iteration_request_instance.to_dict()
# create an instance of ActiveLearningEngineeringIterationRequest from a dict
active_learning_engineering_iteration_request_from_dict = ActiveLearningEngineeringIterationRequest.from_dict(active_learning_engineering_iteration_request_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
