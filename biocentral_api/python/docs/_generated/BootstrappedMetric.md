# BootstrappedMetric

## Properties

| Name                 | Type      | Description                                 | Notes |
| -------------------- | --------- | ------------------------------------------- | ----- |
| **name**             | **str**   | Name of the metric                          |
| **mean**             | **float** | Mean of the metric values                   |
| **lower**            | **float** | Lower bound of the metric values            |
| **upper**            | **float** | Upper bound of the metric values            |
| **iterations**       | **int**   | Number of iterations used for bootstrapping |
| **sample_size**      | **int**   | Sample size used for bootstrapping          |
| **confidence_level** | **float** | Confidence level used for bootstrapping     |

## Example

```python
from biocentral_api._generated.models.bootstrapped_metric import BootstrappedMetric

# TODO update the JSON string below
json = "{}"
# create an instance of BootstrappedMetric from a JSON string
bootstrapped_metric_instance = BootstrappedMetric.from_json(json)
# print the JSON string representation of the object
print(BootstrappedMetric.to_json())

# convert the object into a dict
bootstrapped_metric_dict = bootstrapped_metric_instance.to_dict()
# create an instance of BootstrappedMetric from a dict
bootstrapped_metric_from_dict = BootstrappedMetric.from_dict(bootstrapped_metric_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
