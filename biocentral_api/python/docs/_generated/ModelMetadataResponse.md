# ModelMetadataResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**metadata** | **Dict[str, object]** |  | 

## Example

```python
from biocentral_server_api._generated.models.model_metadata_response import ModelMetadataResponse

# TODO update the JSON string below
json = "{}"
# create an instance of ModelMetadataResponse from a JSON string
model_metadata_response_instance = ModelMetadataResponse.from_json(json)
# print the JSON string representation of the object
print(ModelMetadataResponse.to_json())

# convert the object into a dict
model_metadata_response_dict = model_metadata_response_instance.to_dict()
# create an instance of ModelMetadataResponse from a dict
model_metadata_response_from_dict = ModelMetadataResponse.from_dict(model_metadata_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


