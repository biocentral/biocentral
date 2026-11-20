# PerplexityResult

(Pseudo)perplexity result for a set of sequences (method depends on given protein language model).

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**method** | [**biotrainer_core.data_classes.ZeroShotMethod**](biotrainer_core.data_classes.ZeroShotMethod.md) | Either perplexity or pseudoperplexity | 
**seq2perplexity** | **Dict[str, float]** | Dictionary mapping sequence IDs to their (pseudo)perplexity scores | 

## Example

```python
from biocentral_api._generated.models.perplexity_result import PerplexityResult

# TODO update the JSON string below
json = "{}"
# create an instance of PerplexityResult from a JSON string
perplexity_result_instance = PerplexityResult.from_json(json)
# print the JSON string representation of the object
print(PerplexityResult.to_json())

# convert the object into a dict
perplexity_result_dict = perplexity_result_instance.to_dict()
# create an instance of PerplexityResult from a dict
perplexity_result_from_dict = PerplexityResult.from_dict(perplexity_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


