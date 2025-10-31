# PLMEvalValidateRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**model_id** | **str** | Huggingface model identifier | 

## Example

```python
from biocentral_server_api._generated.models.plm_eval_validate_request import PLMEvalValidateRequest

# TODO update the JSON string below
json = "{}"
# create an instance of PLMEvalValidateRequest from a JSON string
plm_eval_validate_request_instance = PLMEvalValidateRequest.from_json(json)
# print the JSON string representation of the object
print(PLMEvalValidateRequest.to_json())

# convert the object into a dict
plm_eval_validate_request_dict = plm_eval_validate_request_instance.to_dict()
# create an instance of PLMEvalValidateRequest from a dict
plm_eval_validate_request_from_dict = PLMEvalValidateRequest.from_dict(plm_eval_validate_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


