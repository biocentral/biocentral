# EmbedRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**embedder_name** | **str** | Name of the embedder model to use | 
**reduce** | **bool** | Whether to use dimensionality reduction | [optional] [default to False]
**sequence_data** | **Dict[str, str]** | Sequence data to embed (seq_id -&gt; sequence) | 
**use_half_precision** | **bool** | Whether to use half precision | [optional] [default to False]

## Example

```python
from biocentral_api._generated.models.embed_request import EmbedRequest

# TODO update the JSON string below
json = "{}"
# create an instance of EmbedRequest from a JSON string
embed_request_instance = EmbedRequest.from_json(json)
# print the JSON string representation of the object
print(EmbedRequest.to_json())

# convert the object into a dict
embed_request_dict = embed_request_instance.to_dict()
# create an instance of EmbedRequest from a dict
embed_request_from_dict = EmbedRequest.from_dict(embed_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


