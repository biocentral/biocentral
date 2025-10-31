# AddEmbeddingsRequest

Request model for adding embeddings

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**h5_bytes** | **str** | Base64 encoded HDF5 file containing embeddings | 
**sequences** | **str** | JSON string containing sequence data | 
**embedder_name** | **str** | Name of the embedder model | 
**reduced** | **bool** | Whether these are reduced embeddings | 

## Example

```python
from biocentral_server_api._generated.models.add_embeddings_request import AddEmbeddingsRequest

# TODO update the JSON string below
json = "{}"
# create an instance of AddEmbeddingsRequest from a JSON string
add_embeddings_request_instance = AddEmbeddingsRequest.from_json(json)
# print the JSON string representation of the object
print(AddEmbeddingsRequest.to_json())

# convert the object into a dict
add_embeddings_request_dict = add_embeddings_request_instance.to_dict()
# create an instance of AddEmbeddingsRequest from a dict
add_embeddings_request_from_dict = AddEmbeddingsRequest.from_dict(add_embeddings_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


