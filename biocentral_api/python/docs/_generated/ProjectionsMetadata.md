# ProjectionsMetadata

## Properties

| Name                | Type          | Description | Notes |
| ------------------- | ------------- | ----------- | ----- |
| **projection_name** | **List[str]** |             |
| **dimensions**      | **List[int]** |             |
| **info_json**       | **List[str]** |             |

## Example

```python
from biocentral_api._generated.models.projections_metadata import ProjectionsMetadata

# TODO update the JSON string below
json = "{}"
# create an instance of ProjectionsMetadata from a JSON string
projections_metadata_instance = ProjectionsMetadata.from_json(json)
# print the JSON string representation of the object
print(ProjectionsMetadata.to_json())

# convert the object into a dict
projections_metadata_dict = projections_metadata_instance.to_dict()
# create an instance of ProjectionsMetadata from a dict
projections_metadata_from_dict = ProjectionsMetadata.from_dict(projections_metadata_dict)
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
