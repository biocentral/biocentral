# ResearchStatsResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**research_stats** | [**ResearchStats**](ResearchStats.md) | Research statistics | 

## Example

```python
from biocentral_api._generated.models.research_stats_response import ResearchStatsResponse

# TODO update the JSON string below
json = "{}"
# create an instance of ResearchStatsResponse from a JSON string
research_stats_response_instance = ResearchStatsResponse.from_json(json)
# print the JSON string representation of the object
print(ResearchStatsResponse.to_json())

# convert the object into a dict
research_stats_response_dict = research_stats_response_instance.to_dict()
# create an instance of ResearchStatsResponse from a dict
research_stats_response_from_dict = ResearchStatsResponse.from_dict(research_stats_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


