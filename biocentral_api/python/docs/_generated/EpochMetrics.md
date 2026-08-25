# EpochMetrics


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**epoch** | **int** | Epoch number | 
**training** | **Dict[str, object]** | Training metrics | 
**validation** | **Dict[str, object]** | Validation metrics | 

## Example

```python
from biocentral_api._generated.models.epoch_metrics import EpochMetrics

# TODO update the JSON string below
json = "{}"
# create an instance of EpochMetrics from a JSON string
epoch_metrics_instance = EpochMetrics.from_json(json)
# print the JSON string representation of the object
print(EpochMetrics.to_json())

# convert the object into a dict
epoch_metrics_dict = epoch_metrics_instance.to_dict()
# create an instance of EpochMetrics from a dict
epoch_metrics_from_dict = EpochMetrics.from_dict(epoch_metrics_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


