# BiotrainerPrediction


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**seq_id** | **str** | Sequence identifier | 
**prediction** | [**Prediction1**](Prediction1.md) |  | 
**is_aggregated** | **bool** | Whether the prediction is an aggregated per-residue prediction | [optional] [default to False]
**residue_index** | **int** | Residue index for non-collapsed per-residue predictions | [optional] 
**raw_prediction** | [**RawPrediction**](RawPrediction.md) |  | [optional] 
**mcd_predictions** | **List[object]** | All Monte-Carlo-Dropout predictions | [optional] 
**mcd_mean** | [**McdMean**](McdMean.md) |  | [optional] 
**mcd_std** | [**McdStd**](McdStd.md) |  | [optional] 
**mcd_lower_bound** | [**McdLowerBound**](McdLowerBound.md) |  | [optional] 
**mcd_upper_bound** | [**McdUpperBound**](McdUpperBound.md) |  | [optional] 
**bald_score** | **float** | BALD score | [optional] 

## Example

```python
from biocentral_api._generated.models.biotrainer_prediction import BiotrainerPrediction

# TODO update the JSON string below
json = "{}"
# create an instance of BiotrainerPrediction from a JSON string
biotrainer_prediction_instance = BiotrainerPrediction.from_json(json)
# print the JSON string representation of the object
print(BiotrainerPrediction.to_json())

# convert the object into a dict
biotrainer_prediction_dict = biotrainer_prediction_instance.to_dict()
# create an instance of BiotrainerPrediction from a dict
biotrainer_prediction_from_dict = BiotrainerPrediction.from_dict(biotrainer_prediction_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


