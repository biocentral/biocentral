# SplitHBIRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**train_seqs** | **Dict[str, str]** | Target database sequences (train split) | 
**query_seqs** | **Dict[str, str]** | Query database sequences to evaluate (test/val split) | 
**train_labels** | **Dict[str, object]** | Ground truth annotations for train sequences | 
**query_labels** | **Dict[str, object]** | Ground truth annotations for query sequences | 
**evalue_cutoff** | **float** | Maximum MMSeqs2 E-value threshold | [optional] [default to 10.0]
**min_seq_id** | **float** | Minimum sequence identity threshold | [optional] [default to 0.0]
**is_numeric** | **bool** | True for continuous regression targets, False for classification | [optional] [default to False]
**iterations** | **int** | Bootstrap iterations performed | [optional] [default to 30]

## Example

```python
from biocentral_api._generated.models.split_hbi_request import SplitHBIRequest

# TODO update the JSON string below
json = "{}"
# create an instance of SplitHBIRequest from a JSON string
split_hbi_request_instance = SplitHBIRequest.from_json(json)
# print the JSON string representation of the object
print(SplitHBIRequest.to_json())

# convert the object into a dict
split_hbi_request_dict = split_hbi_request_instance.to_dict()
# create an instance of SplitHBIRequest from a dict
split_hbi_request_from_dict = SplitHBIRequest.from_dict(split_hbi_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


