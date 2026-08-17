# GetMissingEmbeddingsResponse

Response model for missing embeddings check

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**missing** | **List[str]** | List of sequence IDs that are missing embeddings | 

## Example

```python
from biocentral_api._generated.models.get_missing_embeddings_response import GetMissingEmbeddingsResponse

# TODO update the JSON string below
json = "{}"
# create an instance of GetMissingEmbeddingsResponse from a JSON string
get_missing_embeddings_response_instance = GetMissingEmbeddingsResponse.from_json(json)
# print the JSON string representation of the object
print(GetMissingEmbeddingsResponse.to_json())

# convert the object into a dict
get_missing_embeddings_response_dict = get_missing_embeddings_response_instance.to_dict()
# create an instance of GetMissingEmbeddingsResponse from a dict
get_missing_embeddings_response_from_dict = GetMissingEmbeddingsResponse.from_dict(get_missing_embeddings_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


