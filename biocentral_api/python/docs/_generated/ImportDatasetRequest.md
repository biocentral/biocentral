# ImportDatasetRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**format** | **str** |  | 
**dataset** | **str** |  | 

## Example

```python
from biocentral_server_api._generated.models.import_dataset_request import ImportDatasetRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ImportDatasetRequest from a JSON string
import_dataset_request_instance = ImportDatasetRequest.from_json(json)
# print the JSON string representation of the object
print(ImportDatasetRequest.to_json())

# convert the object into a dict
import_dataset_request_dict = import_dataset_request_instance.to_dict()
# create an instance of ImportDatasetRequest from a dict
import_dataset_request_from_dict = ImportDatasetRequest.from_dict(import_dataset_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


