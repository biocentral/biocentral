# PLMEvalInformation


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**n_tasks** | **int** | Number of tasks | 
**tasks** | [**List[PLMEvalTaskInformation]**](PLMEvalTaskInformation.md) | List of tasks | 

## Example

```python
from biocentral_server_api._generated.models.plm_eval_information import PLMEvalInformation

# TODO update the JSON string below
json = "{}"
# create an instance of PLMEvalInformation from a JSON string
plm_eval_information_instance = PLMEvalInformation.from_json(json)
# print the JSON string representation of the object
print(PLMEvalInformation.to_json())

# convert the object into a dict
plm_eval_information_dict = plm_eval_information_instance.to_dict()
# create an instance of PLMEvalInformation from a dict
plm_eval_information_from_dict = PLMEvalInformation.from_dict(plm_eval_information_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


