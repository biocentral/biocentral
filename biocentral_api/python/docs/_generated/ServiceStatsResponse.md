# ServiceStatsResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**service_stats** | [**BiocentralServiceStats**](BiocentralServiceStats.md) | Service statistics | 

## Example

```python
from biocentral_api._generated.models.service_stats_response import ServiceStatsResponse

# TODO update the JSON string below
json = "{}"
# create an instance of ServiceStatsResponse from a JSON string
service_stats_response_instance = ServiceStatsResponse.from_json(json)
# print the JSON string representation of the object
print(ServiceStatsResponse.to_json())

# convert the object into a dict
service_stats_response_dict = service_stats_response_instance.to_dict()
# create an instance of ServiceStatsResponse from a dict
service_stats_response_from_dict = ServiceStatsResponse.from_dict(service_stats_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


