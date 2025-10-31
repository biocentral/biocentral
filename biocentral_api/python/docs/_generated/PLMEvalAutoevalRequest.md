# PLMEvalAutoevalRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**model_id** | **str** | Huggingface model identifier | 
**onnx_file** | **str** |  | 
**tokenizer_config** | **str** |  | 

## Example

```python
from biocentral_server_api._generated.models.plm_eval_autoeval_request import PLMEvalAutoevalRequest

# TODO update the JSON string below
json = "{}"
# create an instance of PLMEvalAutoevalRequest from a JSON string
plm_eval_autoeval_request_instance = PLMEvalAutoevalRequest.from_json(json)
# print the JSON string representation of the object
print(PLMEvalAutoevalRequest.to_json())

# convert the object into a dict
plm_eval_autoeval_request_dict = plm_eval_autoeval_request_instance.to_dict()
# create an instance of PLMEvalAutoevalRequest from a dict
plm_eval_autoeval_request_from_dict = PLMEvalAutoevalRequest.from_dict(plm_eval_autoeval_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


