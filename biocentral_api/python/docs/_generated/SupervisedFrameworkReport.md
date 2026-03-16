# SupervisedFrameworkReport


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**min_seq_len** | **int** |  | [optional] 
**max_seq_len** | **int** |  | [optional] 
**results** | **Dict[str, Dict[str, object]]** | Supervised autoeval results | 

## Example

```python
from biocentral_api._generated.models.supervised_framework_report import SupervisedFrameworkReport

# TODO update the JSON string below
json = "{}"
# create an instance of SupervisedFrameworkReport from a JSON string
supervised_framework_report_instance = SupervisedFrameworkReport.from_json(json)
# print the JSON string representation of the object
print(SupervisedFrameworkReport.to_json())

# convert the object into a dict
supervised_framework_report_dict = supervised_framework_report_instance.to_dict()
# create an instance of SupervisedFrameworkReport from a dict
supervised_framework_report_from_dict = SupervisedFrameworkReport.from_dict(supervised_framework_report_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


