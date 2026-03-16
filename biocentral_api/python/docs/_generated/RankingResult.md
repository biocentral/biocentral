# RankingResult


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**scc** | [**MetricEstimate**](MetricEstimate.md) | Spearmans correlation coefficient (overall ranking quality) | 
**ndcg** | [**MetricEstimate**](MetricEstimate.md) | Normalized discounted cumulative gain (top-k ranking quality) | 

## Example

```python
from biocentral_api._generated.models.ranking_result import RankingResult

# TODO update the JSON string below
json = "{}"
# create an instance of RankingResult from a JSON string
ranking_result_instance = RankingResult.from_json(json)
# print the JSON string representation of the object
print(RankingResult.to_json())

# convert the object into a dict
ranking_result_dict = ranking_result_instance.to_dict()
# create an instance of RankingResult from a dict
ranking_result_from_dict = RankingResult.from_dict(ranking_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


