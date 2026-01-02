# AutoEvalReport


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**embedder_name** | **str** | Name of the embedder | 
**training_date** | **str** | Date of training | 
**min_seq_len** | **int** | Minimum sequence length used during evaluation | 
**max_seq_len** | **int** | Maximum sequence length used during evaluation | 
**results** | **Dict[str, Dict[str, object]]** | Autoeval results | 

## Example

```python
from biocentral_api._generated.models.auto_eval_report import AutoEvalReport

# TODO update the JSON string below
json = "{}"
# create an instance of AutoEvalReport from a JSON string
auto_eval_report_instance = AutoEvalReport.from_json(json)
# print the JSON string representation of the object
print(AutoEvalReport.to_json())

# convert the object into a dict
auto_eval_report_dict = auto_eval_report_instance.to_dict()
# create an instance of AutoEvalReport from a dict
auto_eval_report_from_dict = AutoEvalReport.from_dict(auto_eval_report_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


