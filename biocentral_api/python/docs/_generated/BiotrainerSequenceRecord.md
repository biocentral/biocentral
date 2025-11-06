# BiotrainerSequenceRecord


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**seq_id** | **str** | Sequence id | 
**seq** | **str** | Sequence | 
**attributes** | **Dict[str, object]** |  | [optional] 
**embedding** | [**AnyOf**](AnyOf.md) | Embedding | [optional] 

## Example

```python
from biocentral_api._generated.models.biotrainer_sequence_record import BiotrainerSequenceRecord

# TODO update the JSON string below
json = "{}"
# create an instance of BiotrainerSequenceRecord from a JSON string
biotrainer_sequence_record_instance = BiotrainerSequenceRecord.from_json(json)
# print the JSON string representation of the object
print(BiotrainerSequenceRecord.to_json())

# convert the object into a dict
biotrainer_sequence_record_dict = biotrainer_sequence_record_instance.to_dict()
# create an instance of BiotrainerSequenceRecord from a dict
biotrainer_sequence_record_from_dict = BiotrainerSequenceRecord.from_dict(biotrainer_sequence_record_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


