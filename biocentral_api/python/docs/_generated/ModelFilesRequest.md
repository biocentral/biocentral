# ModelFilesRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**model_hash** | **str** | Hash identifier for the trained model | 

## Example

```python
from biocentral_api._generated.models.model_files_request import ModelFilesRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ModelFilesRequest from a JSON string
model_files_request_instance = ModelFilesRequest.from_json(json)
# print the JSON string representation of the object
print(ModelFilesRequest.to_json())

# convert the object into a dict
model_files_request_dict = model_files_request_instance.to_dict()
# create an instance of ModelFilesRequest from a dict
model_files_request_from_dict = ModelFilesRequest.from_dict(model_files_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


