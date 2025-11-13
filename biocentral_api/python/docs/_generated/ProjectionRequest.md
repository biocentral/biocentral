# ProjectionRequest

Request model for projection

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**sequence_data** | **Dict[str, str]** | Sequence data to embed (seq_id -&gt; sequence) | 
**method** | **str** | Projection method to use | 
**config** | **Dict[str, object]** | Projection configuration | 
**embedder_name** | **str** | Name of the embedder model | 

## Example

```python
from biocentral_api._generated.models.projection_request import ProjectionRequest

# TODO update the JSON string below
json = "{}"
# create an instance of ProjectionRequest from a JSON string
projection_request_instance = ProjectionRequest.from_json(json)
# print the JSON string representation of the object
print(ProjectionRequest.to_json())

# convert the object into a dict
projection_request_dict = projection_request_instance.to_dict()
# create an instance of ProjectionRequest from a dict
projection_request_from_dict = ProjectionRequest.from_dict(projection_request_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


