# ModelMetadata


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | [**BiocentralPredictionModel**](BiocentralPredictionModel.md) | Model name | 
**protocol** | [**Protocol**](Protocol.md) | Protocol of model predictions | 
**description** | **str** | Model description | 
**authors** | **str** | Authors of the model | 
**model_link** | **str** | Link to the model&#39;s repository | 
**citation** | **str** | Citation of the model | 
**licence** | **str** | Licence of the model | 
**outputs** | [**List[ModelOutput]**](ModelOutput.md) | List of descriptions of model outputs | 
**model_size** | **str** | Size of the model in MB | 
**embedder** | **str** | Name of the embedder used for the model | 
**training_data_link** | **str** |  | [optional] 

## Example

```python
from biocentral_api._generated.models.model_metadata import ModelMetadata

# TODO update the JSON string below
json = "{}"
# create an instance of ModelMetadata from a JSON string
model_metadata_instance = ModelMetadata.from_json(json)
# print the JSON string representation of the object
print(ModelMetadata.to_json())

# convert the object into a dict
model_metadata_dict = model_metadata_instance.to_dict()
# create an instance of ModelMetadata from a dict
model_metadata_from_dict = ModelMetadata.from_dict(model_metadata_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


