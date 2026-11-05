# ClusterHBIResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**metrics** | [**List[BootstrappedMetric]**](BootstrappedMetric.md) | Bootstrapped evaluation metrics | 
**clusters** | **Dict[str, List[str]]** | Calculated cluster dictionary (rep_id -&gt; members) | 

## Example

```python
from biocentral_api._generated.models.cluster_hbi_response import ClusterHBIResponse

# TODO update the JSON string below
json = "{}"
# create an instance of ClusterHBIResponse from a JSON string
cluster_hbi_response_instance = ClusterHBIResponse.from_json(json)
# print the JSON string representation of the object
print(ClusterHBIResponse.to_json())

# convert the object into a dict
cluster_hbi_response_dict = cluster_hbi_response_instance.to_dict()
# create an instance of ClusterHBIResponse from a dict
cluster_hbi_response_from_dict = ClusterHBIResponse.from_dict(cluster_hbi_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


