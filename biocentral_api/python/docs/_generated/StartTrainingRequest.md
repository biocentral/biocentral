# StartTrainingRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**config_dict** | **Dict[str, object]** | Biotrainer configuration | 
**training_data** | [**List[SequenceTrainingData]**](SequenceTrainingData.md) | List of sequence training data | 

## Example

```python
from biocentral_api._generated.models.start_training_request import StartTrainingRequest

# TODO update the JSON string below
json = "{}"
# create an instance of StartTrainingRequest from a JSON string
start_training_request_instance = StartTrainingRequest.from_json(json)
# print the JSON string representation of the object
print(StartTrainingRequest.to_json())

# convert the object into a dict
start_training_request_dict = start_training_request_instance.to_dict()
# create an instance of StartTrainingRequest from a dict
start_training_request_from_dict = StartTrainingRequest.from_dict(start_training_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


