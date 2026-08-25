# ResearchStats


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**total_sequences_today** | **int** | Total number of sequences uploaded in the last 24 hours | 
**total_sequences_all_time** | **int** | Total number of sequences uploaded in all time | 
**avg_sequence_length** | **float** | Average length of sequences uploaded | 
**aa_distribution** | **Dict[str, int]** | Distribution of amino acids in the sequences | 
**top_embedders** | **Dict[str, float]** | Top embedders based on usage | 
**top_predictors** | **Dict[str, float]** | Top prediction models based on usage | 
**updated_at** | **datetime** | Timestamp of the last update | 

## Example

```python
from biocentral_api._generated.models.research_stats import ResearchStats

# TODO update the JSON string below
json = "{}"
# create an instance of ResearchStats from a JSON string
research_stats_instance = ResearchStats.from_json(json)
# print the JSON string representation of the object
print(ResearchStats.to_json())

# convert the object into a dict
research_stats_dict = research_stats_instance.to_dict()
# create an instance of ResearchStats from a dict
research_stats_from_dict = ResearchStats.from_dict(research_stats_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


