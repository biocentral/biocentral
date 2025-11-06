# PLMEvalInformationResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**info** | [**PLMEvalInformation**](PLMEvalInformation.md) | Information about the PLM evaluation process | 

## Example

```python
from biocentral_api._generated.models.plm_eval_information_response import PLMEvalInformationResponse

# TODO update the JSON string below
json = "{}"
# create an instance of PLMEvalInformationResponse from a JSON string
plm_eval_information_response_instance = PLMEvalInformationResponse.from_json(json)
# print the JSON string representation of the object
print(PLMEvalInformationResponse.to_json())

# convert the object into a dict
plm_eval_information_response_dict = plm_eval_information_response_instance.to_dict()
# create an instance of PLMEvalInformationResponse from a dict
plm_eval_information_response_from_dict = PLMEvalInformationResponse.from_dict(plm_eval_information_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


