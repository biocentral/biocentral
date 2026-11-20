# BiotrainerCheckpoint


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **str** | Name of the checkpoint (e.g. hold_out) | 
**checkpoint** | **bytes** | Bytes containing the checkpoint | 

## Example

```python
from biocentral_api._generated.models.biotrainer_checkpoint import BiotrainerCheckpoint

# TODO update the JSON string below
json = "{}"
# create an instance of BiotrainerCheckpoint from a JSON string
biotrainer_checkpoint_instance = BiotrainerCheckpoint.from_json(json)
# print the JSON string representation of the object
print(BiotrainerCheckpoint.to_json())

# convert the object into a dict
biotrainer_checkpoint_dict = biotrainer_checkpoint_instance.to_dict()
# create an instance of BiotrainerCheckpoint from a dict
biotrainer_checkpoint_from_dict = BiotrainerCheckpoint.from_dict(biotrainer_checkpoint_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


