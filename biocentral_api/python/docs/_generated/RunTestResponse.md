# RunTestResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**test_result** | [**TestResult**](TestResult.md) |  | 

## Example

```python
from biocentral_server_api._generated.models.run_test_response import RunTestResponse

# TODO update the JSON string below
json = "{}"
# create an instance of RunTestResponse from a JSON string
run_test_response_instance = RunTestResponse.from_json(json)
# print the JSON string representation of the object
print(RunTestResponse.to_json())

# convert the object into a dict
run_test_response_dict = run_test_response_instance.to_dict()
# create an instance of RunTestResponse from a dict
run_test_response_from_dict = RunTestResponse.from_dict(run_test_response_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


