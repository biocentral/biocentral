# AddEmbeddingsResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**success** | **bool** | Bool flag indicating whether embeddings were added successfully | 

## Example

```python
from biocentral_server_api._generated.models.add_embeddings_response import AddEmbeddingsResponse

# TODO update the JSON string below
json = "{}"
# create an instance of AddEmbeddingsResponse from a JSON string
add_embeddings_response_instance = AddEmbeddingsResponse.from_json(json)
# print the JSON string representation of the object
print(AddEmbeddingsResponse.to_json())

# convert the object into a dict
add_embeddings_response_dict = add_embeddings_response_instance.to_dict()
# create an instance of AddEmbeddingsResponse from a dict
add_embeddings_response_from_dict = AddEmbeddingsResponse.from_dict(add_embeddings_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


