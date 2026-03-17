# BiocentralServiceStats


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**usable_cpu_count** | **int** | Number of usable CPU cores available to the process | 
**embeddings_database_size** | **int** | Current size of the embeddings database in bytes | 
**total_tasks** | **int** | Total number of tasks submitted since server startup | 
**queue_length** | **int** | Current number of tasks queued for execution | 
**cuda_available** | **bool** | Whether CUDA GPU acceleration is available | 
**cuda_device_names** | **List[str]** | List of names of available CUDA devices | 
**cuda_device_count** | **int** | Number of available CUDA devices | 

## Example

```python
from biocentral_api._generated.models.biocentral_service_stats import BiocentralServiceStats

# TODO update the JSON string below
json = "{}"
# create an instance of BiocentralServiceStats from a JSON string
biocentral_service_stats_instance = BiocentralServiceStats.from_json(json)
# print the JSON string representation of the object
print(BiocentralServiceStats.to_json())

# convert the object into a dict
biocentral_service_stats_dict = biocentral_service_stats_instance.to_dict()
# create an instance of BiocentralServiceStats from a dict
biocentral_service_stats_from_dict = BiocentralServiceStats.from_dict(biocentral_service_stats_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


