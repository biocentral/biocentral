# TestResult

Test results after training. 

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**inference_result** | [**BiotrainerInferenceResult**](BiotrainerInferenceResult.md) | Plain test inference result | [optional] 
**bootstrapped_metrics** | [**List[BootstrappedMetric]**](BootstrappedMetric.md) | Bootstrapped test metrics | [optional] 
**baselines** | **Dict[str, List[BootstrappedMetric]]** | Bootstrapped baselines by method name | [optional] 
**sanity_check_warnings** | **List[str]** | Warnings from sanity checks | [optional] 

## Example

```python
from biocentral_api._generated.models.test_result import TestResult

# TODO update the JSON string below
json = "{}"
# create an instance of TestResult from a JSON string
test_result_instance = TestResult.from_json(json)
# print the JSON string representation of the object
print(TestResult.to_json())

# convert the object into a dict
test_result_dict = test_result_instance.to_dict()
# create an instance of TestResult from a dict
test_result_from_dict = TestResult.from_dict(test_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


