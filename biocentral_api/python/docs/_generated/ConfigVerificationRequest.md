# ConfigVerificationRequest

Request model for config verification

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**config_dict** | **Dict[str, object]** | Biotrainer configuration | 

## Example

```python
from biocentral_api._generated.models.config_verification_request import ConfigVerificationRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ConfigVerificationRequest from a JSON string
config_verification_request_instance = ConfigVerificationRequest.from_json(json)
# print the JSON string representation of the object
print(ConfigVerificationRequest.to_json())

# convert the object into a dict
config_verification_request_dict = config_verification_request_instance.to_dict()
# create an instance of ConfigVerificationRequest from a dict
config_verification_request_from_dict = ConfigVerificationRequest.from_dict(config_verification_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


