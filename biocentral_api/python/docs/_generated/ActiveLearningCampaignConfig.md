# ActiveLearningCampaignConfig

Configuration for an active learning campaign

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **str** | Name of the active learning campaign | 
**model_type** | [**ActiveLearningModelType**](ActiveLearningModelType.md) | Type of model to use | 
**embedder_name** | **str** | Name of embedder to use | 
**optimization_mode** | [**ActiveLearningOptimizationMode**](ActiveLearningOptimizationMode.md) | Optimization mode selection | 
**target_lb** | **float** |  | [optional] 
**target_ub** | **float** |  | [optional] 
**target_value** | **float** |  | [optional] 
**discrete_targets** | **List[str]** |  | [optional] 

## Example

```python
from biocentral_api._generated.models.active_learning_campaign_config import ActiveLearningCampaignConfig

# TODO update the JSON string below
json = "{}"
# create an instance of ActiveLearningCampaignConfig from a JSON string
active_learning_campaign_config_instance = ActiveLearningCampaignConfig.from_json(json)
# print the JSON string representation of the object
print(ActiveLearningCampaignConfig.to_json())

# convert the object into a dict
active_learning_campaign_config_dict = active_learning_campaign_config_instance.to_dict()
# create an instance of ActiveLearningCampaignConfig from a dict
active_learning_campaign_config_from_dict = ActiveLearningCampaignConfig.from_dict(active_learning_campaign_config_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


