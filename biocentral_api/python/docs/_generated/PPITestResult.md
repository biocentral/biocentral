# PPITestResult


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**success** | **str** |  | 
**information** | **str** |  | 
**test_metrics** | **str** |  | 
**test_statistic** | **str** |  | 
**p_value** | **str** |  | 
**significance_level** | **float** |  | 

## Example

```python
from biocentral_api._generated.models.ppi_test_result import PPITestResult

# TODO update the JSON string below
json = "{}"
# create an instance of PPITestResult from a JSON string
ppi_test_result_instance = PPITestResult.from_json(json)
# print the JSON string representation of the object
print(PPITestResult.to_json())

# convert the object into a dict
ppi_test_result_dict = ppi_test_result_instance.to_dict()
# create an instance of PPITestResult from a dict
ppi_test_result_from_dict = PPITestResult.from_dict(ppi_test_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


