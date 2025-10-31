# TransferFileRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**hash** | **str** |  | 
**file_type** | **str** |  | 
**file** | **str** |  | 

## Example

```python
from biocentral_server_api._generated.models.transfer_file_request import TransferFileRequest

# TODO update the JSON string below
json = "{}"
# create an instance of TransferFileRequest from a JSON string
transfer_file_request_instance = TransferFileRequest.from_json(json)
# print the JSON string representation of the object
print(TransferFileRequest.to_json())

# convert the object into a dict
transfer_file_request_dict = transfer_file_request_instance.to_dict()
# create an instance of TransferFileRequest from a dict
transfer_file_request_from_dict = TransferFileRequest.from_dict(transfer_file_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


