# Prediction

Base class for all model predictions.

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**model_name** | **str** | Name of the model | 
**prediction_name** | **str** | Name of the prediction | 
**protocol** | **str** | Protocol name | 
**value** | **object** |  | 
**value_lower** | **float** |  | [optional] 
**value_upper** | **float** |  | [optional] 

## Example

```python
from biocentral_api._generated.models.prediction import Prediction

# TODO update the JSON string below
json = "{}"
# create an instance of Prediction from a JSON string
prediction_instance = Prediction.from_json(json)
# print the JSON string representation of the object
print(Prediction.to_json())

# convert the object into a dict
prediction_dict = prediction_instance.to_dict()
# create an instance of Prediction from a dict
prediction_from_dict = Prediction.from_dict(prediction_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


