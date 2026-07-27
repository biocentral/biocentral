# RunTestRequest


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**hash** | **str** |  | 
**test** | **str** |  | 

## Example

```python
from biocentral_api._generated.models.run_test_request import RunTestRequest

# TODO update the JSON string below
json = "{}"
# create an instance of RunTestRequest from a JSON string
run_test_request_instance = RunTestRequest.from_json(json)
# print the JSON string representation of the object
print(RunTestRequest.to_json())

# convert the object into a dict
run_test_request_dict = run_test_request_instance.to_dict()
# create an instance of RunTestRequest from a dict
run_test_request_from_dict = RunTestRequest.from_dict(run_test_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


