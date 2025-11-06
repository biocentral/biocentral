# OutputData


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**config** | **Dict[str, object]** |  | [optional] 
**derived_values** | **Dict[str, object]** |  | [optional] 
**split_specific_values** | **Dict[str, object]** |  | [optional] 
**training_iteration** | **List[object]** |  | [optional] 
**test_results** | **Dict[str, object]** |  | [optional] 
**predictions** | **Dict[str, object]** |  | [optional] 

## Example

```python
from biocentral_api._generated.models.output_data import OutputData

# TODO update the JSON string below
json = "{}"
# create an instance of OutputData from a JSON string
output_data_instance = OutputData.from_json(json)
# print the JSON string representation of the object
print(OutputData.to_json())

# convert the object into a dict
output_data_dict = output_data_instance.to_dict()
# create an instance of OutputData from a dict
output_data_from_dict = OutputData.from_dict(output_data_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


