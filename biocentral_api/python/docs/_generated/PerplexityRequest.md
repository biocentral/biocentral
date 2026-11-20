# PerplexityRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**sequence_data** | **Dict[str, str]** | Dictionary mapping sequence IDs to their amino acid sequence strings | 
**plm_name** | **str** | Name of the PLM to use for perplexity calculation | 

## Example

```python
from biocentral_api._generated.models.perplexity_request import PerplexityRequest

# TODO update the JSON string below
json = "{}"
# create an instance of PerplexityRequest from a JSON string
perplexity_request_instance = PerplexityRequest.from_json(json)
# print the JSON string representation of the object
print(PerplexityRequest.to_json())

# convert the object into a dict
perplexity_request_dict = perplexity_request_instance.to_dict()
# create an instance of PerplexityRequest from a dict
perplexity_request_from_dict = PerplexityRequest.from_dict(perplexity_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


