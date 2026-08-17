# StartInferenceRequest

Request model for starting inference

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**model_hash** | **str** | Hash identifier for the trained model to use for inference | 
**sequence_data** | **Dict[str, str]** | Sequence data for inference (seq_id -&gt; sequence) | 

## Example

```python
from biocentral_api._generated.models.start_inference_request import StartInferenceRequest

# TODO update the JSON string below
json = "{}"
# create an instance of StartInferenceRequest from a JSON string
start_inference_request_instance = StartInferenceRequest.from_json(json)
# print the JSON string representation of the object
print(StartInferenceRequest.to_json())

# convert the object into a dict
start_inference_request_dict = start_inference_request_instance.to_dict()
# create an instance of StartInferenceRequest from a dict
start_inference_request_from_dict = StartInferenceRequest.from_dict(start_inference_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


