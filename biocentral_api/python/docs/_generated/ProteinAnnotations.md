# ProteinAnnotations


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**protein_id** | **List[str]** |  | 

## Example

```python
from biocentral_api._generated.models.protein_annotations import ProteinAnnotations

# TODO update the JSON string below
json = "{}"
# create an instance of ProteinAnnotations from a JSON string
protein_annotations_instance = ProteinAnnotations.from_json(json)
# print the JSON string representation of the object
print(ProteinAnnotations.to_json())

# convert the object into a dict
protein_annotations_dict = protein_annotations_instance.to_dict()
# create an instance of ProteinAnnotations from a dict
protein_annotations_from_dict = ProteinAnnotations.from_dict(protein_annotations_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


