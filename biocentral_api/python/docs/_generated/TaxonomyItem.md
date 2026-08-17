# TaxonomyItem


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**taxonomy_id** | **int** |  | 
**name** | **str** |  | 
**family** | **str** |  | 

## Example

```python
from biocentral_api._generated.models.taxonomy_item import TaxonomyItem

# TODO update the JSON string below
json = "{}"
# create an instance of TaxonomyItem from a JSON string
taxonomy_item_instance = TaxonomyItem.from_json(json)
# print the JSON string representation of the object
print(TaxonomyItem.to_json())

# convert the object into a dict
taxonomy_item_dict = taxonomy_item_instance.to_dict()
# create an instance of TaxonomyItem from a dict
taxonomy_item_from_dict = TaxonomyItem.from_dict(taxonomy_item_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


