# ConfigVerificationResponse

Response model for config verification

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**error** | **str** | Empty string if verification successful, error message otherwise | [optional] [default to '']

## Example

```python
from biocentral_server_api._generated.models.config_verification_response import ConfigVerificationResponse

# TODO update the JSON string below
json = "{}"
# create an instance of ConfigVerificationResponse from a JSON string
config_verification_response_instance = ConfigVerificationResponse.from_json(json)
# print the JSON string representation of the object
print(ConfigVerificationResponse.to_json())

# convert the object into a dict
config_verification_response_dict = config_verification_response_instance.to_dict()
# create an instance of ConfigVerificationResponse from a dict
config_verification_response_from_dict = ConfigVerificationResponse.from_dict(config_verification_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


