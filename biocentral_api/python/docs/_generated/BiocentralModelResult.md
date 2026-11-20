# BiocentralModelResult


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**model_result** | [**biotrainer_core.data_classes.BiotrainerModelResult**](biotrainer_core.data_classes.BiotrainerModelResult.md) | Biotrainer Model Result containing config, training and test results and metadata | 
**logging_file** | **str** | Logging output during model training | 
**checkpoints** | [**List[BiotrainerCheckpoint]**](BiotrainerCheckpoint.md) | List of bytes containing the checkpoint(s) of the model (name -&gt; checkpoint) | 
**onnx_checkpoint** | [**List[BiotrainerCheckpoint]**](BiotrainerCheckpoint.md) | Bytes containing the ONNX-converted checkpoint(s) of the model (if available, name -&gt; checkpoint) | [optional] 

## Example

```python
from biocentral_api._generated.models.biocentral_model_result import BiocentralModelResult

# TODO update the JSON string below
json = "{}"
# create an instance of BiocentralModelResult from a JSON string
biocentral_model_result_instance = BiocentralModelResult.from_json(json)
# print the JSON string representation of the object
print(BiocentralModelResult.to_json())

# convert the object into a dict
biocentral_model_result_dict = biocentral_model_result_instance.to_dict()
# create an instance of BiocentralModelResult from a dict
biocentral_model_result_from_dict = BiocentralModelResult.from_dict(biocentral_model_result_dict)
```
[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


