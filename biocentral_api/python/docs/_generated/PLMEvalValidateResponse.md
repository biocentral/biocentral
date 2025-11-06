# PLMEvalValidateResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**valid** | **bool** | Whether the model is valid for PLM evaluation | 
**error** | **str** |  | 

## Example

```python
from biocentral_api._generated.models.plm_eval_validate_response import PLMEvalValidateResponse

# TODO update the JSON string below
json = "{}"
# create an instance of PLMEvalValidateResponse from a JSON string
plm_eval_validate_response_instance = PLMEvalValidateResponse.from_json(json)
# print the JSON string representation of the object
print(PLMEvalValidateResponse.to_json())

# convert the object into a dict
plm_eval_validate_response_dict = plm_eval_validate_response_instance.to_dict()
# create an instance of PLMEvalValidateResponse from a dict
plm_eval_validate_response_from_dict = PLMEvalValidateResponse.from_dict(plm_eval_validate_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


