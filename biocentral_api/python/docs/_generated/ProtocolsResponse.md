# ProtocolsResponse

Response model for available protocols

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**protocols** | **List[str]** | List of available protocol names | 

## Example

```python
from biocentral_server_api._generated.models.protocols_response import ProtocolsResponse

# TODO update the JSON string below
json = "{}"
# create an instance of ProtocolsResponse from a JSON string
protocols_response_instance = ProtocolsResponse.from_json(json)
# print the JSON string representation of the object
print(ProtocolsResponse.to_json())

# convert the object into a dict
protocols_response_dict = protocols_response_instance.to_dict()
# create an instance of ProtocolsResponse from a dict
protocols_response_from_dict = ProtocolsResponse.from_dict(protocols_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


