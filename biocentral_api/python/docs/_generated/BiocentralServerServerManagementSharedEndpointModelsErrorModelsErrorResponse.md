# BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**error** | **str** |  | 
**error_type** | **str** |  | 
**details** | **str** |  | [optional] 
**error_code** | **int** |  | [optional] 

## Example

```python
from biocentral_server_api._generated.models.biocentral_server_server_management_shared_endpoint_models_error_models_error_response import BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse

# TODO update the JSON string below
json = "{}"
# create an instance of BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse from a JSON string
biocentral_server_server_management_shared_endpoint_models_error_models_error_response_instance = BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse.from_json(json)
# print the JSON string representation of the object
print(BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse.to_json())

# convert the object into a dict
biocentral_server_server_management_shared_endpoint_models_error_models_error_response_dict = biocentral_server_server_management_shared_endpoint_models_error_models_error_response_instance.to_dict()
# create an instance of BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse from a dict
biocentral_server_server_management_shared_endpoint_models_error_models_error_response_from_dict = BiocentralServerServerManagementSharedEndpointModelsErrorModelsErrorResponse.from_dict(biocentral_server_server_management_shared_endpoint_models_error_models_error_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


