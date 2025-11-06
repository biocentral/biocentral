# PLMEvalTaskInformation


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **str** | Name of the task | 
**description** | **str** | Description of the task | 

## Example

```python
from biocentral_api._generated.models.plm_eval_task_information import PLMEvalTaskInformation

# TODO update the JSON string below
json = "{}"
# create an instance of PLMEvalTaskInformation from a JSON string
plm_eval_task_information_instance = PLMEvalTaskInformation.from_json(json)
# print the JSON string representation of the object
print(PLMEvalTaskInformation.to_json())

# convert the object into a dict
plm_eval_task_information_dict = plm_eval_task_information_instance.to_dict()
# create an instance of PLMEvalTaskInformation from a dict
plm_eval_task_information_from_dict = PLMEvalTaskInformation.from_dict(plm_eval_task_information_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


