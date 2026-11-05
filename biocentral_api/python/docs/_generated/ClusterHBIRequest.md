# ClusterHBIRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**dataset_hash** | **str** | Unique hash of the dataset for caching | 
**sequence_identity_threshold** | **float** | Sequence identity threshold for clustering | [optional] [default to 0.3]
**sequence_data** | **Dict[str, str]** | Map of sequence_id -&gt; sequence. Required on first call | [optional] 
**target_data** | **Dict[str, object]** | Map of sequence_id -&gt; target label/value for evaluation | 
**is_numeric** | **bool** | True for continuous regression targets, False for classification | [optional] [default to False]
**iterations** | **int** | Bootstrap iterations performed | [optional] [default to 30]

## Example

```python
from biocentral_api._generated.models.cluster_hbi_request import ClusterHBIRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ClusterHBIRequest from a JSON string
cluster_hbi_request_instance = ClusterHBIRequest.from_json(json)
# print the JSON string representation of the object
print(ClusterHBIRequest.to_json())

# convert the object into a dict
cluster_hbi_request_dict = cluster_hbi_request_instance.to_dict()
# create an instance of ClusterHBIRequest from a dict
cluster_hbi_request_from_dict = ClusterHBIRequest.from_dict(cluster_hbi_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


