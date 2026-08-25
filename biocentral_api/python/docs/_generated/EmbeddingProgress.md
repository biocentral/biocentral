# EmbeddingProgress


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**current** | **int** | Current progress | 
**total** | **int** | Total number of embeddings to compute | 

## Example

```python
from biocentral_api._generated.models.embedding_progress import EmbeddingProgress

# TODO update the JSON string below
json = "{}"
# create an instance of EmbeddingProgress from a JSON string
embedding_progress_instance = EmbeddingProgress.from_json(json)
# print the JSON string representation of the object
print(EmbeddingProgress.to_json())

# convert the object into a dict
embedding_progress_dict = embedding_progress_instance.to_dict()
# create an instance of EmbeddingProgress from a dict
embedding_progress_from_dict = EmbeddingProgress.from_dict(embedding_progress_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


