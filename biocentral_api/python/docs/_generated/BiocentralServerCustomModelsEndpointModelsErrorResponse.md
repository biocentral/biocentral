# BiocentralServerCustomModelsEndpointModelsErrorResponse

Standard error response model

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**error** | **str** |  | 
**detail** | **str** |  | [optional] 

## Example

```python
from biocentral_server_api._generated.models.biocentral_server_custom_models_endpoint_models_error_response import BiocentralServerCustomModelsEndpointModelsErrorResponse

# TODO update the JSON string below
json = "{}"
# create an instance of BiocentralServerCustomModelsEndpointModelsErrorResponse from a JSON string
biocentral_server_custom_models_endpoint_models_error_response_instance = BiocentralServerCustomModelsEndpointModelsErrorResponse.from_json(json)
# print the JSON string representation of the object
print(BiocentralServerCustomModelsEndpointModelsErrorResponse.to_json())

# convert the object into a dict
biocentral_server_custom_models_endpoint_models_error_response_dict = biocentral_server_custom_models_endpoint_models_error_response_instance.to_dict()
# create an instance of BiocentralServerCustomModelsEndpointModelsErrorResponse from a dict
biocentral_server_custom_models_endpoint_models_error_response_from_dict = BiocentralServerCustomModelsEndpointModelsErrorResponse.from_dict(biocentral_server_custom_models_endpoint_models_error_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


