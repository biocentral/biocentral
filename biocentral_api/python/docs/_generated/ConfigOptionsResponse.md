# ConfigOptionsResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**options** | **List[object]** | List of configuration option dictionaries | 

## Example

```python
from biocentral_api._generated.models.config_options_response import ConfigOptionsResponse

# TODO update the JSON string below
json = "{}"
# create an instance of ConfigOptionsResponse from a JSON string
config_options_response_instance = ConfigOptionsResponse.from_json(json)
# print the JSON string representation of the object
print(ConfigOptionsResponse.to_json())

# convert the object into a dict
config_options_response_dict = config_options_response_instance.to_dict()
# create an instance of ConfigOptionsResponse from a dict
config_options_response_from_dict = ConfigOptionsResponse.from_dict(config_options_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


