# SplitHBIResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**metrics** | [**List[BootstrappedMetric]**](BootstrappedMetric.md) | Bootstrapped evaluation metrics | 
**num_queries** | **int** | Total number of query sequences provided | 
**hits_found** | **int** | Number of queries with homologous hits in train | 
**evaluated_queries** | **int** | Number of queries successfully evaluated | 

## Example

```python
from biocentral_api._generated.models.split_hbi_response import SplitHBIResponse

# TODO update the JSON string below
json = "{}"
# create an instance of SplitHBIResponse from a JSON string
split_hbi_response_instance = SplitHBIResponse.from_json(json)
# print the JSON string representation of the object
print(SplitHBIResponse.to_json())

# convert the object into a dict
split_hbi_response_dict = split_hbi_response_instance.to_dict()
# create an instance of SplitHBIResponse from a dict
split_hbi_response_from_dict = SplitHBIResponse.from_dict(split_hbi_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


