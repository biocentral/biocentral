# SequenceTrainingData


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**seq_id** | **str** | Sequence identifier | 
**sequence** | **str** | AA Sequence | 
**set** | **str** | Set | 
**label** | **str** |  | [optional] 
**mask** | **str** |  | [optional] 

## Example

```python
from biocentral_api._generated.models.sequence_training_data import SequenceTrainingData

# TODO update the JSON string below
json = "{}"
# create an instance of SequenceTrainingData from a JSON string
sequence_training_data_instance = SequenceTrainingData.from_json(json)
# print the JSON string representation of the object
print(SequenceTrainingData.to_json())

# convert the object into a dict
sequence_training_data_dict = sequence_training_data_instance.to_dict()
# create an instance of SequenceTrainingData from a dict
sequence_training_data_from_dict = SequenceTrainingData.from_dict(sequence_training_data_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


