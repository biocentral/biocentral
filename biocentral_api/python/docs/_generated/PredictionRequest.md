# PredictionRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**model_names** | **List[str]** | List of model names to use for prediction | 
**sequence_input** | **Dict[str, str]** | Dictionary mapping sequence IDs to protein sequences | 

## Example

```python
from biocentral_api._generated.models.prediction_request import PredictionRequest

# TODO update the JSON string below
json = "{}"
# create an instance of PredictionRequest from a JSON string
prediction_request_instance = PredictionRequest.from_json(json)
# print the JSON string representation of the object
print(PredictionRequest.to_json())

# convert the object into a dict
prediction_request_dict = prediction_request_instance.to_dict()
# create an instance of PredictionRequest from a dict
prediction_request_from_dict = PredictionRequest.from_dict(prediction_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


