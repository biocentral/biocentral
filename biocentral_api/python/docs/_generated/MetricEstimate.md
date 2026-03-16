# MetricEstimate


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **str** | Name of the metric | 
**mean** | **float** | Mean of the metric values | 
**lower** | **float** | Lower bound of the metric values | 
**upper** | **float** | Upper bound of the metric values | 

## Example

```python
from biocentral_api._generated.models.metric_estimate import MetricEstimate

# TODO update the JSON string below
json = "{}"
# create an instance of MetricEstimate from a JSON string
metric_estimate_instance = MetricEstimate.from_json(json)
# print the JSON string representation of the object
print(MetricEstimate.to_json())

# convert the object into a dict
metric_estimate_dict = metric_estimate_instance.to_dict()
# create an instance of MetricEstimate from a dict
metric_estimate_from_dict = MetricEstimate.from_dict(metric_estimate_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


