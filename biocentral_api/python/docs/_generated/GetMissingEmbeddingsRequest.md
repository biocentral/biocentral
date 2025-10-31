# GetMissingEmbeddingsRequest

Request model for checking missing embeddings

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**sequences** | **str** | JSON string containing sequence data | 
**embedder_name** | **str** | Name of the embedder model | 
**reduced** | **bool** | Whether to check for reduced embeddings | 

## Example

```python
from biocentral_server_api._generated.models.get_missing_embeddings_request import GetMissingEmbeddingsRequest

# TODO update the JSON string below
json = "{}"
# create an instance of GetMissingEmbeddingsRequest from a JSON string
get_missing_embeddings_request_instance = GetMissingEmbeddingsRequest.from_json(json)
# print the JSON string representation of the object
print(GetMissingEmbeddingsRequest.to_json())

# convert the object into a dict
get_missing_embeddings_request_dict = get_missing_embeddings_request_instance.to_dict()
# create an instance of GetMissingEmbeddingsRequest from a dict
get_missing_embeddings_request_from_dict = GetMissingEmbeddingsRequest.from_dict(get_missing_embeddings_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


