# GetProjectionConfigResponse

Response model for projection configuration

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**projection_config** | **Dict[str, List[object]]** | Projection configuration for each method | 

## Example

```python
from biocentral_api._generated.models.get_projection_config_response import GetProjectionConfigResponse

# TODO update the JSON string below
json = "{}"
# create an instance of GetProjectionConfigResponse from a JSON string
get_projection_config_response_instance = GetProjectionConfigResponse.from_json(json)
# print the JSON string representation of the object
print(GetProjectionConfigResponse.to_json())

# convert the object into a dict
get_projection_config_response_dict = get_projection_config_response_instance.to_dict()
# create an instance of GetProjectionConfigResponse from a dict
get_projection_config_response_from_dict = GetProjectionConfigResponse.from_dict(get_projection_config_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


