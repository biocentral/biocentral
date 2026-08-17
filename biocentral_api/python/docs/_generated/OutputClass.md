# OutputClass


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**shortcut** | **str** | Shortcut of the label | 
**label** | **str** | Label of the class | 
**description** | **str** | Description of the class | 

## Example

```python
from biocentral_api._generated.models.output_class import OutputClass

# TODO update the JSON string below
json = "{}"
# create an instance of OutputClass from a JSON string
output_class_instance = OutputClass.from_json(json)
# print the JSON string representation of the object
print(OutputClass.to_json())

# convert the object into a dict
output_class_dict = output_class_instance.to_dict()
# create an instance of OutputClass from a dict
output_class_from_dict = OutputClass.from_dict(output_class_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


