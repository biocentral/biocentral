# ProjectionResult

## Properties

| Name                     | Type                                              | Description | Notes |
| ------------------------ | ------------------------------------------------- | ----------- | ----- |
| **protein_annotations**  | [**ProteinAnnotations**](ProteinAnnotations.md)   |             |
| **projections_metadata** | [**ProjectionsMetadata**](ProjectionsMetadata.md) |             |
| **projections_data**     | [**ProjectionsData**](ProjectionsData.md)         |             |

## Example

```python
from biocentral_api._generated.models.projection_result import ProjectionResult

# TODO update the JSON string below
json = "{}"
# create an instance of ProjectionResult from a JSON string
projection_result_instance = ProjectionResult.from_json(json)
# print the JSON string representation of the object
print(ProjectionResult.to_json())

# convert the object into a dict
projection_result_dict = projection_result_instance.to_dict()
# create an instance of ProjectionResult from a dict
projection_result_from_dict = ProjectionResult.from_dict(projection_result_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
