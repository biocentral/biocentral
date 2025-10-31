# NotFoundErrorResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**error** | **str** |  | 
**error_type** | **str** |  | [optional] [default to 'not_found']
**details** | **str** |  | [optional] 
**error_code** | **int** |  | [optional] 

## Example

```python
from biocentral_server_api._generated.models.not_found_error_response import NotFoundErrorResponse

# TODO update the JSON string below
json = "{}"
# create an instance of NotFoundErrorResponse from a JSON string
not_found_error_response_instance = NotFoundErrorResponse.from_json(json)
# print the JSON string representation of the object
print(NotFoundErrorResponse.to_json())

# convert the object into a dict
not_found_error_response_dict = not_found_error_response_instance.to_dict()
# create an instance of NotFoundErrorResponse from a dict
not_found_error_response_from_dict = NotFoundErrorResponse.from_dict(not_found_error_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


