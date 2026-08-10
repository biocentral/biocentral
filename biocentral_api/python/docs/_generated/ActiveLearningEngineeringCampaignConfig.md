# ActiveLearningEngineeringCampaignConfig

Configuration for an active learning engineering campaign

## Properties

| Name                  | Type                                                                    | Description                          | Notes      |
| --------------------- | ----------------------------------------------------------------------- | ------------------------------------ | ---------- |
| **embedder_name**     | **str**                                                                 | Name of the embedder model to use    |
| **name**              | **str**                                                                 | Name of the active learning campaign |
| **model_type**        | [**ActiveLearningModelType**](ActiveLearningModelType.md)               | Type of model to use                 |
| **optimization_mode** | [**ActiveLearningOptimizationMode**](ActiveLearningOptimizationMode.md) | Optimization mode selection          |
| **seed**              | **int**                                                                 | Random seed for reproducibility.     | [optional] |
| **wildtype_sequence** | **str**                                                                 | Wildtype sequence to engineer        |

## Example

```python
from biocentral_api._generated.models.active_learning_engineering_campaign_config import ActiveLearningEngineeringCampaignConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningEngineeringCampaignConfig from a JSON string
active_learning_engineering_campaign_config_instance = ActiveLearningEngineeringCampaignConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningEngineeringCampaignConfig.to_json())

# convert the object into a dict
active_learning_engineering_campaign_config_dict = active_learning_engineering_campaign_config_instance.to_dict()
# create an instance of ActiveLearningEngineeringCampaignConfig from a dict
active_learning_engineering_campaign_config_from_dict = ActiveLearningEngineeringCampaignConfig.from_dict(active_learning_engineering_campaign_config_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
