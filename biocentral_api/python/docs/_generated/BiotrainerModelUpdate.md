# BiotrainerModelUpdate


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**current_model_result** | [**BiotrainerModelResult**](BiotrainerModelResult.md) | Current model result | 
**training_iteration** | **List[object]** | Current training iteration for fast updates of observers like tensorboard | [optional] 

## Example

```python
from biocentral_api._generated.models.biotrainer_model_update import BiotrainerModelUpdate

# TODO update the JSON string below
json = "{}"
# create an instance of BiotrainerModelUpdate from a JSON string
biotrainer_model_update_instance = BiotrainerModelUpdate.from_json(json)
# print the JSON string representation of the object
print(BiotrainerModelUpdate.to_json())

# convert the object into a dict
biotrainer_model_update_dict = biotrainer_model_update_instance.to_dict()
# create an instance of BiotrainerModelUpdate from a dict
biotrainer_model_update_from_dict = BiotrainerModelUpdate.from_dict(biotrainer_model_update_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


