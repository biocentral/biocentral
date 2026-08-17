# TaxonomyResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**taxonomy** | [**List[TaxonomyItem]**](TaxonomyItem.md) | List of taxonomy lookup results | 

## Example

```python
from biocentral_api._generated.models.taxonomy_response import TaxonomyResponse

# TODO update the JSON string below
json = "{}"
# create an instance of TaxonomyResponse from a JSON string
taxonomy_response_instance = TaxonomyResponse.from_json(json)
# print the JSON string representation of the object
print(TaxonomyResponse.to_json())

# convert the object into a dict
taxonomy_response_dict = taxonomy_response_instance.to_dict()
# create an instance of TaxonomyResponse from a dict
taxonomy_response_from_dict = TaxonomyResponse.from_dict(taxonomy_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


