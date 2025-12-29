# ModelOutput


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **str** | Name of the output | 
**description** | **str** | Description of the output | 
**output_type** | [**OutputType**](OutputType.md) | Type of output | 
**value_type** | **str** | Type of output values | 
**classes** | [**List[OutputClass]**](OutputClass.md) |  | [optional] 
**value_range** | **List[object]** |  | [optional] 
**unit** | **str** |  | [optional] 

## Example

```python
from biocentral_api._generated.models.model_output import ModelOutput

# TODO update the JSON string below
json = "{}"
# create an instance of ModelOutput from a JSON string
model_output_instance = ModelOutput.from_json(json)
# print the JSON string representation of the object
print(ModelOutput.to_json())

# convert the object into a dict
model_output_dict = model_output_instance.to_dict()
# create an instance of ModelOutput from a dict
model_output_from_dict = ModelOutput.from_dict(model_output_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


