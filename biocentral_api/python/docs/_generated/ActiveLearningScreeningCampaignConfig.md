# ActiveLearningScreeningCampaignConfig

Configuration for an active learning screening campaign

## Properties

| Name                  | Type                                                                    | Description                                                  | Notes      |
| --------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------ | ---------- |
| **embedder_name**     | **str**                                                                 | Name of the embedder model to use                            |
| **name**              | **str**                                                                 | Name of the active learning campaign                         |
| **model_type**        | [**ActiveLearningModelType**](ActiveLearningModelType.md)               | Type of model to use                                         |
| **optimization_mode** | [**ActiveLearningOptimizationMode**](ActiveLearningOptimizationMode.md) | Optimization mode selection                                  |
| **seed**              | **int**                                                                 | Random seed for reproducibility.                             | [optional] |
| **target_lb**         | **float**                                                               | Lower bound of the target value to optimize (mode: INTERVAL) | [optional] |
| **target_ub**         | **float**                                                               | Upper bound of the target value to optimize (mode: INTERVAL) | [optional] |
| **target_value**      | **float**                                                               | Target value to optimize (mode: VALUE)                       | [optional] |
| **discrete_targets**  | **List[str]**                                                           | List of target labels (must be subset of all labels)         | [optional] |

## Example

```python
from biocentral_api._generated.models.active_learning_screening_campaign_config import ActiveLearningScreeningCampaignConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningScreeningCampaignConfig from a JSON string
active_learning_screening_campaign_config_instance = ActiveLearningScreeningCampaignConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningScreeningCampaignConfig.to_json())

# convert the object into a dict
active_learning_screening_campaign_config_dict = active_learning_screening_campaign_config_instance.to_dict()
# create an instance of ActiveLearningScreeningCampaignConfig from a dict
active_learning_screening_campaign_config_from_dict = ActiveLearningScreeningCampaignConfig.from_dict(active_learning_screening_campaign_config_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
