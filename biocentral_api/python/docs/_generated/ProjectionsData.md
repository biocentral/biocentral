# ProjectionsData

## Properties

| Name                | Type                      | Description | Notes |
| ------------------- | ------------------------- | ----------- | ----- |
| **projection_name** | **List[str]**             |             |
| **identifier**      | **List[str]**             |             |
| **x**               | **List[float]**           |             |
| **y**               | **List[float]**           |             |
| **z**               | **List[Optional[float]]** |             |

## Example

```python
from biocentral_api._generated.models.projections_data import ProjectionsData

# TODO update the JSON string below
json = "{}"
# create an instance of ProjectionsData from a JSON string
projections_data_instance = ProjectionsData.from_json(json)
# print the JSON string representation of the object
print(ProjectionsData.to_json())

# convert the object into a dict
projections_data_dict = projections_data_instance.to_dict()
# create an instance of ProjectionsData from a dict
projections_data_from_dict = ProjectionsData.from_dict(projections_data_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
