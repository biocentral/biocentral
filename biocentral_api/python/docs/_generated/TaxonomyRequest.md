# TaxonomyRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**taxonomy_ids** | **List[int]** | List of taxonomy ids | 

## Example

```python
from biocentral_server_api._generated.models.taxonomy_request import TaxonomyRequest

# TODO update the JSON string below
json = "{}"
# create an instance of TaxonomyRequest from a JSON string
taxonomy_request_instance = TaxonomyRequest.from_json(json)
# print the JSON string representation of the object
print(TaxonomyRequest.to_json())

# convert the object into a dict
taxonomy_request_dict = taxonomy_request_instance.to_dict()
# create an instance of TaxonomyRequest from a dict
taxonomy_request_from_dict = TaxonomyRequest.from_dict(taxonomy_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


